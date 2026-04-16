# Contributing

## Core Standard

**Every new rule must include the failure case that triggered it.**

A rule without a failure case is a guess. This playbook is built from real mistakes, not hypothetical best practices.

## How to Contribute

### Adding a New Rule

1. Describe the failure: what went wrong, what the AI did incorrectly, what the impact was.
2. Write the rule that would have prevented it.
3. Include an activation condition if the rule is domain-specific (e.g., "Only when Figma designs are involved").
4. Submit a PR with both the rule and the failure case in the PR description.

Example PR description:

```
## Failure Case
AI replaced a color hex value across 12 files using replace_all.
3 of those files used the same hex for a different semantic purpose (border vs background).
Result: visual regression that passed all tests.

## Rule
visual-ui-workflow.md: "Do not use replace_all for color hex values.
Each usage context is different."
```

### Modifying an Existing Rule

- Explain what the current rule gets wrong or misses.
- Provide a concrete example (not a hypothetical).
- If weakening a rule, explain why the original constraint is no longer needed.

### What We Don't Accept

- Rules based on "best practices" without a concrete failure case.
- Rules that add process without preventing a specific class of mistakes.
- Overly specific rules that only apply to one project (use project-level rules for those).

## Structure

- `rules/` — Always-active behavior rules (global)
- `agents/` — Subagent definitions (critic, alignment-checker, etc.)
- `skills/` — Intent-triggered workflows (git-commit, review, etc.)
- `commands/` — Manually invoked slash commands (/plan, /session, etc.)

Domain-specific rules belong in project-level `{project}/.claude/rules/`, not in global rules.

## Style

- Write in English for this public repo.
- Keep rules concise. If a rule needs more than one page, it's probably two rules.
- Use imperative voice ("Do X", "Never Y"), not passive ("X should be done").
- Include activation conditions for rules that don't apply universally.

## License

By contributing, you agree your contributions are licensed under MIT.
