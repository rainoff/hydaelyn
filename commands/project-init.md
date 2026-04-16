---
description: Initialize Claude Code setup for a new or existing project
---

Initialize Claude Code for this project:

1. Check if this is a new or existing project:
$SHELL ls CLAUDE.md .claude/ 2>/dev/null && echo "EXISTING" || echo "NEW"
$SHELL git log --oneline -3 2>/dev/null

2. If NEW project:
   - Create CLAUDE.md with project overview, structure, tech stack, and gotchas
   - Create .claude/commands/ with project-specific commands
   - Create .claude/settings.local.json with project-specific permissions
   - Configure .gitignore for .claude/:
     - Track: .claude/commands/, .claude/agents/ (team-shared)
     - Ignore: .claude/settings.json, .claude/settings.local.json (personal)

3. If EXISTING project:
   - Read CLAUDE.md and check if it follows best practices (< 2500 tokens, has gotchas section)
   - List existing .claude/ setup and suggest improvements
   - Check if project-specific commands would be useful

4. In both cases:
   - Scan project structure (package.json, requirements.txt, etc.) to detect tech stack
   - Suggest project-specific slash commands based on common workflows
   - Suggest project-specific subagents if applicable
   - Show final directory structure

5. Scaffolding checks (run for both NEW and EXISTING):

   a. **Create specs/ directory** (if it doesn't exist):
      ```bash
      mkdir -p specs && touch specs/.gitkeep
      ```

   a2. **System Spec directory setup**:
      - Ask: "Do you want to use OpenSpec (in-repo `openspec/specs/`), Private Specs (`~/.claude/projects/{key}/specs/system/`), or skip?"
      - OpenSpec → `mkdir -p openspec/specs openspec/changes openspec/changes/archive`
      - Private → `mkdir -p ~/.claude/projects/{key}/specs/system`
      - Skip → do not create; /plan will propose it as needed

   b. **Confirm Linter configuration**:
      - If exists → skip
      - If not exists → ask "Would you like to use a standard ESLint/Prettier config?"
        - No → note in CLAUDE.md: "This project does not use a standard linter"

   c. **Confirm CI configuration** (`.gitlab-ci.yml` / `.github/workflows/`):
      - If exists → skip
      - If not exists → remind: "This project does not have CI configured"

   d. **Ask if this is a team project**:
      - Yes → suggest creating `.gitlab/CODEOWNERS`, defaulting all paths to the current user
      - No → skip

   e. **JIRA configuration**:
      - Check if CLAUDE.md already has a `## JIRA` section
      - If not → ask:
        - "Default task type?" (common: FT-Task, Story, Task)
        - "Team name?" (common: your-team)
      - Write to CLAUDE.md:
        ```yaml
        ## JIRA
        - default_type: {answer}
        - team: {answer}
        ```
      - Do not write project key or parent ticket (asked dynamically at each /plan)

6. **Document placement suggestions** (inform the user):
   ```
   If you have any of the following documents, consider placing them here so I can index them quickly:

     docs/architecture/ — system architecture, module relationship diagrams
     docs/ops/          — deployment processes, environment config
     docs/business/     — business rules, product specs
     docs/integrations/ — third-party service config, API integration docs

   Or tell me directly and I'll store them in memory.
   I'll automatically include existing documents in the MEMORY.md knowledge map.
   ```

7. Report what was created/updated — output checklist:
   ```
   Project initialization complete

     {✅|⚠️} CLAUDE.md
     {✅|⚠️} specs/ directory
     {✅|⚠️} System Spec directory
     {✅|⚠️} Linter config
     {✅|⚠️} CI config
     {✅|⚠️} CODEOWNERS (team project)
     {✅|⚠️} JIRA config
   ```
