#!/usr/bin/env bash
# reflection log <tag> <miss> <fix> [--weight <n>]
# Appends a structured reflection to today's daily log (Layer 3)

set -euo pipefail

MEMORY_DIR="${REFLECTION_MEMORY:-./memory}"
STATE_FILE="${REFLECTION_STATE:-$HOME/.openclaw/reflection-state.json}"

# Parse args
TAG="${1:?Usage: reflection log <tag> <miss> <fix> [--weight <n>]}"
MISS="${2:?Missing: <miss> — what went wrong}"
FIX="${3:?Missing: <fix> — what to do instead}"
shift 3

WEIGHT=1
while [[ $# -gt 0 ]]; do
  case "$1" in
    --weight) WEIGHT="${2:?--weight requires a number}"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

# Ensure memory directory
mkdir -p "$MEMORY_DIR"

TODAY=$(date +%Y-%m-%d)
LOG_FILE="$MEMORY_DIR/$TODAY.md"
NOW=$(date +%H:%M)

# Create file with header if new
if [[ ! -f "$LOG_FILE" ]]; then
  echo "# Reflection Log — $TODAY" > "$LOG_FILE"
  echo "" >> "$LOG_FILE"
fi

# Append entry
cat >> "$LOG_FILE" << EOF

## [$NOW] $TAG
- **Miss:** $MISS
- **Fix:** $FIX
- **Weight:** $WEIGHT
- **Applied:** 0
EOF

# Update state: increment session corrections, record last log time
if [[ -f "$STATE_FILE" ]]; then
  _tmp=$(mktemp)
  jq --arg now "$(date +%s)" \
    '.last_log = ($now | tonumber) | .session_corrections = ((.session_corrections // 0) + 1)' \
    "$STATE_FILE" > "$_tmp" && mv "$_tmp" "$STATE_FILE"
fi

echo "✓ Logged to $LOG_FILE [$TAG] weight=$WEIGHT"
