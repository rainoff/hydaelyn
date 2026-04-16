# Development Workflow (Always Follow)

## Environment

<!-- Adjust for your system: Python command (python3 / py), shell (bash / zsh) -->

- Response language: English

## Task Startup

- Start every task in Plan Mode. Do not write code until the plan is approved.
- If the user's task description is fewer than 3 sentences, ask 2-3 clarifying questions before planning.
- When the user gives a vague instruction ("fix this", "make it better"), clarify the specific goal first.

## Effort Modes

Two levels:
- **`high`** (default) — general implementation, refactoring, routine operations
- **`max`** — deep reasoning required:
  - **Planning** — architecture decisions, system design
  - **Debugging** — root cause analysis, anomaly tracing (judge by semantics, not keyword lists)
  - **Reviewing** — code review, pre-push checks

### Switching

When the current task enters any of the above scenarios, emit a one-line non-blocking reminder: "Suggest `/effort max`". Do not wait for confirmation — if the user continues with their task, treat it as skip.

`/plan` and `/review` skill Effort Check steps follow this definition — do not duplicate the rules.

## Commit Discipline

- Commit after each logical step (DB layer, API, frontend — separately).
- Commit message format follows project skill conventions (default: Commitizen).
- If the project has a git-commit skill, always commit through it.
- Commit immediately after tests pass on large changes — avoid accumulating unpushed changes.
- Do not push unless the user requests it.

## Testing

- Prioritize testability in each batch of work.
- Automated tests run first; manual tests listed with clear steps.
- Default to TDD for tasks with deterministic logic: write tests first → confirm they fail → implement → confirm they pass.
- TDD is not required for exploratory work, UI prototyping, or one-off scripts.

## Quality

- Do not review code you just wrote in the same context. Suggest using a subagent or new session.
- For core business logic changes, explain each modification and wait for confirmation.
- If stuck on the same error 3+ times, stop and suggest: "/clear and restart with a better approach."

## No Over-Engineering

- Only make changes that are directly requested or clearly necessary.
- Do not add unnecessary docstrings, comments, or type annotations.
- Three similar lines of code is better than a premature abstraction.

## Task Completion

- After finishing a task, remind: "Run /review before pushing."
- Then suggest /clear before starting the next task.
- Before /clear, write a /session handoff so the next session can pick up seamlessly.

## Context Management

- Use @ file references instead of pasting file contents.
- Prefer reading files with tools rather than asking the user to copy content in.
- **Context health monitoring** (mandatory, do not skip):
  - After receiving a compaction notification → immediately write /session, then suggest /clear.
  - There is no reliable way to know exact context usage percentage. Do not fabricate numbers. When in doubt, warn early rather than late.
  - Long sessions degrade output quality (reasoning loops, shortcuts, losing track of the plan). Proactive /clear is the most effective defense.
- **User checkpoint requests are non-deferrable** (mandatory): When the user requests /session, /clear, "record this", "pause", "wait" → execute immediately. Never respond with "let me finish Step N first." **Why**: Deferring checkpoints is the primary cause of context overflow — when the user decides to pause, AI rationalization must not override that decision.
- **Post-Compact Recovery**: If `~/.claude/.compact-marker` exists, immediately read it to understand pre-compaction state, write a brief session note, then delete the marker. This takes priority over the user's next instruction.
