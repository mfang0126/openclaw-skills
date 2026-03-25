#!/usr/bin/env bash
# reflection apply <pattern-text>
# Record that a pattern was successfully applied. Increments weight and applied count.

set -euo pipefail

STATE_FILE="${REFLECTION_STATE:-$HOME/.openclaw/reflection-state.json}"
PATTERN="${1:?Usage: reflection apply <pattern-text>}"

# Ensure state file exists
if [[ ! -f "$STATE_FILE" ]]; then
  mkdir -p "$(dirname "$STATE_FILE")"
  echo '{"last_check":0,"last_log":0,"session_corrections":0,"weights":{}}' > "$STATE_FILE"
fi

# Create a stable hash key from the pattern text
KEY=$(echo -n "$PATTERN" | md5 2>/dev/null || echo -n "$PATTERN" | md5sum 2>/dev/null | cut -d' ' -f1 || echo -n "$PATTERN" | shasum | cut -d' ' -f1)

# Read current weight data
CURRENT_WEIGHT=$(jq -r --arg k "$KEY" '.weights[$k].weight // 1' "$STATE_FILE")
CURRENT_APPLIED=$(jq -r --arg k "$KEY" '.weights[$k].applied // 0' "$STATE_FILE")
NOW=$(date +%s)

NEW_APPLIED=$((CURRENT_APPLIED + 1))

# Update state file
jq --arg k "$KEY" --arg w "$CURRENT_WEIGHT" --arg a "$NEW_APPLIED" --arg t "$NOW" --arg p "$PATTERN" \
  '.weights[$k] = {
    "pattern": $p,
    "weight": ($w | tonumber),
    "applied": ($a | tonumber),
    "last_used": ($t | tonumber)
  }' "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"

echo "✓ Applied [$PATTERN] — weight=$CURRENT_WEIGHT, applied=$NEW_APPLIED"

# Suggest promotion if applied enough times
if (( NEW_APPLIED >= 3 )); then
  echo "  → Applied 3+ times. Consider: reflection promote \"$PATTERN\""
fi
