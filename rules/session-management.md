# Session Management Rules

## Auto-Writing Session Notes

Only write a session note at these moments (path: `~/.claude/projects/{project}/sessions/{date}.md`; **in a worktree, write to the parent** — see `worktree-memory.md`):

1. **User explicitly requests it** (/session or says "done", "stop here", "talk tomorrow") — write a complete handoff
2. **After a commit — session writeback** (do both together):
   - Append one line `- ✅ {hash} {message}` to the "Completed" section of that day's session note (if the file already exists)
   - Check the previous session note's "Next Up" section: if this commit completes one of the pending items, go back and change that item from `[ ]` to `[x]` with the commit hash

Do not proactively write session notes at any other time.

## Session Note Format

```markdown
# Session: {date}

## Completed
- ✅ {commit hash} {commit message}
- ⚠️ {uncommitted} {description of completed but uncommitted work}

> Every completed item must be marked ✅ (committed) or ⚠️ (not committed). Uncommitted work should be prioritized at the start of the next session.

## Key Decisions (if any)
- {only record decisions that will affect judgment next time}

## Next Up
- [ ] {specific next step}
```

## Starting a New Session

At the start of every new conversation, if the user asks "where did we leave off", "what's next", "continue", or similar:

1. First read the current project's `sessions/` and `memory/MEMORY.md`
2. **Worktree awareness**: if the project key contains `-worktrees-`, resolve the parent project key (take everything before `-worktrees-`) and read from the parent's `memory/` and `sessions/`. See `worktree-memory.md`
3. **If the path is not found, use `glob **/MEMORY.md` and `glob **/sessions/**/*.md` to search down from `~/.claude/projects/`**
4. Never declare "no records" after trying only one path — the project key provided by the system may differ from the actual directory name
5. Respond based on what is found

### Todo Progress Check

Read the "Next Up" section of the most recent session note; if there are unchecked todo items (`- [ ]`) that are more than 3 days old:
- List these items and ask the user: "These todos were left from last time — which ones have been completed?"
- After the user responds, update the session note (check off completed items) and sync relevant memory

**Why:** Completed todos that are never marked done are the most common source of memory staleness. Asking once proactively costs far less than correcting things after an audit.

### MR Convergence Reminder

When "Next Up" contains an open MR or push-related todo that has been unresolved for more than 5 days:
- Proactively remind: "MR todo has been open for more than 5 days. Recommend scope freeze: open the MR with current changes, track newly discovered issues in separate tickets."
- This is a mandatory reminder, not a suggestion — scope creep is the most common cause of MR delays.

### External Pending Items Tracking

Items that require a reply from external parties (designers, PM, backend) before work can proceed should be marked with `⏳` in "Next Up":
```
- ⏳ {item} — waiting for {who} to respond ({date raised})
```
After 7 days with no progress, the session startup reminds the user to make a decision: resolve, defer, or mark wontfix. External pending items must not silently disappear.

### Rules Change Check

At every session startup, read the latest entry date from `~/.claude/CHANGELOG.md` and compare it against the current project's most recent session note date:
- New rule changes exist → notify: "Global rules were updated on {date}: {summary}. Would you like to check if this project's memory needs to be aligned?"
- No new changes → do not notify

## Division of Labor with memory/

- **Session notes**: Short-term handoff (valid for a few days), records "what was done" and "what to do next"
- **memory/**: Long-term knowledge (valid across weeks), records "why things are done this way" and "how the system works"
- Do not maintain a duplicate todo list in both session notes and memory
- Multiple sessions on the same day share the same note (append, do not overwrite) — see format below

### Same-Day Multi-Session Append Format

Use `---` to separate sub-sessions. The entire file must have only **one** "Next Up" section (at the bottom):

- When adding a sub-session, separate with `---`
- New completed items append directly below the separator (no need to repeat the `## Completed` heading)
- New key decisions append to the **existing** "Key Decisions" section (do not open a new one)
- Completed items from the old "Next Up" are checked off and removed; remaining items are merged into the latest "Next Up"
- There is exactly one "Next Up" section at the bottom of the file at all times
