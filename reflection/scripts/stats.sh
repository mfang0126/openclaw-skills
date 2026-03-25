#!/usr/bin/env bash
# reflection stats — show memory statistics across all 3 layers

set -euo pipefail

MEMORY_DIR="${REFLECTION_MEMORY:-./memory}"
SOUL_FILE="${REFLECTION_SOUL:-./SOUL.md}"
STATE_FILE="${REFLECTION_STATE:-$HOME/.openclaw/reflection-state.json}"
REVIEW_FILE="$MEMORY_DIR/self-review.md"

echo "📊 Reflection Memory Stats"
echo ""

# Layer 1: Golden Rules
echo "Layer 1 — Golden Rules (SOUL.md):"
if [[ -f "$SOUL_FILE" ]]; then
  RULES=$(grep -c '^\s*-' "$SOUL_FILE" 2>/dev/null || echo 0)
  LINES=$(wc -l < "$SOUL_FILE" | tr -d ' ')
  echo "  Rules: $RULES / 50 max"
  echo "  Lines: $LINES"
else
  echo "  (not found)"
fi
echo ""

# Layer 2: Active Lessons
echo "Layer 2 — Active Lessons (self-review.md):"
if [[ -f "$REVIEW_FILE" ]]; then
  ENTRIES=$(grep -c '^\s*-' "$REVIEW_FILE" 2>/dev/null || echo 0)
  LINES=$(wc -l < "$REVIEW_FILE" | tr -d ' ')
  TOPICS=$(grep -c '^##' "$REVIEW_FILE" 2>/dev/null || echo 0)
  echo "  Entries: $ENTRIES"
  echo "  Topics: $TOPICS"
  echo "  Lines: $LINES / 100 max"
else
  echo "  (not found)"
fi
echo ""

# Layer 3: Raw Logs
echo "Layer 3 — Daily Logs (memory/*.md):"
if [[ -d "$MEMORY_DIR" ]]; then
  LOG_COUNT=$(find "$MEMORY_DIR" -name '????-??-??.md' -type f 2>/dev/null | wc -l | tr -d ' ')
  if (( LOG_COUNT > 0 )); then
    NEWEST=$(find "$MEMORY_DIR" -name '????-??-??.md' -type f 2>/dev/null | sort -r | head -1 | xargs -I{} basename {} .md 2>/dev/null)
    OLDEST=$(find "$MEMORY_DIR" -name '????-??-??.md' -type f 2>/dev/null | sort | head -1 | xargs -I{} basename {} .md 2>/dev/null)
    TOTAL_ENTRIES=$(find "$MEMORY_DIR" -name '????-??-??.md' -type f 2>/dev/null -exec grep -c '^## ' {} + 2>/dev/null | awk -F: '{sum+=$NF} END{print sum+0}')
    echo "  Log files: $LOG_COUNT"
    echo "  Date range: $OLDEST → $NEWEST"
    echo "  Total entries: $TOTAL_ENTRIES"
  else
    echo "  (no daily logs)"
  fi
else
  echo "  (memory/ directory not found)"
fi
echo ""

# State
echo "Session State:"
if [[ -f "$STATE_FILE" ]]; then
  CORRECTIONS=$(jq -r '.session_corrections // 0' "$STATE_FILE")
  LAST_LOG=$(jq -r '.last_log // 0' "$STATE_FILE")
  if (( LAST_LOG > 0 )); then
    LAST_LOG_AGO=$(( ($(date +%s) - LAST_LOG) / 60 ))
    echo "  Session corrections: $CORRECTIONS"
    echo "  Last logged: ${LAST_LOG_AGO}m ago"
  else
    echo "  Session corrections: $CORRECTIONS"
    echo "  Last logged: never"
  fi
else
  echo "  (no state file)"
fi
