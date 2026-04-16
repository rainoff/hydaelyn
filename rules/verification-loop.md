# Verification Loop — Acceptance Feedback Loop

> Acceptance failure is not a disaster — it's part of the process.

## Principles

1. **Acceptance failure → open a correction subtask, do not roll back the entire step**
2. **Correction subtask inherits the original ACs** — no acceptance condition will be missed
3. **Re-verify after correction is complete** — only proceed to next step after passing
4. **Maximum two correction rounds** — exceeding two rounds indicates the granularity of task breakdown is problematic; replanning is needed

## Acceptance Flow

### Step 0: Critic Review (Builder-Critic Dialectic)

After task-executor completes, **before the main session accepts**, launch the `critic` subagent for adversarial review.

**Context Swap Principle:** Critic receives only the spec (ACs) and git diff — it does not inherit the builder's conversation history. This is intentional — it eliminates the builder's rationalization bias.

**Content to pass to critic:**
```
## Spec (Acceptance Criteria)
{copy original ACs from plan/spec}

## Changed Files
{git diff output}

## Test Results
{test execution results}

## Pattern Compliance
{copy Pattern Compliance section from spec, including table, Lint Assertions, and Deviations}
```

**Critic result handling:**
- **PASS** → proceed to Step 0.5 (if applicable) or Step 1
- **FAIL (has 🔴 Critical)** → treat as acceptance failure immediately, enter Step 3 correction flow with critic findings as the basis for corrections
- **Only 🟡 Important** → proceed to Step 0.5 (if applicable) or Step 1, but include findings as reference

### Step 0.5: Alignment Check (when external references exist)

**When to trigger:** When a subtask involves any of the following, execute after Critic PASS and before main session acceptance:
- UI/UX implementation (has Figma design file)

**For UI subtasks, Alignment Check = Figma Phase 3 Audit**:
For subtasks with a Figma design file, the specific execution of Step 0.5 is Phase 3 from `figma-workflow.md` (automatically compare spec tokens vs. code values). Screenshot comparison can supplement but cannot replace value-by-value comparison.
- API integration (has Protobuf schema or API spec)
- Dify workflow modification (has YAML definition)
- Any implementation with a clear external reference source

**Cases where it does not trigger:** Pure logic changes, refactors, tests, documentation updates.

Launch `alignment-checker` subagent (fresh context), passing:
```
## Reference Type
{figma | spec | schema | workflow}

## Reference Source
{Figma URL | spec path | schema definition}

## Implementation Files
{files changed in this task}

## Focus Areas
{key alignment points extracted from ACs}
```

**Result handling:**
- **ALIGNED** → proceed to Step 1
- **MISALIGNED (has 🔴)** → treat as acceptance failure; use discrepancies as basis for corrections
- **Only 🟡** → proceed to Step 1; include in acceptance reference

### Step 1: Main session accepts subagent output

Acceptance checklist:
- [ ] Critic review passed (or only has 🟡 findings)
- [ ] Pattern Compliance audit passed (all Lint Assertions match expected results)
- [ ] Alignment check passed (if applicable, or only has 🟡 findings)
- [ ] All ACs marked as complete
- [ ] All tests passing (`npm test` / `pytest`)
- [ ] Code conforms to lint rules
- [ ] No files outside scope were modified
- [ ] No new dependencies introduced (unless agreed in advance)

### Step 2: Acceptance result branches

#### ✅ Pass

```
✅ Step {N} accepted

  AC status: {M}/{M} passed
  Tests: {X} passed, 0 failed
  Lint: no errors

  → Ready to proceed to next step
  → JIRA sync reminder (see jira-sync rule)
```

Commit all changes for this step; commit message includes the corresponding ticket ID.

**SDD sync**: If this step modified a module that has a system spec, update the spec's `last_verified` to today's date.

#### ❌ Fail

```
❌ Step {N} not accepted

  Issues:
    1. AC-2 not satisfied: {specific description of what's wrong}
    2. Test `should handle edge case` failed

  Correction plan:
    → Create correction subtask (inheriting AC-2)
    → Estimated correction scope: {affected files}

  This is correction round {1|2}.
```

### Step 3: Correction subtask

Format for correction subtask:

```
## Correction Subtask (original Step {N}, round {R})

## Original ACs (inherited)
- AC-2: {original condition — copy in full}

## Failure Reason
{specific description of the problem found during acceptance}

## Correction Requirements
{clearly state what needs to change}

## Scope
- Modifiable files: {list only files that need to be corrected}

## Pattern Compliance
{inherited from original subtask, copy the full Pattern Compliance section}
```

The correction subtask is handed to the task-executor agent to execute, following the same flow as the original step.

### Step 4: Re-verify after correction

After correction is complete, **run the full acceptance checklist again** (not just the corrected parts):
- All original ACs must be re-verified
- All tests must be re-run
- Confirm the correction did not break anything else

### Step 5: Handling more than two rounds

If the same step has not passed after more than two rounds of correction:

```
⚠️ Step {N} has not passed after {R} correction rounds

  This typically means:
    1. Granularity too large — this step needs to be split further
    2. AC definition not specific enough — need to revise the spec
    3. Unforeseen dependency exists — need to re-evaluate scope

  Recommendation: pause execution and return to /plan to re-evaluate the breakdown of this step.
```

## JIRA Sync

When acceptance fails:
- **Do not update JIRA status** (subtask stays In Progress)
- Record failure reason and correction plan in the subtask comment

When correction passes:
- Trigger JIRA sync normally (Trigger point 2)
- Note in comment: "passed after {R} round(s) of correction"

## Change Spec Archiving

After all steps pass acceptance and the feature is complete:
- Has OpenSpec CLI → `openspec change apply {ticket-id}`
- No CLI → manually check off all ACs in `specs/{ticket-id}.md` and mark as complete
- Update the corresponding system spec at this point if needed

## Relationship with Gate

- The verification loop happens **before the Gate** — all steps must pass acceptance before entering the Gate check
- Gate checks overall feature functionality; verification checks individual steps
- They do not conflict — they are quality assurance at different granularities
