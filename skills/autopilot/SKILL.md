---
name: autopilot
description: Automated execution mode. Triggers when the user expresses "start doing it", "go", "auto run", "autopilot", "start implementing", or similar. Prerequisite: must have a confirmed plan and spec.
---

# Autopilot — Automatic Build-Review-Fix Loop

## Prerequisites

- Must have a confirmed plan (including subtask breakdown and ACs)
- If no plan exists, remind the user to run `/plan` first

## Startup Confirmation

```
Autopilot starting

  Plan: {plan name}
  Steps: {N} subtasks
  Mode: {conservative|rapid}

  I will automatically execute: builder → critic → fix (up to 2 rounds) → commit → next step
  I will stop and ask you in the following situations:
    - Critic fails 2 consecutive rounds
    - An architectural decision is required
    - A step requires manual testing from you
    - Context usage is too high (recommend compact)

  Start?
```

Wait for user confirmation before starting.

## Execution Loop

For each step in plan:

### Phase 1: Build
- Dispatch `task-executor` subagent to implement
- Pass: subtask description, ACs, scope, test spec, **Pattern Compliance (including Lint Assertions and Deviations)**

### Phase 2: Critic
- Dispatch `critic` subagent to review (fresh context)
- Pass: ACs + git diff + test results + **Pattern Compliance (including Lint Assertions and Deviations)**

### Phase 3: Result Branch

**Critic PASS:**
1. Commit (via git-commit skill)
2. JIRA sync reminder (jira-sync trigger point 3)
3. Output:
```
✅ Step {N}/{total} complete
  AC: {M}/{M} passed
  Critic: PASS
  Commit: {hash}
  → Continuing to Step {N+1}
```
4. Proceed to next step

**Critic FAIL (round 1):**
1. Convert critic findings to a correction subtask
2. Dispatch task-executor to correct
3. Re-dispatch critic
4. Output:
```
🔄 Step {N} correcting (round 1)
  Issue: {critic findings summary}
  → Re-reviewing after correction
```

**Critic FAIL (round 2):**
1. Stop and output full problem description
2. Wait for user intervention:
```
⛔ Step {N} has not passed after 2 consecutive correction rounds

  Critic findings:
    {detailed list}

  Options:
    a) You intervene and adjust, then I continue
    b) Return to /plan to re-break this step
    c) Skip this step and do the next one
```

### Phase 4: Context Management

After completing each step, check context usage:
- **< 50%** → continue
- **50-70%** → remind: "Context at {X}%, recommend completing the current step then /session + /clear before continuing"
- **> 70%** → force stop:
```
⚠️ Context at {X}%, cleanup needed

  Completed: Steps 1-{N} (all committed)
  Remaining: Steps {N+1}-{total}

  Please run:
    1. /session (extract knowledge)
    2. /clear
    3. Come back and say "continue autopilot" — I'll resume from Step {N+1}
```

## Completion

After all steps are complete:

```
Autopilot complete

  Completed: {N}/{N} steps
  Commits: {list hash + message}
  Correction rounds: {stats}

  Recommended:
    1. /review (full review before pushing)
    2. /session (record this session's knowledge)
```

If there is a JIRA ticket, trigger jira-sync trigger point 4 (all subtasks complete → main task In Review).

## Resuming

When the user says "continue autopilot", "keep going", or "resume" after /clear:
1. Read the latest session note
2. Confirm completed steps (from commit history)
3. Continue from the next incomplete step
