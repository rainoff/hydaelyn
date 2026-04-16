---
description: Write a session progress snapshot + extract knowledge + update memory
---

Write a handoff snapshot for the current session and extract reusable knowledge from this conversation.

## Phase 1: Session Note

1. Check this session's commits:
$SHELL git log --oneline --since="today"

2. Write to `~/.claude/projects/{project}/sessions/{today}.md`, format:

```markdown
# Session: {date}

## Completed
- {commit hash} {commit message}
- {important non-commit operations, e.g., DB writes, deployments}

## Key Decisions (if any)
- {why A was chosen over B — only record decisions that will affect judgment next time}

## Next Up
- [ ] {most important next step}
- [ ] {other todos}
```

3. If a session note for the same day already exists, **append** to the existing file (add `---` separator)

## Phase 2: Knowledge Extraction

Review the full conversation for this session and execute the following extractions:

### 2a. Pattern Detection

Scan the conversation for recurring behavior patterns:
- **Appears 2+ times** = pattern → consider storing in memory
- **Appears 3+ times** = strong pattern → must store in memory or rules
- **Behavior that violates existing CLAUDE.md/rules** → highest priority; strengthen the corresponding rule

### 2b. Project Knowledge (store in Warm memory)

- **Architectural discoveries** — dependencies between modules, call chains, data flows
- **Design decisions** — why A was chosen over B, what factors were considered
- **Pitfalls encountered** — why things got stuck, the solution, how to avoid recurrence
- **Module changes** — modified a module's behavior → update the MEMORY.md knowledge map

When writing to memory:
1. Ensure the YAML frontmatter includes a `description` field (one-line summary)
2. Update the corresponding module pointer in MEMORY.md
3. Ensure MEMORY.md does not exceed 50 lines

### 2c. Universal Wisdom (store globally)

Lessons applicable across projects:
- Tool/framework usage pitfalls
- Design pattern pros and cons
- AI behavior improvements (feedback)

Store in global memory or update `~/.claude/rules/`.

### 2d. Extraction Criteria

**Extract:**
- Knowledge that will change future AI behavior
- Cause-and-effect relationships (not just facts)
- Decisions with scope affecting more than 1 subtask

**Do not extract:**
- Pure code change records (git log already has these)
- One-off debugging (unless it reveals a systemic issue)
- Information already in memory (avoid duplication)

### 2e. System Spec Update Check

Did this session modify a module's public interface or internal structure?

- **Modified Public API** → flag in "Next Up": "⚡ {module} system spec needs updating (API change)"
- **Modified Internal Structure** → flag: "📋 {module} system spec update recommended"
- Do not modify the spec directly during /session — only flag it

## Phase 3: Memory Health Check

### 3a. Hot Memory (MEMORY.md)
- Line count ≤ 50? If over → push details to Warm
- Do pointers point to existing files? If broken → remove
- Are module descriptions still accurate? → Update

### 3b. Warm Memory Quick Scan
- Did this session's changes make any memory entry **outdated**? → Update or flag for archiving
- Do multiple memory entries describe the same topic? → Consider merging
- Are there memory entries missing a frontmatter `description` field? → Add one

### 3c. Archive Reminders
- If memory meeting archive conditions is found (plan complete, decision superseded, etc.) → remind to archive
- Do not auto-archive in /session — leave that to /housekeeping

## Phase 4: Lightweight Reflect (auto-execute)

Only analyze behavior from **the current session** (no historical review — that's the full `/reflect`'s job).

### Scan items
- **Rule violations** — did this session's behavior violate CLAUDE.md or rules/?
- **Runtime issues** — were there bugs that static checks missed and the user discovered manually?
- **Skipped steps** — were context check, critic, alignment check, or other steps skipped?

### Output rules
- Findings exist → list findings and suggest whether `/evolve` is needed
- No findings → one line: "This session's workflow was normal"
- **Does not block session completion** — reflect results are appended to the output and do not affect handoff writing

## Output

```
Session snapshot written: {path}

Knowledge extracted:
  - {what memory was added/updated, one per line}
  - or "No new knowledge to extract this session"

Pattern detection:
  - {patterns found and how they were handled}
  - or "No significant patterns"

Memory health:
  Hot: {N}/50 lines
  {updates/outdated flags/archive reminders}
  or "All memory status normal"

Session Reflect:
  - {findings list}
  - or "This session's workflow was normal"
  - {if findings} Suggest running /evolve for: {items}
```
