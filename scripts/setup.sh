#!/usr/bin/env bash
# ~/.claude bootstrap script
# Usage: bash ~/.claude/scripts/setup.sh
#
# Prerequisites:
#   - Node.js + npm installed
#   - Git installed
#   - Claude Code CLI installed
#
# What this script does:
#   1. Install dotenvx if needed, decrypt .env with DOTENV_PRIVATE_KEY
#   2. Generate settings.local.json from .env
#   3. Install JIRA MCP server
#   4. Offer to clone registered projects
#   5. Path remapping for cross-machine portability
#   6. Verify setup

set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
cd "$CLAUDE_DIR"

echo "=== Claude Code Bootstrap ==="
echo ""

# ─── Step 1: Decrypt .env ───
# .env in repo is encrypted by dotenvx. We need DOTENV_PRIVATE_KEY to decrypt.
# Store this key in your password manager.

if ! command -v dotenvx &>/dev/null; then
  echo "[*] Installing dotenvx..."
  npm install -g @dotenvx/dotenvx
fi

# Check if .env is already decrypted (contains no "encrypted:" values)
if grep -q "encrypted:" .env 2>/dev/null; then
  if [ -z "${DOTENV_PRIVATE_KEY:-}" ]; then
    echo ""
    echo "[!] .env is encrypted. Paste your DOTENV_PRIVATE_KEY (from your password manager):"
    read -rs DOTENV_KEY_INPUT
    export DOTENV_PRIVATE_KEY="$DOTENV_KEY_INPUT"
    echo ""
  fi

  echo "[*] Decrypting .env..."
  dotenvx decrypt
  echo "[✓] .env decrypted"
else
  echo "[✓] .env already decrypted"
fi

# ─── Step 2: Load .env ───
set -a
source .env
set +a

# Validate required vars
MISSING=""
[ -z "${JIRA_HOST:-}" ] && MISSING="$MISSING JIRA_HOST"
[ -z "${JIRA_EMAIL:-}" ] && MISSING="$MISSING JIRA_EMAIL"
[ -z "${JIRA_API_TOKEN:-}" ] && MISSING="$MISSING JIRA_API_TOKEN"
[ -z "${JIRA_DEFAULT_PROJECT:-}" ] && MISSING="$MISSING JIRA_DEFAULT_PROJECT"

if [ -n "$MISSING" ]; then
  echo "[!] Missing required variables in .env:$MISSING"
  exit 1
fi

echo "[✓] .env variables loaded"

# ─── Step 3: Install JIRA MCP server ───
MCP_DIR="$CLAUDE_DIR/mcp-jira-server"
if [ ! -d "$MCP_DIR/dist" ]; then
  echo "[*] Installing JIRA MCP server..."
  if [ ! -d "$MCP_DIR" ]; then
    git clone https://github.com/tom28881/mcp-jira-server.git "$MCP_DIR"
  fi
  cd "$MCP_DIR"
  npm install
  npm run build
  cd "$CLAUDE_DIR"
  echo "[✓] JIRA MCP server installed"
else
  echo "[✓] JIRA MCP server already installed"
fi

# ─── Step 4: Generate settings.local.json ───
MCP_INDEX="$MCP_DIR/dist/index.js"
# Convert to forward slashes for JSON
MCP_INDEX_JSON=$(echo "$MCP_INDEX" | sed 's|\\|/|g')

cat > "$CLAUDE_DIR/settings.local.json" << JSONEOF
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest", "--headless"]
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"]
    },
    "supabase": {
      "type": "http",
      "url": "https://mcp.supabase.com/mcp"
    },
    "jira": {
      "command": "node",
      "args": ["$MCP_INDEX_JSON"],
      "env": {
        "JIRA_HOST": "$JIRA_HOST",
        "JIRA_EMAIL": "$JIRA_EMAIL",
        "JIRA_API_TOKEN": "$JIRA_API_TOKEN",
        "JIRA_DEFAULT_PROJECT": "$JIRA_DEFAULT_PROJECT"
      }
    }
  }
}
JSONEOF

echo "[✓] settings.local.json generated"

