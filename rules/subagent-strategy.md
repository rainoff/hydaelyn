# Subagent Delegation Strategy

> Choosing the right mode matters more than choosing the right agent.

## Three Execution Modes

| Mode | Isolation | Context sharing | When to use |
|------|---------|-------------|---------|
| **Fork** | Fully independent | None | Independent research, parallel searches, tasks that don't need to know each other's results |
| **Worktree** | Git-isolated | None | Parallel development that requires file modifications but may conflict |
| **Teammate** | No isolation | Shared | Tasks that need to know each other's progress and collaborate to completion |

## Worktree Mode: Memory Injection

When spawning a worktree agent, the main session must inject parent project information into the prompt (path, memory location, branch name), otherwise the agent will start from an empty worktree project directory with no memory at all.

Resolution rules and prompt template are in `worktree-memory.md`.

## When to Delegate vs. Do It Yourself

**Delegate to subagent**:
- Task is independent and doesn't need the result to decide the next step → Fork (background execution)
- Needs to modify code but may conflict with main branch → Worktree
- Needs adversarial review (critic, alignment-checker) → Fork (fresh context, eliminates bias)
- Search/research task exceeds 3 queries → Fork (protect main context)

**Do it yourself**:
- Simple single-file search (use Grep/Glob)
- Operations that need immediate results to continue
- Decisions that require user interaction

## Model Selection

| Agent type | Recommended model | Reason |
|-----------|---------|------|
| task-executor | sonnet | Executes clear instructions without deep reasoning, saves tokens |
| critic / alignment-checker | opus | Requires adversarial thinking and comprehensive review |
| code-reviewer / security-reviewer | sonnet | Structured checking, primarily pattern matching |
| Explore (research) | sonnet | Search-oriented, no deep reasoning needed |
| Plan (planning) | opus | Requires architectural-level thinking |

## Parallelization Principles

- **Independent tasks always run in parallel**: when multiple agents have no dependencies, start them in the same message
- **Research first**: investigate uncertain things with an Explore agent first, then decide next steps based on results
- **Background execution**: agents whose results are not immediately needed use `run_in_background: true`
- **No duplicate work**: if a task is delegated to an agent, the main session should not do it simultaneously

## Available Agent List

| Agent | Purpose | When to trigger |
|-------|------|---------|
| task-executor | Execute a single subtask | After plan breakdown, call for each step |
| critic | Adversarial code review | After task-executor completes, before acceptance |
| alignment-checker | Compare against external reference sources | After UI/API subtask completes |
| code-reviewer | Code quality review | On demand |
| code-simplifier | Simplify and clean up code | After implementation is complete |
| security-reviewer | Security vulnerability review | On demand |
