---
name: review
description: Code review. Triggers when the user is preparing to push or expresses review intent, including "review this", "check this", "see if there are any issues", "ready to push", "about to push", "check before pushing"
---

# Code Review (Multi-Agent Parallel Review)

## Trigger Condition

Activate when the user wants to **review current changes before committing or pushing**.

Common expressions: "review this", "check this", "see if there are any issues", "ready to push", "about to push", "check before pushing", "code review"

## Execution Flow

**Before Step 1**: Per the Effort Mode in `rules/dev-workflow.md` — if not currently at `max`, emit a single non-blocking `/effort max` reminder. Do not wait for a reply; proceed directly to Step 1.

### 1. Gather change scope

- If uncommitted changes exist: review `git diff` and `git diff --cached`
- If no uncommitted changes but recent commits on branch: review `git diff main...HEAD` (or the appropriate base branch)
- Show `git diff --stat` summary first

### 2. Launch parallel review agents

Spawn **three subagents in parallel**, each in fresh context with only the diff and relevant files:

| Agent | Focus | Model |
|-------|-------|-------|
| `code-reviewer` | Logic errors, error handling, code patterns, AC compliance | opus |
| `security-reviewer` | Injection, auth, secrets, data handling, CSRF/CORS | opus |
| `code-simplifier` | Over-engineering, dead code, unnecessary complexity | sonnet |

Each agent receives:
```
Review the following changes. Only report real issues, not style preferences.

## Changed Files
{git diff --stat}

## Diff
{git diff}
```

### 3. Synthesize findings

Merge results from all agents, deduplicate, and categorize:

- 🔴 **Critical** — must fix before push (any agent)
- 🟡 **Important** — should fix (any agent)
- 🔵 **Simplification** — from code-simplifier only

Group findings by file, not by agent or category.

For each finding provide:
- File and line reference (`file_path:line_number`)
- Which agent found it (code/security/simplifier)
- What's wrong (one sentence)
- Suggested fix (code snippet or description)

### 4. Proto scope check (if applicable)

If proto schemas were updated, verify only feature-relevant proto files are included. Unscoped proto recompiles often introduce TS errors in unrelated pages.

### 5. Verdict

- ✅ "No critical issues — safe to push." — if no 🔴 findings
- ⛔ "There are N critical issues — recommend fixing before pushing." — if 🔴 findings exist

## Output Rules

- Do NOT review code you wrote in the same conversation context. If all changes are from this session, suggest: "Recommend using a new session or subagent for review to avoid reviewing your own work."
- Keep output concise. Don't explain obvious things.
- If all three agents report PASS with no findings: "All three reviewers found no issues — safe to push."
