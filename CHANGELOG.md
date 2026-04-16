# Rules Changelog

> Record one line for every global rule change. At session startup, compare against the most recent session note date and notify the user if there are new entries.

- 2026-04-07: knowledge-index — L0 now uses frontmatter description, Glacier archiving uses archived flag (no file moves), MEMORY.md no longer stores current-state snapshots
- 2026-04-07: session-management — added "todo progress check": at session startup, proactively ask the user about todos unresolved for more than 3 days
- 2026-04-07: web-fetch-safety — added external content safety policy: three-step verification for WebFetch results + MCP installation safety checks
- 2026-04-10: scoped-rules — moved translation-system to project-level, added activation condition to public-repo-sync (only triggers in ~/.claude)
- 2026-04-10: model-quality — switched to 200k model + effort high + showThinkingSummaries + lowered /clear threshold to 40% (response to anthropics/claude-code#42796 analysis)
- 2026-04-10: session-management — added cross-session todo writeback rule + PostToolUse hook to detect commits and remind about writeback
- 2026-04-10: worktree-memory — added worktree memory strategy (parent resolution, read/write to parent, anti-trampling, subagent injection)
- 2026-04-10: context-compact — PreCompact hook upgrade (marker + log), mandatory 40%/60% thresholds, Post-Compact Recovery rule
- 2026-04-10: pattern-consistency — SDD+TDD three-checkpoint Pattern Compliance mechanism (Plan: Pattern Discovery + Constitution + Spec-Test Debate / Build: TDD six-step + pattern awareness / Review: Critic Lint Assertions automation)
- 2026-04-10: figma-workflow — Phase 1 Color Inventory mandatory full audit + Phase 3 Refactor mode (cross-section audit)
- 2026-04-10: visual-ui-workflow — decorative image positioning Gotcha (stop on first failure and ask)
- 2026-04-10: session-management — MR convergence reminder (5-day threshold) + external pending items ⏳ tracking (7-day reminder)
- 2026-04-10: session-management — same-day multi-session append format: single "Next Up" section, merge key decisions, use --- separator
- 2026-04-10: figma-workflow — Gotcha: CSS transform direction is a common AI mistake; provide options rather than implementing directly
- 2026-04-10: public-repo-sync — added sync frequency recommendation (weekly batch preferred over per-commit sync)
- 2026-04-13: effort-modes — defined high/max two levels × Planning/Debugging/Reviewing three scenarios; plan/review skill references single definition to avoid duplicated copy; non-blocking reminder avoids friction on every call (why: reviewer identified three duplications + fragile keyword list + ambiguous blocking skip semantics)
- 2026-04-13: dev-workflow — user checkpoint is non-deferrable rule (why: real case where AI deferred "record session" to after Step N, context exploded in between; deferral = prohibited)
- 2026-04-15: sdd — added Spec-Driven Development rule (System Spec as-is + Change Spec to-be, incremental non-blocking, OpenSpec compatible, integrated with plan/session/housekeeping/project-init)
- 2026-04-15: sdd-review — fixed session.md 2d/2e ordering bug, aligned L0→frontmatter, added last_verified update timing (verification-loop + sdd), added change spec archiving trigger, clarified Patterns vs Constitution boundary
