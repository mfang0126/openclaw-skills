#!/usr/bin/env bash
# reflection check [--quiet]
# Returns OK or ALERT based on time since last reflection

set -euo pipefail

STATE_FILE="${REFLECTION_STATE:-$HOME/.openclaw/reflection-state.json}"
THRESHOLD="${REFLECTION_THRESHOLD:-60}"  # minutes
QUIET=false

[[ "${1:-}" == "--quiet" ]] && QUIET=true

# Ensure state file exists
if [[ ! -f "$STATE_FILE" ]]; then
  mkdir -p "$(dirname "$STATE_FILE")"
  echo '{"last_check":0,"last_log":0,"session_corrections":0,"weights":{}}' > "$STATE_FILE"
fi

LAST_CHECK=$(jq -r '.last_check // 0' "$STATE_FILE")
NOW=$(date +%s)
ELAPSED=$(( (NOW - LAST_CHECK) / 60 ))

# Update last_check timestamp
jq --arg now "$NOW" '.last_check = ($now | tonumber)' "$STATE_FILE" > "${STATE_FILE}.tmp" \
  && mv "${STATE_FILE}.tmp" "$STATE_FILE"

if (( ELAPSED >= THRESHOLD )); then
  CORRECTIONS=$(jq -r '.session_corrections // 0' "$STATE_FILE")
  if [[ "$QUIET" == "false" ]]; then
    echo "ALERT: ${ELAPSED}m since last reflection"
    echo "Session corrections: $CORRECTIONS"
    echo ""
    echo "Actions:"
    echo "  reflection read        — review recent lessons"
    echo "  reflection log ...     — log new insight"
  else
    echo "ALERT"
  fi
  exit 1
else
  if [[ "$QUIET" == "false" ]]; then
    echo "OK: ${ELAPSED}m since last reflection (threshold: ${THRESHOLD}m)"
  else
    echo "OK"
  fi
  exit 0
fi
