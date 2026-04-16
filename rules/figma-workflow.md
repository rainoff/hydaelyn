---
paths:
  - "**/*.tsx"
  - "**/*.vue"
  - "**/*.jsx"
  - "**/*.css"
  - "**/*.scss"
  - "**/*.svelte"
  - "**/*.html"
  - "specs/**/figma*"
---

# Figma Workflow — Precise Integration Process

> Query component by component, never guess. Spec is the single source of truth.

## Activation Condition

Activate when a ticket involves UI implementation and a Figma design file exists.

## MCP Capabilities and Limitations

### What can be retrieved accurately
- Dimensions, spacing, padding, gap (precise to px)
- Colors (hex / rgba / full gradient definitions)
- border, stroke (including dash patterns)
- box-shadow / effects
- Font family, weight, size, lineHeight, letterSpacing
- Component tree structure, component variants, instance properties

### Known blind spots
- **Character-level fills**: For TEXT nodes where individual characters have different colors, MCP only returns the node-level primary fill
- **Dev Mode Annotations**: Behavior notes written by designers using Figma's native annotation feature (dashed boxes connected to components) are not in the node tree and are completely invisible to MCP. These annotations typically contain key information about interactions, scroll behavior, and state transitions
- **Figma Comments**: Discussion threads on the canvas — MCP cannot read these either
- **Figma Variables / Design Tokens**: Only resolved values are available; token names may not be retrievable
- **Interactive states**: hover, active, disabled states require separate queries for each variant's nodeId
- **Responsive behavior**: Figma only represents fixed sizes; breakpoint behavior requires additional information

### Blind spot compensation strategies

| Blind spot | Compensation method |
|------------|---------------------|
| Character-level fills | Claude flags suspected locations + user manually enters color values in spec |
| Dev Mode Annotations | **User pastes annotation content into the spec's "Behavior Notes" section during Phase 0 review** |
| Figma Comments | Same as Annotations — content that affects implementation must be manually moved to spec |
| Interactive states | List each variant's nodeId in the Node Map and query separately |

## Phase 0: Figma Exploration (once per ticket)

**Goal**: Build a Figma Node Map and write it to spec.

### Step 0a: Locate Handoff Spec

Designers may have set up a handoff structure in Figma (Atomic Design layers: Atoms → Molecules → Organisms).

1. First look for a handoff section at the Canvas level (usually a SECTION named "Handoff", "To organize", or the component name)
2. If found, drill in to see the component list under Atoms / Molecules / Organisms
3. These component IDs should match the instances used on the page — cross-verify

### Step 0b: Drill into Page Structure

1. Use `get_figma_data(fileKey, nodeId=page_top_level, depth=2)` to identify sections
2. For each section, drill further with `depth: 2` down to component level
3. Drill separately for all breakpoints (desktop / tablet / mobile)

### Step 0c: Screenshot Confirmation

1. For each section at each breakpoint, download 1x screenshots using `download_figma_images`
2. Store screenshots at `specs/figma-reference/{breakpoint}-{NN}-{section}.png`
3. Naming convention: `desktop-01-hero.png`, `mobile-04-plan.png`, `tablet-06-bottomcta.png`

### Step 0d: Produce Node Map

1. Write the Node Map table to `specs/{ticket}.md`
2. **User verifies each ID is correct by comparing screenshots against the Node Map**
3. User fills in gaps or corrections after review; only proceed to Phase 1 after confirmation

### Step 0e: User Supplements Dev Mode Annotations

MCP cannot read Figma Dev Mode Annotations (dashed annotation boxes), and screenshot exports do not render annotations either.

**How to supplement**: The user pastes annotation content to Claude at any point during development, and Claude writes it into the `Behavior Notes` section of spec. This does not need to be done all at once — it can be done in batches as needed.

```markdown
### Behavior Notes (from Figma Annotations, manually added)
| Section | Annotation content | Corresponding Node |
|---------|--------------------|--------------------|
| Plan carousel | "Use scrollbar on tablet and above, use left/right arrows + dots on mobile" | 4753:13679 |
```

**Principles**:
- Prioritize drilling down to independently implementable component level (card, list item, button)
- Record nodeId separately for each breakpoint (desktop / tablet / mobile)
- If the design has multiple versions (V1/V2), only record the confirmed version
- If the designer has a handoff spec, prioritize following its component layering structure

## Phase 1: Design Token Extraction (before implementing each component)

**Goal**: Extract precise design values from Figma and write them to the spec's Design Tokens section.

