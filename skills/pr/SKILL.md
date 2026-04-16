---
name: pr
description: Create a Merge Request. Triggers when the user expresses intent to create an MR, including "open MR", "create MR", "submit MR", "create MR", "merge request", "merge back to main", "open PR", "create PR", "submit PR", "pull request", "send for review"
---

# Merge Request

## Trigger Condition

Activate when the user wants to **create a merge request** for the current branch.

Common expressions: "open MR", "create MR", "submit MR", "merge request", "merge back to main", "send for review"
Also triggers on PR terminology: "open PR", "create PR", "submit PR", "pull request"

## Execution Flow

1. **Gather context** (run in parallel):
   - `git branch --show-current` — current branch name
   - `git log main...HEAD --oneline` — all commits on this branch (adjust base branch if needed)
   - `git diff main...HEAD --stat` — file change summary
   - `git status` — check for uncommitted changes
   - `git log -1 --format="%H"` on remote — check if pushed

2. **Pre-flight checks:**
   - If uncommitted changes exist → warn: "There are uncommitted changes — commit first?" and stop
   - If not pushed to remote → will push with `-u` in step 4

3. **Draft MR content** based on ALL commits (not just the latest):
   - **Title**: Under 70 characters. Format: `type(scope): description` matching Commitizen style from commits
   - **Body**: Use this template:
     ```
     ## Summary
     - bullet 1 (what changed and why)
     - bullet 2
     - bullet 3

     ## Test Plan
     - [ ] test step 1
     - [ ] test step 2
     ```

4. **CODEOWNERS check** (if the project has CODEOWNERS):
   - Read CODEOWNERS, compare against `git diff --name-only` to find affected owners
   - Automatically suggest reviewers (excluding the MR author)
   - If changes span multiple owners → add a cross-module impact section to MR description:
     ```
     ## Cross-module Impact

     | Module | Owner | Files changed |
     |------|-------|-----------|
     | src/components/ | @frontend-team | 3 |
     | src/api/ | @backend-team | 1 |
     ```

5. **Show the draft and ask for confirmation:**
   "Confirm creating the MR?"
   - User approves → push (if needed) and create MR via `glab mr create`
   - User requests changes → revise and re-ask
   - User declines → stop

6. **After MR is created:**
   - Print the MR URL
   - If the project has CI checks, mention: "MR created — waiting for CI to complete."

## Output Rules

- **Never create a MR without user confirmation.**
- Default base branch is `main`. If the repo uses `master` or `develop`, detect from `git remote show origin` or ask.
- Do NOT add `Co-Authored-By` or any trailers to the MR body.
- Use `glab mr create` with `--title` and `--description` flags. Pass description via HEREDOC for formatting.
- If the branch name contains a ticket ID (e.g., `feat/COIN-75-xxx`), include it in the MR title.
- If CODEOWNERS suggests reviewers, add `--reviewer` flag.
