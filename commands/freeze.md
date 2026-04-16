---
description: Lock the edit scope. Only allow modifying files in the specified directory; block file modifications outside scope. Usage: /freeze src/components/party-card
---

# Freeze Mode

Restrict this session to only modify files within the specified directory.

## Usage

```
/freeze src/components/party-card
/freeze apps/horny-client/components/new-year-page-components
/freeze supabase/functions/search-glossary
```

## Behavior

Once active, when the AI attempts to Edit or Write a file outside the specified directory, **do not execute** — instead output:

```
🧊 Freeze mode: out-of-scope modification intercepted
  File: {intercepted file path}
  Allowed scope: {frozen directory}

  If you truly need to modify a file outside scope:
  a) Say "unfreeze" to lift the restriction
  b) Say "add {path}" to expand the allowed scope
```

## Exceptions

The following files are not subject to freeze restrictions (because they are required by the workflow):
- `*.test.*` / `*.spec.*` (test files)
- `CLAUDE.md` (if spec progress needs to be updated)
- Session notes / memory files

## Deactivation

Deactivate when the user says "unfreeze", "remove freeze", or "unlock".
