# Knowledge Index — Three-Temperature Memory System

> AI should not be clueless about things it's already been told. Everything that's been shared must be quickly findable.

## Three-Temperature Architecture

```
Hot    → MEMORY.md (always loaded, <50 lines, knowledge map + pointers)
Warm   → memory/*.md (loaded on demand, read after locating the relevant module per task)
Glacier → memory/archive/ (completed/expired, indexed but not proactively loaded)
```

### Hot Memory (MEMORY.md)

- Always loaded; auto-read at the start of every session
- **Hard limit: 50 lines** — anything beyond that must be pushed down to Warm
- Store only pointers and summaries, not details
- Freely editable (not append-only)
- Format: a knowledge map organized by module (see below)

### Warm Memory (memory/*.md)

- Loaded on demand — only read files relevant to the modules involved in the current task
- Every file must have YAML frontmatter (including name, description, type); `description` serves as the quick-scan summary
- Feedback type: append-only (add entries, do not delete; archive expired entries to Glacier)
- Reference type: can be directly edited and updated
- Project type: archive to Glacier when complete

### Glacier (Archived Warm Memory)

- Completed plans, resolved issues, superseded decisions
- **Archiving method**: Add `archived: true` + `archived_date` to the file's frontmatter; do not move the file
- Remove the pointer from MEMORY.md
- When scanning, use `grep -L 'archived: true' memory/` to filter out archived files
- To retrieve from Glacier, simply remove the archived flag

## Quick Scan Protocol

Use the frontmatter `description` field as the quick-scan summary (replaces the old L0 HTML comment approach).

### Read decision flow

1. **Description scan** — `grep 'description:' memory/` to get one-line summaries of all files
2. **Relevance judgment** — based on task description, decide which files are relevant
3. **L1 section scan** — for relevant files >80 lines, scan section headers first
4. **L2 full read** — read the full file only after confirming it's needed

Hot memory always goes directly to L2 (it's designed to be very small).

## MEMORY.md Format (Hot Memory)

```markdown
## System Map

### {Module Name}
- Responsibility: {one sentence}
- Warm: [file1](...), [file2](...)
- Docs: `path/to/doc`

## Feedback
- [feedback-xxx](...) — {one line}

## Reference
- [reference-xxx](...) — {one line}

## In Progress
- [plans/xxx](...) — {status}
```

**Note**: MEMORY.md does not store current-state snapshots (progress numbers, deployment status, or other easily outdated information). Progress is carried by session notes; system capability descriptions belong in the corresponding Warm memory files.

## Archiving Trigger Conditions

| Type | When to archive to Glacier |
|------|-------------------|
| Plan | All ACs complete and committed |
| Decision | Superseded by a new decision |
| Feedback | Written into a global rule (no longer needs a memory reminder) |
| Project status | Not updated in over 30 days |
| Bug/issue | Fixed and has a regression test |

Archiving (2 steps):
1. Add `archived: true` + `archived_date: {date}` to the file's frontmatter
2. Remove the pointer from MEMORY.md

## Auto Dream Compatibility

Once Claude Code's native Auto Dream feature is available, the three-temperature system should coexist with it:
- Auto Dream handles automatic merging, deduplication, and conflict resolution
- The three-temperature system handles tiering and archiving
- No conflict: Auto Dream operates on MEMORY.md (Hot); the three-temperature system manages the entire memory/ directory
- When `/dream` is available, add it to the `/housekeeping` workflow

## Document Placement Guidelines

When the user has documents to index for the AI:

| Type | Recommended location |
|------|---------|
| System architecture, module relationships | `docs/architecture/` |
| Deployment processes, environment config | `docs/ops/` |
| Business rules, product specs | `docs/business/` |
| Third-party service config | `docs/integrations/` |

Or tell the AI directly and it will store them in memory.

## AI Behavior Rules

### Starting a new session
0. **Worktree resolution**: if the project key contains `-worktrees-`, resolve the parent project key (take everything before `-worktrees-`) and read from the parent's `memory/` for all subsequent steps. See `worktree-memory.md`
1. Read MEMORY.md (Hot) — get the system map
2. Based on the user's task description, locate the relevant modules
3. Use frontmatter descriptions to scan and determine which Warm memory files to read
4. Read only the relevant Warm memory files (not all of them)

### When receiving a task
1. First locate which modules are involved from the Hot knowledge map
2. Read relevant Warm memory progressively: Description → L1 → L2
3. If the map does not cover the area → only then use grep/glob to explore
4. If exploration uncovers valuable knowledge → write it to Warm memory + update Hot pointers

### When a knowledge gap is discovered
```
I notice that {module name} has no record in the knowledge index.
I just learned from the code: {brief description}

Should I store this in memory?
```
