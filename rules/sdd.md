# SDD — Spec-Driven Development

> Every module has a ground truth spec. Read the spec before making changes — do not scan code on the fly.

## Activation Condition

Applies to all projects. Introduced incrementally — write a spec only when you touch a module. Missing specs do not block the workflow.

## Two Types of Spec

| Type | Purpose | Description | Template |
|------|---------|-------------|----------|
| **System Spec** | as-is | Describes what the system looks like right now (ground truth) | See below |
| **Change Spec** | to-be | Describes what to change (delta) | `rules/spec-template.md` |

## System Spec Storage Location

Resolution priority (use the first match):

1. **In-repo OpenSpec**: `{project}/openspec/specs/{module}.md`
2. **Private specs**: `~/.claude/projects/{key}/specs/system/{module}.md`
3. **Memory fallback**: relevant memory files in `~/.claude/projects/{key}/memory/`
4. **Trigger creation**: none of the above exist → propose creating one (user can skip)

For projects where placing `openspec/` in the repo is not viable (e.g., shared monorepos, restricted repo permissions, or preference against non-code directories in the repo), use Private specs.

## System Spec Template

Frontmatter:

```yaml
---
module: {module name}
scope: {directory or file pattern covered}
last_verified: {YYYY-MM-DD}
---
```

Body:

```markdown
# {Module Name}

## Intent
<!-- One paragraph: why this module exists and what problem it solves -->

## Public API
<!-- Externally exposed interfaces: function signatures, endpoints, events, CLI commands -->

## Internal Structure
<!-- Internal composition: key files, class/function relationships, data flow -->

## Extension Points
<!-- How to add functionality without changing the core: hooks, plugins, config, etc. -->

## Dependencies
<!-- Upstream: what this depends on. Downstream: what depends on this module -->

## Gotchas
<!-- Traps when using or modifying this module. Same format as CLAUDE.md Gotchas -->

## Patterns
<!-- Code patterns specific to this module, complementing the Pattern Constitution -->
```

### Section Descriptions

- **Intent**: One paragraph. Not a feature list — "why it exists"
- **Public API**: Externally visible interfaces. Changing these = breaking change
- **Internal Structure**: How it is organized internally. Does not need to be line-by-line, but must let a reader understand the module architecture
- **Extension Points**: How to extend. "Adding a new X" — what to change
- **Dependencies**: Upstream and downstream. Who is affected if this module changes
- **Gotchas**: Traps. Accumulated from memory feedback and real experience
- **Patterns**: Code patterns specific to this module. Cross-module patterns go in the Pattern Constitution. If a pattern is already covered by the Constitution (has a corresponding Lint Assertion), do not repeat it here — use `→ see constitution: {domain}` instead

## When It Triggers

### Auto-propose creation (non-blocking)

- `/plan` touches a module with no system spec → propose creating one
- User can skip ("not needed this time") → does not block the workflow
- Accepted → create during the /plan flow, as the output of Step 3.2

### When to update

- After a change spec is fully implemented → check whether the corresponding system spec needs updating
- Module's Public API was modified → must update
- Module's Internal Structure was modified → recommended update
- During `/session` knowledge extraction, flag specs that need updating
- When updating a spec, also update `last_verified` to today's date

### Staleness check

- `/housekeeping` scans specs where `last_verified` is more than 30 days ago → reminds to update
- Does not auto-update — only reminds

## Division of Labor with Memory

| Knowledge type | Storage location | Examples |
|---------------|-----------------|----------|
| Structural | System Spec | API signatures, module dependencies, extension points |
| Experiential | Memory (feedback) | "Last time we changed X, Y broke" |
| Status | Memory (project) | "Currently building feature Z" |
| Normative | Rules | "All projects require a context check" |

**Migration principle**: If memory contains descriptions of module structure (API, dependencies, internal organization), migrate that content into the system spec when creating it. Keep only experiential content in memory.

## OpenSpec CLI Integration

Use the CLI when available; otherwise use Read/Write manually. The format is the same either way.

```bash
# Initialize (optional)
openspec init

# Create a system spec
openspec spec create {module}

# Create a change spec
openspec change create {ticket-id}

# Archive after completion
openspec change apply {ticket-id}
```

**Not a dependency** — the CLI is just an accelerator. The spec file itself is what matters; create it by any means.
