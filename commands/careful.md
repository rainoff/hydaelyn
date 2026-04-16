---
description: Enable protection mode. Blocks destructive commands (rm -rf, git reset --hard, DROP TABLE, etc.). Say "disable careful" to deactivate.
---

# Careful Mode

When active, intercept the following destructive operations during this session:

## Block List

- `rm -rf` / `rm -r` (directory deletion)
- `git reset --hard` / `git checkout .` / `git clean -f`
- `git push --force` / `git push -f`
- `DROP TABLE` / `DROP DATABASE` / `TRUNCATE`
- `docker system prune` / `docker volume rm`
- Any direct operations against the prod environment

## Behavior

When any of the above operations are encountered, **do not execute** — instead output:

```
⛔ Careful mode: destructive operation intercepted
  Command: {intercepted command}
  Risk: {why it's dangerous}
  Alternative: {safe approach}

Say "I confirm I want to execute" to force execution.
```

## Deactivation

Deactivate when the user says "disable careful", "turn off careful", or "remove protection".
