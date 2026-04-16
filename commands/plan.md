---
description: Structured feature development workflow
---

Guide me through building a new feature.

**Before you begin**: Per the Effort Mode in `rules/dev-workflow.md` — if not currently at `max`, emit a single non-blocking `/effort max` reminder. Do not wait for a reply; proceed directly to Step 1.

1. Ask me exactly what I want to build
2. Clarify any ambiguities with 2-3 targeted questions
3. Ask: do I have a ticket ID? (e.g., COIN-75, WEB-71, OP-36)

### 3.2. System Spec Check

Per `rules/sdd.md`, check whether the modules involved have a system spec.

a. **Infer involved modules** — derive from the requirements described in Steps 1–2
b. **Look up system spec by resolution order**:
   - in-repo `openspec/specs/` → private `~/.claude/projects/{key}/specs/system/` → memory fallback
c. **Found → read it** — check `last_verified`; if >30 days, warn that it may need updating
d. **Not found → propose creating one** — user may skip ("not needed this time")
e. **Output Spec Context status table**:
   ```
   System Spec Context:
     {module}: ✅ {path} (verified {date})
     {module}: ❌ No spec — create one now? (skippable)
   ```

> Non-blocking. User may skip without affecting subsequent steps.

### 3.5. Figma Pre-check (UI tickets only)

If the ticket involves UI implementation and a Figma design file exists:

a. **Check if spec already has a Node Map** — read `specs/{ticket-id}.md` and confirm the `## Figma Node Map` section exists
b. **If not → run Phase 0 first** — follow `figma-workflow.md` to execute Phase 0 (explore → screenshots → Node Map → user review)
c. **Check Design Tokens** — confirm the `## Design Tokens` section exists (at minimum, shared colors + typography for the desktop breakpoint)
d. **If not → run Phase 1 first** — extract Design Tokens for each component and write to spec
e. **Layout-level Sanity Check** — download screenshots of each section, do a high-level structure comparison with the current implementation (if any). Confirm flex direction, layout hierarchy, and component composition are correct before proceeding to subtask breakdown

> This checkpoint is mandatory. UI specs without both a Node Map and Design Tokens may not proceed to subtask breakdown.