**Steps**:
1. Run `get_figma_data` for each component nodeId in the Node Map
2. Parse all layout, fill, stroke, effect from `globalVars.styles`
3. For every TEXT node in each component, build a complete **Color Inventory** table (no TEXT node may be omitted):
   | TEXT Node | Content summary | Figma fill | Expected Tailwind class |
   Compare this table line by line during implementation to ensure code text colors match Figma 1:1.
4. Organize into structured tables (Layout / Colors / Typography / Borders & Effects)
5. When encountering TEXT nodes, check whether the text might have character-level fills (based on design intent)
6. For areas suspected to have multi-color text, download screenshots using `download_figma_images` as reference

**Output format**: See the `Design Tokens` section in the spec template.

### First-definition validation (prevent copy-paste propagation)

When defining a reusable style value for the first time in code (such as dash pattern, gap, color code):
1. **Compare against spec character by character** — do not rely on memory; open the spec and verify the exact value
2. **Define once, reference many times** — prefer design tokens / Tailwind config / variables over hard-coding the same value in multiple places
3. **If wrong the first time, wrong everywhere** — if a value appears multiple times in the spec, only validate once, but validation must be precise to every digit

## Phase 2: Character-Level Fill Compensation

**Trigger**: TEXT nodes known to have multi-color text (accent colors, link colors, etc.).

**Approach** (mixed A + B strategy):
1. Claude flags `(!) possible character-level fill` during extraction
2. Also download a screenshot of the component as visual reference
3. User fills in correct color values and ranges in the `Character-Level Fills` table when reviewing spec
4. During implementation, use the user-annotated values, not the node-level fill returned by MCP

**Format in spec**:
```markdown
### Character-Level Fills (MCP blind spot, manually annotated)
| Text Node ID | Full text summary | Emphasis range | Emphasis color |
|--------------|-------------------|----------------|----------------|
| I4831:...678 | [Important rule reminder]...distributed once per month... | "distributed once per month" | #64E9D6 |
```

## Phase 3: Post-Implementation Figma Audit

**Goal**: Automatically compare Figma tokens against actual values in code, listing all discrepancies at once.

**Trigger**: After each UI component subtask is complete, before acceptance review.

**Mandatory**: In the UI subtask acceptance flow, Phase 3 Figma Audit is equivalent to Step 0.5 Alignment Check in verification-loop. It cannot be skipped or deferred until the end.

### Refactor Mode (cross-section unified corrections)

When changes are uniform adjustments across multiple sections (e.g., consolidating tokens, unifying import patterns):
- Do not run Phase 3 section by section
- Switch to "full-module audit": compare target attributes across all affected sections at once
- Output format is the same as standard Phase 3, but title it `Figma Audit: {topic} (across {N} sections)`

**Comparison items**:
1. Dimensions (width / height / padding / gap / border-radius)
2. Colors (background / text color / border color)
3. Typography (family / weight / size / lineHeight)
4. Effects (shadow / blur)
5. Character-level fills (compare against manual annotations in spec)

**Output format**:
```
Figma Audit: {component name}
  ✅ width: 320px — code: w-[320px]
  ❌ font-weight: 900 — code: font-bold (700) → needs font-black
  ⚠️ character-level fill not auto-verified, please visually confirm screenshot
```

## Spec Priority

Spec is the single source of truth. When the following sources conflict:
1. **User's manual annotations in spec** — highest priority
2. **Figma MCP query results** — second priority
3. **Screenshot visual judgment** — reference only

If the user has modified values in spec (correcting Figma recognition errors), all subsequent implementation and audit must use spec values — do not go back to query Figma.

## Gotchas

- Phase 3 Figma Audit cannot be deferred — compare immediately after each UI subtask is complete, do not wait until everything is done. Reason: incorrect values propagate through copy-paste to subsequent subtasks
- When writing a repeated value for the first time, compare against spec character by character — dash patterns, gaps, colors are easy to misremember (e.g., [2,8] remembered as [2,10]). Open spec and compare, do not rely on memory
- Page-level Figma queries are unreliable — data volume is too large and hierarchy is easily misidentified. Always drill to component-level queries
- Mobile/Tablet values must not be guessed — when spec only has desktop, mobile values must either be queried from the Figma mobile node or explicitly marked "to be confirmed". Do not infer independently
- CSS transform direction is a common AI mistake — scale-x mirroring, translate offsets, and rotate directions involve spatial reasoning that AI handles poorly. When transforms are involved, provide two directional options for the user to choose from rather than implementing a single direction unilaterally
