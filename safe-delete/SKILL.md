---
name: safe-delete
description: |
  Intercept all delete operations and use `trash` (ali-rantakari) instead of `rm`.

  ALWAYS use `trash` instead of `rm` when deleting files or directories.
  Files moved to trash can be recovered from ~/.Trash/

  RULES:
  - `rm -rf PATH` → `trash PATH` (no -rf needed, trash handles dirs)
  - `rm PATH` → `trash PATH`
  - `rm -f PATH` → `trash PATH`
  - NEVER use raw `rm` command in exec
  - The only exception is `/tmp/` cleanup where trash is unnecessary

  trash is installed at /opt/homebrew/bin/trash (ali-rantakari version).
  It moves files to macOS ~/.Trash/ (recoverable).

  NOTE: OpenClaw exec does NOT source .zshrc, so shell aliases (safeshell wrap rm)
  are NOT available. You must explicitly use `trash` in all exec commands.
metadata:
  openclaw:
    emoji: "🗑️"
    requires:
      bins: ["trash"]
---

# Safe Delete

**Always use `trash` instead of `rm`.** No exceptions except `/tmp/` cleanup.

## Quick Reference

| Instead of | Use |
|-----------|-----|
| `rm file.txt` | `trash file.txt` |
| `rm -rf dir/` | `trash dir/` |
| `rm -f file` | `trash file` |
| `rm -r dir/` | `trash dir/` |
| `find . -name "*.tmp" -delete` | `find . -name "*.tmp" -exec trash {} +` |

## How It Works

- `trash` moves files to `~/.Trash/` (macOS Trash)
- Files are recoverable from Finder or terminal
- Supports directories (no need for -r flag)
- Installed via Homebrew: `brew install trash`

## Examples

```bash
# Delete old workspace
trash /Users/mingfang/.openclaw/workspace-old/

# Delete temp files
trash /tmp/my-temp-file.txt

# Delete and verify
trash ~/Downloads/old-report.pdf && echo "moved to trash"
```
