---
description: Memory cleanup and archiving. Run periodically to keep memory lean.
---

# Memory Housekeeping

Clean up, archive, and consolidate memory to keep the three-temperature system healthy.

## 1. Hot Memory Check

Read MEMORY.md and check:
- [ ] Exceeds 50 lines? → Push details down to Warm; Hot keeps only pointers
- [ ] Any links pointing to non-existent files? → Remove them
- [ ] Are the module descriptions in the knowledge map still accurate? → Update them

## 2. Warm Memory Scan

For each .md file under `memory/`:

a. **Frontmatter check** — Does the file have a YAML frontmatter with a `description` field? If not, add one
b. **Expiry check** — Based on the rules, determine if it should be archived to Glacier:

| Type | Archive condition |
|------|---------|
| Plan | All ACs complete and committed |
| Decision | Superseded by a new decision |
| Feedback | Written into a global rule |
| Project status | Not updated in over 30 days |
| Bug/issue | Fixed and has a regression test |

c. **Merge check** — Are there multiple files describing the same topic? → Merge into one
d. **Accuracy check** — Do the referenced file paths, function names, API endpoints still exist? → Flag outdated ones

## 2.5. System Spec Scan

For all system specs (in-repo `openspec/specs/` + private `specs/system/`):

a. **Expiry check** — `last_verified` > 30 days → flag as needing update
b. **Orphan check** — the directory/file referenced by `scope` no longer exists → flag as orphan
c. **Duplication check** — spec and memory both contain overlapping structural descriptions → suggest migrating to spec

## 3. Glacier Archiving

For files marked for archiving in Step 2:
1. Add `archived: true` and `archived_date: {date}` to the YAML frontmatter
2. Remove the pointer from MEMORY.md

If `memory/archive/` does not exist, create it along with `index.md`.

## 4. Session Directory Cleanup

Scan the `sessions/` directory:
- Session notes older than 30 days → remind the user whether to archive or delete
- Do not auto-delete; list them for the user to decide

## 5. UUID Session Cache Cleanup

Scan UUID folders under the project directory (Claude Code session cache):
- List each folder's size
- Folders older than 30 days → suggest compressing/archiving or deleting
- Do not auto-delete; list them for the user to decide

## 6. Auto Dream Integration (reserved)

When the `/dream` command becomes available:
- Run `/dream` before starting housekeeping
- Dream processes Hot memory first; housekeeping then handles Warm and Glacier

## Output

```
Memory Housekeeping complete

Hot Memory:
  Lines: {N}/50
  {what was fixed, or "status normal"}

Warm Memory:
  Total files: {N}
  Frontmatter updated: {N}
  Archived to Glacier: {N} ({list})
  Merged: {N} groups ({list})
  Outdated flagged: {N} ({list})

System Specs:
  Total specs: {N}
  Expired (>30 days): {N} ({list})
  Orphaned: {N} ({list})

Session Cache:
  Cleanable: {N} UUID directories, total {size}
  (list items recommended for cleanup, await user confirmation)
```
