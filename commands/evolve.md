---
description: Based on /reflect output, modify rules and CLAUDE.md to improve AI behavior
---

# Evolve — Rules Evolution

Based on analysis results from /reflect, propose and execute rule modifications.

## Prerequisites

- Must have run `/reflect` first (or the user has provided specific improvement requirements)
- All modifications require user confirmation before execution

## 1. Read Reflect Output

From the most recent /reflect results, extract:
- Rule violations → rules that need to be strengthened
- Recurring patterns → rules that need to be added
- Knowledge gaps → documentation/memory that needs to be supplemented

## 2. Propose Modification Plan

For each item that needs to be addressed, propose specific changes:

```
Evolve plan (based on reflect from {date})

{N} modifications:

1. [Strengthen] rules/{file}.md
   Reason: {rule violation description}
   Change: {specific diff}

2. [Add] rules/{file}.md
   Reason: {recurring pattern description}
   Rule: {new rule content}

3. [Update] memory/{file}.md
   Reason: {knowledge gap description}
   Content: {what to add}

Confirm to execute? (can confirm item by item or all at once)
```

## 3. Execute Modifications

After user confirms:
- Modify the corresponding rules/ files
- If it involves core principles in CLAUDE.md → flag specifically; requires explicit user agreement
- Update memory if needed
- Commit the changes

## 4. Record

After modifications are complete, write to the evolve log:
- Store in `memory/evolve-log.md` (append-only)
- Format: `- {date}: {change summary} — reason: {trigger}`

## Rules

- **Never auto-modify CLAUDE.md** — changes to core principles require the user to confirm each item
- **rules/ changes can be batch-confirmed** — but must list the complete diff
- **Only change rules, not memory contents** — memory maintenance is handled by /session and /housekeeping
- **Do not delete rules, only strengthen or add** — deleting rules requires explicit user request
