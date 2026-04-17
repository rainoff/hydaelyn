[English](README.md) | [繁體中文](README.zh-TW.md)

# hydaelyn

A personal [Claude Code](https://docs.anthropic.com/en/docs/claude-code) setup: rules, agents, skills, hooks, and a three-tier memory system. Maps to `~/.claude`. Clone it, adjust a few personal settings (permissions, notification hooks), and it runs.

The rules accumulated over time. Each one traces back to a specific incident: Claude did something wrong in some situation, and a rule got added so it wouldn't repeat. A reasonable starting point is `CLAUDE.md` plus `dev-workflow.md` and `session-management.md` — add more as specific pain points show up.

## Directory Structure

```
~/.claude/
├── CLAUDE.md                 # 5 principles + Context Check
├── settings.json             # permissions, hooks, language
├── keybindings.json          # custom keybindings
├── CHANGELOG.md              # rule change log
│
├── rules/                    # behavior rules (global or path-scoped)
│   ├── dev-workflow.md       # task start, commit discipline, effort modes
│   ├── session-management.md # session notes, stale todo tracking, MR convergence
│   ├── knowledge-index.md    # memory in three tiers (Hot/Warm/Glacier)
│   ├── sdd.md                # Spec-driven: System Spec + Change Spec
│   ├── jira-sync.md          # JIRA sync, 5 trigger points
│   ├── verification-loop.md  # Critic → Alignment → review (max 2 fix rounds)
│   ├── ownership.md          # CODEOWNERS-based cross-module check
│   ├── subagent-strategy.md  # Fork / Teammate / Worktree delegation
│   ├── worktree-memory.md    # Worktree memory inheritance
│   ├── web-fetch-safety.md   # External content safety (prompt injection defense)
│   ├── figma-workflow.md     # paths: UI files — Figma MCP four-phase flow
│   ├── visual-ui-workflow.md # paths: UI files — visual change flow
│   ├── writing-style.md      # paths: README, docs — prose style
│   └── spec-template.md      # paths: specs — Change Spec format
│
├── agents/                   # subagents (isolated context)
│   ├── task-executor.md      # Builder — implements a single subtask (Sonnet)
│   ├── critic.md             # Adversarial review, pattern consistency first (Opus)
│   ├── alignment-checker.md  # External reference alignment — Figma/schema/spec (Opus)
│   ├── code-reviewer.md      # Logic, error handling, code patterns (Opus)
│   ├── security-reviewer.md  # OWASP, permissions, secrets, injection (Opus)
│   └── code-simplifier.md    # Remove dead code, over-abstraction (Sonnet)
│
├── skills/                   # intent-triggered workflows
│   ├── autopilot/            # Auto build → critic → alignment → fix loop
│   ├── git-commit/           # generate and execute git commit
│   ├── pr/                   # create MR/PR from commits
│   └── review/               # parallel three-agent review before push
│
├── commands/                 # slash commands (manually invoked)
│   ├── plan.md               # /plan — structured planning, outputs spec
│   ├── project-init.md       # /project-init — initialize project
│   ├── session.md            # /session — progress snapshot + knowledge extraction
│   ├── housekeeping.md       # /housekeeping — memory cleanup and archival
│   ├── reflect.md            # /reflect — review sessions, detect violations
│   ├── evolve.md             # /evolve — modify rules based on reflect output
│   ├── careful.md            # /careful — enable destructive command blocking
│   └── freeze.md             # /freeze — lock edit scope
│
└── scripts/                  # hook scripts
    ├── setup.sh
    ├── claude-notify-macos.sh
    └── claude-notify-linux.sh
```

## Architecture

Built on Claude Code's native extension points:

| Layer | What | When loaded |
|---|---|---|
| `CLAUDE.md` | Project-wide instructions and principles | Every session |
| `rules/` | Behavior rules, one topic per file | Every session (global) or on matching files (`paths:` frontmatter) |
| `agents/` | Subagents with isolated context, own model and tool set | When delegated to |
| `skills/` | Intent-triggered workflows | When invoked or intent-matched |
| `commands/` | Manual slash commands | When invoked |
| Hooks (`settings.json`) | Shell scripts at lifecycle events — PreToolUse, Stop, PreCompact | Every matching event |

### Path-scoped rules

Rules without frontmatter load every session. Add `paths:` to scope a rule to specific file patterns — it only loads when Claude works with matching files.

```yaml
# rules/figma-workflow.md — only loads when editing UI or spec files
---
paths:
  - "**/*.tsx"
  - "**/*.css"
  - "specs/**/figma*"
---
```

Four rules use `paths:` in this playbook: `figma-workflow`, `visual-ui-workflow`, `writing-style`, `spec-template`. The rest load globally.

### Governance layers (custom)

Three patterns go beyond the official extension points:

| Pattern | What it adds | Built with |
|---|---|---|
| Three-tier memory | Hot / Warm / Glacier archival on top of auto memory | `rules/knowledge-index.md` + `commands/housekeeping.md` |
| Spec-driven development | System Spec (as-is) + Change Spec (to-be) per module | `rules/sdd.md` + `rules/spec-template.md` + `commands/plan.md` |
| Builder-Critic verification | task-executor → critic (fresh context) → alignment-checker | `agents/` + `rules/verification-loop.md` + `skills/autopilot/` |

Optional. The playbook works at L1 without any of these.

## Getting Started

```bash
git clone https://github.com/rainoff/hydaelyn.git ~/.claude
```

Don't enable everything at once. See the levels below and pick what's useful now. Unused rules (JIRA, Figma) can be deleted without affecting the rest.

### Maturity Levels

| Level | Files | What it provides |
|---|---|---|
| **L1 — Foundation** | `CLAUDE.md` + `rules/dev-workflow.md` + `rules/session-management.md` | Context Check, commit discipline, session handoff |
| **L2 — Automation** | L1 + `agents/` + `skills/` + `rules/verification-loop.md` | Builder-Critic loop, auto commit/review, `/plan` workflow |
| **L3 — Self-iteration** | L2 + `memory/` + `/reflect` + `/evolve` | Three-tier memory, rules that evolve from real failures, cross-session learning |

Start at L1. Move to L2 when the AI keeps making mistakes a second reviewer would catch. Move to L3 when the system needs to improve itself across sessions.

### Customization

| Situation | What to do |
|---|---|
| Not using JIRA | Delete `rules/jira-sync.md` |
| Not using Figma | Delete `rules/figma-workflow.md` |
| Project-specific rules | Put them under `{project}/.claude/rules/`, not global |
| macOS | Use `claude-notify-macos.sh` |
| Linux | Use `claude-notify-linux.sh` |
| Windows | Write a PowerShell notification script |
| Change response language | Edit `language` in `settings.json` (default: zh-TW) |

## Key Design Pieces

### Five Principles (CLAUDE.md)

1. **Don't assume** — can't find the info? Look it up or ask.
2. **Context Check** — before any code change, list: modules involved, memory read, existing patterns, upstream/downstream, what's still unclear.
3. **Follow existing patterns** — consistency over cleverness. No new conventions without approval.
4. **Context compaction preferences** — tell the harness what to preserve first when compacting.
5. **When to ask, look up, or act** — a decision table.

### Two Execution Modes

| Mode | Use case | Pattern consistency |
|---|---|---|
| `conservative` (default) | Existing projects | Enforced |
| `rapid` | New projects, fast iteration | Relaxed |

### Memory in Three Tiers

```
Hot    → MEMORY.md (always loaded, ≤50 lines, knowledge map)
Warm   → memory/*.md (loaded on demand, frontmatter description for quick scan)
Glacier → same directory, frontmatter archived: true (files don't move)
```

### Spec-driven development

Two spec types per module:

| Type | Role |
|---|---|
| **System Spec** (as-is) | Ground truth of what the module looks like now — Intent, Public API, Extension Points, Gotchas |
| **Change Spec** (to-be) | Delta of what's changing this round — AC, Pattern Compliance, test mapping |

Incremental adoption: write specs only for the modules you're touching. Missing specs don't block the flow. If you have the OpenSpec CLI, use it; otherwise write the files by hand — the format is the same.

Storage precedence for System Specs: in-repo `openspec/specs/` → private fallback `~/.claude/projects/{key}/specs/system/` → memory fallback. The third is transitional; migrate to a spec later.

Split with memory: specs hold structural knowledge (API, dependencies, extension points); memory holds experiential (past pitfalls) and situational (what's in progress).

### Verification Flow

```
task-executor (Sonnet) implements
        ↓
critic (Opus) — fresh context, no builder conversation history
        ↓ PASS
alignment-checker — alignment against external references (Figma/schema/spec)
        ↓ ALIGNED
main session verification → commit
```

Max 2 fix rounds per step. More than that means the decomposition was wrong — go back and re-split.

### Self-iteration

```
/plan → /autopilot → /session → /reflect → /evolve
```

`/reflect` reviews recent sessions for patterns and rule violations. `/evolve` adjusts the rules based on what surfaces (always asks before modifying anything).

### Hooks

| Hook | When | What it does |
|---|---|---|
| PreToolUse (Edit/Write) | Before every file write | Remind Context Check + MEMORY.md read |
| PreCompact | Before context compaction | Remind to run `/session` |
| Stop (self-check) | When the AI stops | Self-verify: is the task actually done? |
| Stop (uncommitted) | When the AI stops | Warn about uncommitted files |

Notification hooks live in `scripts/`; there are macOS and Linux versions. For Windows, write a PowerShell script using `New-BurntToastNotification` or similar.

## Design Rationale

**Rules come from stepping on rakes.** Example: critic must run in fresh context — that rule exists because when the AI reviews code it just wrote, it rationalizes the missing pieces. One incident, one rule.

**Determinism beats self-discipline.** Hooks check `git status` and echo reminders rather than relying on the AI to remember. Bash is reliable; AI memory isn't.

**Memory needs tiering and archival.** Outdated memory makes the AI act on wrong assumptions, which is harder to catch than missing memory. So: description scan first, archived flag for stale entries, Hot layer capped at 50 lines.

## Similar Projects

| | This playbook | [shanraisshan/claude-code-best-practice](https://github.com/shanraisshan/claude-code-best-practice) | [BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD) | [HumanLayer](https://github.com/humanlayer/humanlayer) |
|---|---|---|---|---|
| **Type** | Personal config | Best-practice doc | Full Agile methodology | Human-in-the-loop SDK |
| **Scope** | `~/.claude` only | Docs + examples | 9 agent roles, 4 phases | MCP daemon + cloud |
| **Rules origin** | Accumulated from real failures | Community-curated | Designed upfront | N/A |
| **Self-iteration** | `/reflect` + `/evolve` | No | No | No |
| **Memory** | Three-tier | No | No | No |
| **Weight** | Medium | Light | Heavy | Separate layer |

These can work together. HumanLayer can handle approval gates, shanraisshan's examples are worth borrowing from, BMAD's phase structure can slot on top — this playbook's rules and memory don't conflict with any of them.

## License

MIT. Fork and adapt.
