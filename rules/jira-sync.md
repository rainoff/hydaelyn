# JIRA Sync — Progress Synchronization Rules

> Let PMs see progress directly on the Gantt chart without interrupting engineers' focus.

## Prerequisites

- JIRA MCP server must be configured and available
- Every development task should have a corresponding JIRA ticket
- All operations follow the pattern: "prompt → user confirms → execute" — never auto-update JIRA

## Project Configuration (CLAUDE.md)

Each project's CLAUDE.md should contain a JIRA section with only infrequently-changing default values:

```yaml
## JIRA
- default_type: FT-Task
- team: Frontend  # example — replace with your team name
```

**Not stored in config** (ask dynamically at each `/plan`):
- Project key (varies by requester)
- Parent ticket

If the project's CLAUDE.md has no JIRA section, collect all necessary information before acting when sync is triggered.

## JIRA Field Reference

| Purpose | Field | JIRA field (replace with yours) |
|------|------|------------|
| Team | Project default | `customfield_XXXXX` |
| Approver | — | `customfield_XXXXX` |
| Start date | start date | `customfield_XXXXX` |
| Target end | target end | `customfield_XXXXX` |

> Field IDs vary by JIRA instance. Use `GET /rest/api/3/field` to discover yours.

## Status Flow

**Different projects/types have different workflows — do not hard-code transition names.**

Before each status transition, query available transitions using `GET /issue/{key}/transitions`, then match the target state.

Known examples (replace with your actual JIRA workflow labels):
- PROJ-A FT-Task: `Todo` →(transition A)→ `In Progress` →(transition B)→ `In Review` → `FINISH`
- PROJ-B large work: `Todo` → `In Progress` →(transition C)→ `FINISH` (no In Review)

**Rule: Move toward FINISH as far as possible. If there is an In Review state in between, transition twice; otherwise go directly.**

## Default Values (overridable by user)

- **Issue type**: `FT-Task` (user can specify `Story` or other types)
- **Team**: `Frontend` (example — replace with your team name)
- **Approvers**: not set for subtasks (main task determined by user)

## Four Sync Trigger Points

### Trigger 0: Before Plan Starts → Collect JIRA Info

**When:** When the user starts `/plan`, before any planning

**Claude Code behavior:**
```
JIRA info check:
  Project key: ? (e.g., PROJ-A, PROJ-B, PROJ-C)
  Parent ticket: ? (e.g., PROJ-A-38)
  Task type: {default_type from CLAUDE.md} (press Enter for default, or type to override)
```

After user responds, store these three values in the current session context for use by subsequent trigger points.

### Trigger 1: Before Plan Starts → Move Main Task to In Progress

**When:** After Trigger 0 has collected all info

**Claude Code behavior:**
```
Update main task status first?
  ticket: {parent ticket}
  status: Todo → In Progress
  start date: {today}

Confirm?
```

**JIRA operations:**
- Query available transitions, find the transition targeting "In Progress"
- Execute transition
- Set `customfield_10015` (start date) to today

### Trigger 2: Plan Complete → Create Subtasks + Schedule

**When:** After `/plan` command finishes task breakdown

**Claude Code behavior:**
```
Plan complete, broken into {N} steps.

Create corresponding subtasks in JIRA?
  Parent ticket: {collected in Trigger 0}
  Type: {collected in Trigger 0}
  Will create:
    1. {subtask title} — AC: {M} items, estimated {start} ~ {end}
    2. {subtask title} — AC: {M} items, estimated {start} ~ {end}
    3. {subtask title} — AC: {M} items, estimated {start} ~ {end}

Confirm? (you can adjust dates or type before confirming)
```

**JIRA operations:**
- Create subtask under parent ticket
  - project: project key collected in Trigger 0
  - type: task type collected in Trigger 0
  - description: includes AC list
  - assignee: current user
  - Team (`customfield_10001`): team default value from CLAUDE.md
  - Start date (`customfield_10015`): per schedule
  - Target end (`customfield_10023`): per schedule
  - **Do not set Approvers** (`customfield_10003`)
- Status remains `Todo`

**Scheduling logic:**
- First subtask start date = today
- Subsequent subtask start date = the day after the previous subtask's target end
- Duration per subtask estimated from AC count and complexity (provide suggestion, user can adjust)

### Trigger 3: Subtask Acceptance Passed → Advance toward FINISH

**When:** After the main session accepts a step (all ACs ✅, tests green)

**Claude Code behavior:**
1. Query currently available transitions for that subtask
2. Find the path toward FINISH and display to user:

```
✅ Step {N} accepted.

Update JIRA?
  ticket: {PROJ-SUB-XXX}
  operation: {current} →(transition A)→ {intermediate state} →(transition B)→ FINISH
  comment: "AC 1-{M} all passed, tests green. commit: {hash}"

Confirm?
```

If the workflow can reach FINISH in one step, display one step.

**JIRA operations:**
- Query available transitions, transition step by step until FINISH
- Re-query available transitions after each step before proceeding
- Add a comment containing passed ACs and commit hash
- Check if all subtasks are FINISH → if so, trigger Trigger 4

### Trigger 4: All Subtasks Complete → Move Main Task to In Review

**When:** After the last subtask transitions to FINISH

**Claude Code behavior:**
```
All subtasks complete!

Update main task?
  ticket: {PROJ-XXX}
  status: In Progress → In Review
  comment: "All {N} subtasks complete, ready for code review."

Confirm? Further steps are handled manually.
```

**JIRA operations:**
- Query main task available transitions, find the transition toward "In Review"
- If the project has no "In Review" state, notify user to choose target state (may go directly to FINISH)
- Add comment
- **Stop here** — subsequent steps are handled manually by the user

## When Not to Trigger Sync

- User explicitly says "no need to sync" or "no ticket"
- Hotfix (speed first, update after)
- Pure documentation updates (README, CHANGELOG)
- `.claude` config file changes

## Error Handling

If JIRA MCP is unavailable:
- **Do not block the development workflow**
- Record pending sync items to session note
- Remind: "JIRA MCP is currently unavailable. Pending sync items have been noted and can be updated manually later."

If a transition fails (e.g., wrong status name):
- Display the error message and currently available transitions
- Let the user choose the correct transition name
