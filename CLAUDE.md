# Execution Mode

Check the project's CLAUDE.md for `mode:` setting. Default is `conservative`.

- **`mode: conservative`** — Existing projects. All principles enforced. Pattern consistency is mandatory.
- **`mode: rapid`** — New projects / fast iteration. Principle #3 (pattern consistency) is relaxed. Speed > consistency. Still must follow #1 (never assume) and #2 (context check, but "Existing patterns" field is optional). **Minimum safety net still applies:** after each subtask, run `build` + `test` (if exists) + scan for known runtime pitfalls (see `agents/critic.md` checklist). No full critic review required, but runtime verification is non-negotiable.

# First Principles

<important>
## 1. Never assume — ask or look up.

If the information is not in the plan, spec, memory, or session:
- **Can I find it myself?** → Read MEMORY.md → locate module → read related memory files
- **Can't find it?** → ASK the user. Do not guess.

Do not guess implementation details, business logic, or user intent. Ever.
</important>

<important>
## 2. Context check before every action.

Before writing or modifying ANY code, output this block:

```
Context Check:
- Modules involved: {list}
- Memory read: {which files, or "none needed" with reason}
- Existing patterns: {how similar code is written in this project — cite file:line}
- System specs: {present/missing — cite path or "none — will explore"}
- Upstream/downstream: {what calls this, what breaks if changed}
- Unsure about: {list, or "nothing — proceeding"}
```

**"Existing patterns" is mandatory in conservative mode.** You must find and cite at least one existing example of similar code in the project before writing new code. If no similar code exists, state that explicitly and explain what convention you will follow.

If "Unsure about" is empty, double-check — that usually means you skipped the thinking.
If you cannot fill in "Modules involved", you have not read the knowledge map yet. Stop and read it.
</important>

<important if="mode is conservative">
## 3. Follow existing patterns — consistency over cleverness.

If the project has established code patterns, architectural conventions, or design principles:
- **Follow them exactly**, even if you think there's a "better" way.
- Do NOT introduce new patterns, abstractions, or conventions without explicit user approval.
- When unsure if a pattern exists, search the codebase first. Match what's already there.
- Consistency enables maintainability. A "better" approach that breaks consistency is worse.
</important>

## 4. Context compaction preferences

When the harness performs context compaction, preserve information in this priority order:

**Must preserve** (compaction must not remove):
- Current plan and spec AC list
- User's recent instructions and decisions
- Incomplete task state
- File paths and change intentions currently being modified

**Prefer to preserve**:
- Memory file contents (loaded Warm memory)
- Test results (pass/fail)
- Git diff summaries

**Can truncate**:
- Long tool output (logs, large grep results) — keep first 50 lines + summary
- Detailed process of completed steps (keep conclusions only)
- Duplicate reads of the same file's old versions

**Can remove**:
- Exploratory search results (once target is found, search process can be discarded)
- Discussions of rejected approaches

## 5. Decide correctly: ask / look up / act.

| Situation | Action |
|-----------|--------|
| Info exists in memory/docs | Read it yourself. Do NOT ask the user. |
| Info does not exist anywhere | ASK the user. Do NOT guess. |
| Info might be outdated | Verify current state first, then act. |
| Ambiguous requirement | ASK the user. One question beats one wrong move. |
| Clear requirement + context loaded | Act. No need to ask. |
