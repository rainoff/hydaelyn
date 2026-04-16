---
paths:
  - "**/*.tsx"
  - "**/*.vue"
  - "**/*.jsx"
  - "**/*.css"
  - "**/*.scss"
  - "**/*.svelte"
  - "**/*.html"
---

# Visual UI Workflow — Visual Change Workflow

> You can only judge what you can see. A hex value in code is not the same as the effect on screen.

## Activation Condition

Activate when a task involves UI color schemes, asset replacement, panel styles, text readability, or other visual changes.

## Workflow

### Step 1: Learn Before Doing

Color schemes and visual styles are not AI's strong suit. Before making changes, you must:
1. WebSearch for color principles for the style in question (pixel game UI, WCAG contrast ratios, etc.)
2. Verify that foreground/background color combinations have contrast ratio ≥ 3:1 (headings) or ≥ 4.5:1 (body text)
3. Organize into a color scheme table and **provide 2-3 options for the user to choose from**

**Do not pick colors by feel.**

### Step 2: Modify and Verify Screen by Screen

- Run Playwright screenshots every 2-3 files changed
- Never use `replace_all` to bulk-replace color codes — each usage context is different
- Continue to the next batch only after screenshots confirm text readability and style consistency

### Step 3: Playwright Screenshot Verification

```bash
npx playwright test e2e/screenshots.spec.ts
```

After screenshots, view them with the Read tool and check:
- [ ] Text is clearly readable against panel backgrounds
- [ ] Color tone is consistent with the overall style (not jarring)
- [ ] Buttons, labels, and other interactive elements are distinguishable
- [ ] Style is consistent across different screens

### Step 4: User Confirmation

The final judgment on visual results belongs to the user. AI provides options and technical implementation — it does not make subjective aesthetic decisions.

## Notes

- Before Playwright screenshots, run `localStorage.clear()` to avoid residual state
- Screenshots should cover key screens: MainMenu, Hub, Map, Battle, Shop, Garage, Boss
- If no Playwright setup exists, remind the user to verify manually

## Gotchas

- Stop immediately after the first failed attempt at positioning a decorative image — do not keep trying different placements. Ask the user: "Is the visual direction of this image correct in this position?" Reason: filename direction hints (rightbot/lefttop) indicate the original design position, not necessarily the target placement position. CSS transform flipping is needed rather than swapping `src`.
- Figma node names are inherited from the component master; the actual position of an instance may differ — do not infer placement direction from node names.
