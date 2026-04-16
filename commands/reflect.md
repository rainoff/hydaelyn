---
description: Review recent sessions, detect patterns and rule violations, and propose improvements
---

# Reflect — Self-Reflection

Review recent session diaries and memory changes to identify patterns that can be improved.

## 1. Gather Materials

Read the most recent 5 session notes from `sessions/` (or a user-specified range).
Read recently added/modified files from memory.

### Visual Snapshot (when Playwright is available)

If the project has `playwright.config.ts` and a screenshot spec (e.g., `e2e/screenshots.spec.ts`):
1. Run `npx playwright test e2e/screenshots.spec.ts` to generate screenshots
2. View each screenshot using the Read tool
3. Add the **Visual Issues** dimension to the analysis (see below)

This allows reflect to review actual rendered results, not just code.

## 2. Analysis Dimensions

### Rule Violations (highest priority)
- Scan session records for any behavior that violated CLAUDE.md or rules/
- Examples: skipping Context Check, guessing user intent, breaking pattern consistency
- For each violation, record: which rule, what context, what consequence

### Recurring Patterns
- Same type of problem appearing 2+ times → pattern
- Same type of problem appearing 3+ times → strong pattern; must be addressed
- Categories: debugging strategies, architectural decisions, communication style, tool usage

### Successful Approaches
- Which approaches worked well and were recognized by the user?
- Are these approaches already recorded in rules or memory?

### Visual Issues (when screenshots are available)
- Text readability: which screens have insufficient contrast between text and background?
- Style consistency: which screens are stylistically inconsistent with others?
- Layout issues: element alignment, spacing, overflow, etc.
- For each issue, record: which screenshot, which area, specific description

### Knowledge Gaps
- When did lack of information cause the AI to be inefficient?
- Where should this information live (memory? docs? CLAUDE.md?)

## 3. Output

```
Reflection (covering {date range}, {N} sessions)

Rule Violations:
  {N} found
  - {rule} — {context} — {suggested strengthening}

Recurring Patterns:
  {N} patterns
  - {pattern description} — appeared {N} times — {suggested handling}

Successful Approaches:
  - {approach} — recorded: {yes/no}

Knowledge Gaps:
  - {missing information} — suggested location: {location}

Visual Issues (when screenshots available):
  {N} found
  - [{screenshot name}] {area} — {problem description}

Skill Gotchas (auto-writeback suggestions):
  - {skill name} — {failure pattern description}

Items recommended for /evolve:
  1. {most important improvement}
  2. {secondary improvement}
```

## 3. Skill Gotchas Writeback

If analysis identifies the same failure pattern appearing repeatedly in a skill/command/agent:
1. Find the corresponding skill/command file
2. Suggest adding or updating a `## Gotchas` section at the end of the file
3. Format: `- {failure scenario} → {correct approach}`
4. Add to /evolve queue (do not modify directly in reflect)

This allows each skill to accumulate its own failure experience over time, so the AI can see and avoid them when triggered next time.

## Gotchas

- Playwright screenshots may capture the wrong state due to residual localStorage → screenshot spec's `beforeEach` must include `localStorage.clear()` + `page.reload()`
- Phaser canvas screenshots require sufficient load time (at least 3 seconds) — otherwise the screenshot may capture a blank or loading screen

## Notes

- Reflect only analyzes and suggests — it does not modify any files
- Rule changes and Gotchas writebacks are handled by /evolve (requires user confirmation)
- If no significant findings are discovered, output: "Recent performance stable, no adjustments needed"