4. Build a change specification document following the spec-template rule format, and write it to `specs/{ticket-id}.md` in the project root (create `specs/` if it doesn't exist). If no ticket ID, use a descriptive slug (e.g., `specs/add-auth-middleware.md`). If a system spec exists (from Step 3.2), `## Current Behavior` can reference it instead of rewriting. Required sections:
   - **Context** — why this change exists (1-3 sentences)
   - **Current Behavior** — what happens now
   - **Target Behavior** — what should happen after
   - **Files to Change** — each file with one-line description
   - **Acceptance Criteria** — checkboxes, this is the "done" definition
   - **Testing Strategy** — automated tests, manual steps, or both
   - **Known Pitfalls** — things that could go wrong (optional)

### 4.5. Pattern Discovery (mandatory for existing projects)

After writing `## Files to Change` and before writing `## Acceptance Criteria`, execute Pattern Discovery.

**Purpose**: Scan the modules involved in this implementation, identify existing code patterns, and write them into the spec's `## Pattern Compliance` section as a contract for subsequent implementation and review.

**Prerequisite**: Pattern Constitution is stored at `~/.claude/projects/{project}/memory/pattern-constitution.md`. Auto-created on first `/plan`, accumulated over time.

**Constitution format**:

```yaml
---
name: pattern-constitution
description: Project pattern constitution — established code conventions and lint assertions
type: reference
---
```

```markdown
## Established Patterns
<!-- Patterns validated across multiple tickets, high confidence -->

### {Domain}
- **Approach**: {description}
- **Example**: `{path}:{line}`
- **Count**: {N} instances
- **Established at**: {ticket-id} / {date}
- **Lint Assertion**:
  ```bash
  {grep/lint command}
  # Expected: {expected result}
  ```

## Observed Patterns
<!-- First-time discoveries, need more ticket validation before upgrading to Established -->

### {Domain}
- **Approach**: {description}
- **Example**: `{path}:{line}`
- **Count**: {N} instances
- **Discovered at**: {ticket-id} / {date}

## Known Deviations
<!-- Deviations with valid justification, recorded to avoid false flags -->

| Domain | Deviation location | Deviation approach | Reason | Permitted at |
|--------|-------------------|-------------------|--------|-------------|
```

**Constitution evolution rules**:
- First-time pattern discovery → Observed
- Confirmed across 2+ tickets → upgrade to Established + generate Lint Assertion
- New deviation from an Established pattern → record in Known Deviations (requires user confirmation)

**Flow**:

a. **Read Pattern Constitution** — if it exists, read existing pattern records and lint assertions. Already-recorded domains are referenced directly without re-scanning.

b. **Determine scan scope** — extract directories from `## Files to Change` (at module level, e.g., `src/components/party-card/` → scan `src/components/`)

c. **Scan newly involved domains** — only scan domains not yet covered in the constitution:

| Domain | Scan method | How to determine mainstream |
|--------|------------|---------------------------|
| Asset Import | grep SVG/image import patterns | Higher count = mainstream |
| Styling | grep CSS Module / styled / className / Tailwind | Count + examples |
| API Call | grep useQuery / useMutation / fetch / axios | Higher count = mainstream |
| State | grep useState / useStore / useSelector | Higher count = mainstream |
| Component | Observe naming (PascalCase/kebab-case), export style | Majority rules |
| i18n | grep useTranslation / t( / Trans | Presence check |
| Testing | Observe test file location and mock patterns | Existing structure |

d. **Generate Lint Assertions** — for each mainstream approach (whether Observed or Established), generate project-specific grep/lint commands **at the spec level**. Even on first scan (all Observed), the spec still carries lint assertions for the critic to execute. Only after confirmation across 2+ tickets are lint assertions persisted to the Constitution's Established section. Example:
```bash
# Asset Import: SVGs should use SVGR import, not <img> + SVG
grep -rn '<img.*\.svg' src/ --include='*.tsx' --include='*.jsx'
# Expected: 0 matches (or only files permitted in Deviations)
```

e. **Update Constitution** — write newly discovered patterns + lint assertions back to the constitution (cumulative)

f. **Generate spec's Pattern Compliance section** — extract domains involved in this implementation from the constitution and write to spec

g. **User confirmation** — present the Pattern Compliance section and confirm:
   - Is the mainstream approach determination correct?
   - Does this implementation need any deviations? (if so, record in Deviations)
   - Are the lint assertions reasonable?
   - Once confirmed, this becomes the contract

> This step is mandatory. Existing project specs without Pattern Compliance may not proceed to subtask breakdown.
> Brand new projects (no existing code) skip this step.

### 4.7. Spec-Test Debate (SDD+TDD Integration)

After Pattern Discovery is confirmed and before subtask breakdown, execute the Spec-Test Debate.

**Purpose**: Ensure the spec's ACs and Pattern Compliance can be verified by tests, and establish bidirectional consistency between spec and tests.

**Flow**:

a. **AC → Test Cases** — for each AC, confirm it can map to specific test cases (fill in AC-Test Mapping)

b. **Pattern Compliance → Lint Assertions** — confirm each involved pattern has a corresponding lint assertion (already generated in Step 4.5)

c. **Contradiction check** — if you find:
   - AC conflicts with Pattern Compliance (e.g., AC requires an approach that the pattern disallows) → revise spec
   - A test cannot cover a certain AC → AC is too vague, needs refinement
   - Lint assertion conflicts with Deviations → adjust assertion to exclude permitted deviations

d. **Confirm** — after all contradictions are resolved, the spec's ACs, Pattern Compliance, and AC-Test Mapping are all consistent

> Spec is the source of truth. Tests and lint are both derived from the spec, not the other way around.

5. Create a detailed implementation plan as a numbered checklist, appended to the spec file under `## Implementation Plan`
6. Wait for my approval before starting implementation
7. After approval, work through the checklist step by step
8. Commit after each logical step
9. After all steps done, mark acceptance criteria as checked in the spec file

## Minimum Testable Step Breakdown Criteria

After producing the checklist and before starting implementation, each step must pass the following checks:

### Three Breakdown Principles

A step is "minimally testable" if and only if it simultaneously satisfies:

1. **Single AC principle** — corresponds to only 1-2 Acceptance Criteria from the spec. If a step needs to verify 3 or more ACs, it can be broken down further.

2. **Independently testable principle** — can be tested independently without depending on other incomplete steps. If Step B's tests require Step A to be complete first, Step B is not independently testable — consider merging or reordering.

3. **Single module principle** — the scope of changes is within one module. If a step requires changing both frontend and backend simultaneously, split it into two steps, each with their own ACs and tests.

### Breakdown Output Format

```markdown
## Task Breakdown

### Step 1: {title}
- **AC**: AC-1
- **Scope**: `src/components/Modal.tsx`, `__tests__/Modal.test.tsx`
- **Test**: `should open modal on button click`
- **Dependencies**: none

### Step 2: {title}
- **AC**: AC-2, AC-3
- **Scope**: `src/api/submit.ts`, `__tests__/api.test.ts`
- **Test**: `should submit form data`, `should handle 500 error`
- **Dependencies**: Step 1 (needs Modal's form data structure)
```

### Breakdown Quality Check

After breakdown is complete, auto-check:

```
Breakdown quality check

  {✅|❌} Each step has ≤ 2 ACs
  {✅|❌} Each step is independently testable
  {✅|❌} Each step is within a single module
  {✅|❌} No circular dependencies
  {✅|❌} All ACs are covered (none missed)
  {✅|❌} UI ticket: spec includes Figma Node Map + Design Tokens
  {✅|❌} UI ticket: layout-level sanity check passed (high-level structure matches Figma)
  {✅|❌|⬜} Modules involved have a system spec
  {✅|❌} Existing project: Pattern Compliance section filled in and user confirmed
  {✅|❌} Existing project: Spec-Test Debate complete (AC↔Test↔Pattern all consistent)
```