# ─── Step 5: Clone projects ───
CONF="$CLAUDE_DIR/projects.conf"
if [ -f "$CONF" ]; then
  echo ""
  echo "=== Project Cloning ==="
  echo ""
  echo "Default paths are from the original machine. You can change them."
  echo ""

  # Read projects.conf, skip comments and blank lines
  i=0
  declare -a PATHS=()
  declare -a URLS=()
  declare -a DESCS=()
  declare -a KEYS=()

  while IFS='|' read -r path url desc key; do
    # Skip comments and blank lines
    [[ "$path" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${path// /}" ]] && continue

    path=$(echo "$path" | xargs)  # trim whitespace
    url=$(echo "$url" | xargs)
    desc=$(echo "$desc" | xargs)
    key=$(echo "$key" | xargs)

    PATHS[$i]="$path"
    URLS[$i]="$url"
    DESCS[$i]="$desc"
    KEYS[$i]="$key"

    # Check if already cloned
    if [ -d "$path/.git" ]; then
      status="[exists]"
    else
      status="[not cloned]"
    fi

    echo "  [$i] $path $status"
    echo "      $desc"
    echo ""
    i=$((i + 1))
  done < "$CONF"

  echo "Which projects to clone? (comma-separated numbers, 'all', or 'skip')"
  read -r CHOICE

  if [ "$CHOICE" = "skip" ] || [ -z "$CHOICE" ]; then
    echo "[*] Skipping project cloning"
  else
    if [ "$CHOICE" = "all" ]; then
      INDICES=$(seq 0 $((i - 1)))
    else
      INDICES=$(echo "$CHOICE" | tr ',' ' ')
    fi

    for idx in $INDICES; do
      idx=$(echo "$idx" | xargs)  # trim
      default_path="${PATHS[$idx]}"
      u="${URLS[$idx]}"

      echo ""
      echo "  Clone path for $(basename "$default_path")?"
      echo "  Default: $default_path"
      echo "  (Enter to accept, or type a new path)"
      read -r custom_path
      p="${custom_path:-$default_path}"

      if [ -d "$p/.git" ]; then
        echo "  [✓] $p already exists, skipping clone"
      else
        parent=$(dirname "$p")
        mkdir -p "$parent"
        echo "  [*] Cloning → $p"
        git clone "$u" "$p" && echo "  [✓] Cloned $p" || echo "  [!] Failed to clone $p"
      fi

      # Store actual path for remapping
      PATHS[$idx]="$p"
    done
  fi

  # ─── Step 5b: Path remapping ───
  echo ""
  echo "=== Memory Path Remapping ==="
  PROJECTS_DIR="$CLAUDE_DIR/projects"
  REMAP_COUNT=0

  for idx in $(seq 0 $((i - 1))); do
    actual_path="${PATHS[$idx]}"
    original_key="${KEYS[$idx]}"

    [ -z "$original_key" ] && continue
    [ ! -d "$actual_path" ] && continue

    # Derive the new project key from actual path
    # Claude Code rule: replace / and : with --
    new_key=$(echo "$actual_path" | sed 's|:||g; s|/|--|g; s|^--||')

    if [ "$new_key" = "$original_key" ]; then
      continue  # Same path, no remap needed
    fi

    # Original memory/sessions exist but new key directory doesn't
    if [ -d "$PROJECTS_DIR/$original_key" ] && [ ! -d "$PROJECTS_DIR/$new_key" ]; then
      echo "  [*] Remapping: $original_key → $new_key"

      # Create new project dir and symlink memory + sessions
      mkdir -p "$PROJECTS_DIR/$new_key"

      if [ -d "$PROJECTS_DIR/$original_key/memory" ]; then
        # Copy instead of symlink — git tracks the original, new key gets a working copy
        cp -r "$PROJECTS_DIR/$original_key/memory" "$PROJECTS_DIR/$new_key/memory"
        echo "      memory/ copied"
      fi

      if [ -d "$PROJECTS_DIR/$original_key/sessions" ]; then
        cp -r "$PROJECTS_DIR/$original_key/sessions" "$PROJECTS_DIR/$new_key/sessions"
        echo "      sessions/ copied"
      fi

      REMAP_COUNT=$((REMAP_COUNT + 1))
    fi
  done

  if [ $REMAP_COUNT -eq 0 ]; then
    echo "  [✓] All paths match, no remapping needed"
  else
    echo "  [✓] Remapped $REMAP_COUNT project(s)"
  fi
else
  echo "[*] No projects.conf found, skipping project cloning"
fi

# ─── Step 6: Verify ───
echo ""
echo "=== Setup Complete ==="
echo ""
echo "Installed:"
echo "  - settings.local.json (MCP servers configured)"
echo "  - mcp-jira-server (JIRA integration)"
echo ""
echo "Next steps:"
echo "  1. Open Claude Code and run /mcp to verify servers"
echo "  2. Supabase MCP needs OAuth — run Claude Code and it will prompt"
echo "  3. If you have a Gemini API key, add GEMINI_API_KEY to .env"
echo ""
echo "To re-run after changing .env: bash $CLAUDE_DIR/scripts/setup.sh"
