#!/bin/bash
# check_workspace.sh — List workspace files with metadata to help audit staleness
# Usage: ./scripts/check_workspace.sh [workspace_path]
# Default: uses current directory

WORKSPACE="${1:-$(pwd)}"
WORKSPACE_FILES=(SOUL.md USER.md MEMORY.md WORKING.md AGENTS.md TOOLS.md BOOTSTRAP.md HEARTBEAT.md)

echo "Workspace: $WORKSPACE"
echo "---"
printf "%-20s %-12s %-8s %s\n" "FILE" "MODIFIED" "LINES" "STATUS"
echo "---"

for file in "${WORKSPACE_FILES[@]}"; do
  filepath="$WORKSPACE/$file"
  if [ -f "$filepath" ]; then
    modified=$(stat -f "%Sm" -t "%Y-%m-%d" "$filepath" 2>/dev/null || stat -c "%y" "$filepath" 2>/dev/null | cut -d' ' -f1)
    lines=$(wc -l < "$filepath" | tr -d ' ')
    printf "%-20s %-12s %-8s %s\n" "$file" "$modified" "$lines" "✅ exists"
  else
    printf "%-20s %-12s %-8s %s\n" "$file" "-" "-" "❌ missing"
  fi
done
