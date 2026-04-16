---
name: git-commit
description: Generate and execute a git commit. Triggers when the user expresses commit intent, including explicit commands ("commit this", "wrap up", "save progress", "that's it for now", "wrapping up") as well as mid-conversation continuations ("ok", "keep organizing", "reorganize" — when the conversational context involves a commit flow).
---

# Git Commit Style

## Trigger Condition

Activate when the user's intent is to **record current uncommitted changes as a git commit**.

Common expressions: "commit this", "save progress", "wrap up", "that's it for now", "wrapping up", "check in", "good enough", "staging this", "phase complete"

Ambiguous phrases like "current progress", "current state" — when uncommitted changes exist in the working tree, default to treating as a commit request.

### Change Source Priority

1. **Staged changes exist** (`git diff --cached`) — use staged changes as the **sole** source.
2. **No staged changes** — fall back to all modified changes (`git diff HEAD`) as the source.

**Isolation Rule (MUST enforce when staged changes exist):**

- Run ONLY `git diff --cached`. Do NOT run `git diff` (unstaged) or inspect `git status` unstaged section.
- Do NOT mention, describe, or reference any unstaged file changes in the commit message, body, bullet points, or user-facing analysis.
- If unstaged changes are visible in the environment, treat them as out-of-scope and ignore completely.
- The commit message, scope, subject, and body MUST reflect ONLY the staged diff content.

Analyze **only the selected source diff above** to infer the appropriate `type`, `scope`, and `subject` according to the rules below.

## Format

Follows the **Commitizen** convention:

```
<type>(<scope>): <subject>

[body]

[footer]
```

## Type Usage

| Type       | When to use                                                           |
| ---------- | --------------------------------------------------------------------- |
| `feat`     | New pages, components, API integrations, animations, env templates    |
| `fix`      | Bug fixes, visual adjustments, logic corrections                      |
| `refactor` | Component decomposition, style cleanup, lint fixes, dead code removal |
| `chore`    | Version bumps, env file maintenance, script renaming                  |
| `docs`     | README updates, environment variable documentation                    |

## Scope Naming

- Use **project name** or **module name** in lowercase: e.g., `auth`, `middleware`, `env`
- Multiple scopes separated by comma: `(app, lib/footer)`
- Infrastructure-level scopes may use uppercase abbreviation: `Dockerfile`
- Path-style scopes are acceptable: `lib/footer`

## Subject Writing Style

- **Functional changes** — written in Traditional Chinese (Taiwan usage): e.g., `新增共用元件 dialog`、`調整列表金額樣式`
- **Technical changes** — written in English: e.g., `update import paths for OAuthConfig`、`add Docker support`
- When mixed, primary intent determines the language — Chinese takes precedence
- Start directly with a verb, no trailing period

## Output Rule

### Execution Flow (must follow in order)

1. **Analyze changes** — Read the diff and determine the appropriate `type`, `scope`, and `subject`.
2. **Print the commit message** — Display the generated commit message in a fenced code block.
3. **Ask for confirmation** — After printing, always ask the user: "Confirm commit?"
4. **Act based on user response:**
   - User approves (e.g., "yes", "OK", "execute", "commit", "right", "y", or any affirmative) — execute `git commit -m "..."`.
   - User requests changes — **immediately and automatically** revise the commit message, reprint the updated version in a fenced code block, and ask for confirmation again — do NOT wait for the user to re-prompt.
   - User declines (e.g., "no", "cancel", "never mind", or any negative) — do not commit, end the flow.

**IMPORTANT: Never execute `git commit` before the user explicitly confirms.**

### Commit Entry Gate

Subagents must NOT execute `git commit`. If a subagent needs to commit, return the proposed message to the main thread and let this skill handle it.

### Additional Rules

- Always output a single commit message — default to one commit regardless of change volume.
- Only if the changes are clearly unrelated in nature (e.g., a bug fix mixed with a new feature), append a one-liner suggestion: "These could also be split into 2 commits — would you like a reference?" — keep it brief, do not elaborate.
- **Do NOT add `Co-Authored-By` or any trailer lines to the commit message.** Claude Code's default behavior appends `Co-Authored-By: Claude ...` — this skill explicitly overrides that. The commit message MUST contain only `<type>(<scope>): <subject>` and optional body/footer defined by this skill.
- **Always use the simple `-m` flag to pass the commit message. Do NOT use HEREDOC (`$(cat <<'EOF'...EOF)`) or any subshell substitution.** These patterns can leave `.git/index.lock` unreleased and break subsequent git operations.
  - ✅ `git commit -m "feat(sd): subject"`
  - ✅ With body: `git commit -m $'feat(sd): subject\n\n- bullet one\n- bullet two'`
  - ❌ `git commit -m "$(cat <<'EOF'...EOF)"`

## Body / Footer

- Body is optional; use when details are too numerous to fit in the subject
- When used, list key changes as bullet points (Chinese preferred)
- Body answers "what changed" at a glance, not "why"
- Footer records Breaking Changes or linked issues

## Anti-patterns

| DON'T                                                                                                   | DO                                                                                                                               |
| ------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| When staged changes exist, describe unstaged files (e.g., `.gitignore`, `middleware.ts`) to the user    | Completely ignore unstaged files; analyze only `git diff --cached`                                                               |
| Add "other unstaged changes include..." to the commit body or user-facing output                        | Keep body strictly limited to content found in the staged diff                                                                   |
| Use `Analyze the diff` ambiguously, causing the AI to pull in all visible diffs                         | Analyze only the source diff selected by Change Source Priority                                                                  |
| Append `Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>` or any trailer to the commit message | Keep the commit message strictly in Commitizen format with no trailers                                                           |
| `git commit -m "$(cat <<'EOF'\nsubject\n\nbody\nEOF\n)"`                                                | `git commit -m "subject"` or with body: `git commit -m $'subject\n\nbody'`                                                       |

## Commit Examples

```
feat(app, lib/footer): 新增 Footer warningList props 支援客製化警告列表；添加客製化內容

feat(tailwind-plugin): update to version 0.3.0 with new typography and effects utilities, including strict mode handling for font-size and line-height

refactor(app): 建立 icon item 元件並且替換，調整樣式

fix(app): TOP 按鈕 - 邏輯調整，改為在 mobile 下滑 100px 時顯示，桌面保持顯示

chore(tailwind-plugin): release version 0.4.0 with refactor of conversion functions and fix for import statement

docs(env): update environment variable documentation, enhancing clarity on usage and structure, and adding a detailed scope section
```
