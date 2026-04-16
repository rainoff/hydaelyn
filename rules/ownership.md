# Ownership — Ownership and Module Boundaries

> Before touching anything, answer: whose is it?

## Activation Condition

**Only activate when CODEOWNERS exists in the project root** (check in order: `.gitlab/CODEOWNERS` → `CODEOWNERS` → `docs/CODEOWNERS`).
If none exist, this rule does not trigger at all.

## Principles

1. **Every directory has an owner** — defined through the project's CODEOWNERS
2. **Communicate before modifying another person's module** — this is mandatory, not a suggestion
3. **MR automatically assigns the correct reviewer** — based on CODEOWNERS, not memory

## CODEOWNERS Specification

Every team project's CODEOWNERS must exist and be maintained. Recommended location: `.gitlab/CODEOWNERS`. Format:

```
# Format: path pattern    @owner
# owner can be a GitLab username or group

# Global fallback
*                       @tech-lead

# Frontend
/src/components/        @frontend-team
/src/pages/             @frontend-team
/src/styles/            @frontend-team

# Backend / API
/src/api/               @backend-team
/src/services/          @backend-team

# Shared modules (requires multi-party review)
/src/shared/            @tech-lead @frontend-team @backend-team
```

## Claude Code Behavior Rules

### Cross-module modification check

When preparing to commit, if files from `git diff --name-only` span directories with different owners:

1. **Stop and list the affected modules and their corresponding owners**
2. **Ask: "Have you already coordinated with @owner?"**
3. If the answer is "not yet" → suggest opening a discussion first, do not commit
4. If the answer is "already aligned" → add `Coordinated-with: @owner` to the commit message

### Example prompt

```
Cross-module modification notice

Your changes span multiple owners:
  - src/components/Header.vue → @frontend-team
  - src/api/auth.ts → @backend-team
  - src/shared/types.ts → @tech-lead + @frontend-team + @backend-team

Have you already aligned with the relevant owners?
```

### Exceptions

The following cases do not require cross-module coordination:
- Only modifying directories you own
- Modifying pure type files (`.d.ts`, `types.ts`) without changing interfaces
- Modifying test files (`*.test.*`, `*.spec.*`)
- Modifying documentation (`*.md`, `CHANGELOG`)
- Dependency updates (version bumps in `package.json`)

### New project initialization

When running `/project-init` for a team project, suggest generating `.gitlab/CODEOWNERS`:
- Default all paths to the current user
- Remind the user to update when team members join

## Integration with MR

When opening an MR:
1. Read CODEOWNERS and automatically suggest reviewers based on changed files
2. If changes span multiple owners → add a "cross-module impact" section to the MR description
3. If the target repo has no CODEOWNERS → do not trigger, do not warn
