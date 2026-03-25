#!/usr/bin/env bash
# reflection demote <pattern-text>
# Demote a rule: Layer 1→2 (SOUL.md → self-review.md) or Layer 2→3 (self-review → archive note)

set -euo pipefail

MEMORY_DIR="${REFLECTION_MEMORY:-./memory}"
SOUL_FILE="${REFLECTION_SOUL:-./SOUL.md}"
REVIEW_FILE="$MEMORY_DIR/self-review.md"

PATTERN="${1:?Usage: reflection demote <pattern-text>}"

# Search Layer 1 first (SOUL.md)
if [[ -f "$SOUL_FILE" ]]; then
  MATCH=$(grep -n "$PATTERN" "$SOUL_FILE" 2>/dev/null | head -1 || true)
  if [[ -n "$MATCH" ]]; then
    LINE_NUM=$(echo "$MATCH" | cut -d: -f1)
    LINE_TEXT=$(echo "$MATCH" | cut -d: -f2-)
    # Remove from SOUL.md
    sed -i.bak "${LINE_NUM}d" "$SOUL_FILE" && rm -f "${SOUL_FILE}.bak"
    # Add to Layer 2
    mkdir -p "$MEMORY_DIR"
    [[ -f "$REVIEW_FILE" ]] || echo "# Active Lessons" > "$REVIEW_FILE"
    echo "- $LINE_TEXT (demoted $(date +%Y-%m-%d))" >> "$REVIEW_FILE"
    echo "✓ Demoted from Layer 1 → Layer 2: $LINE_TEXT"
    exit 0
  fi
fi

# Search Layer 2
if [[ -f "$REVIEW_FILE" ]]; then
  MATCH=$(grep -n "$PATTERN" "$REVIEW_FILE" 2>/dev/null | head -1 || true)
  if [[ -n "$MATCH" ]]; then
    LINE_NUM=$(echo "$MATCH" | cut -d: -f1)
    LINE_TEXT=$(echo "$MATCH" | cut -d: -f2-)
    sed -i.bak "${LINE_NUM}d" "$REVIEW_FILE" && rm -f "${REVIEW_FILE}.bak"
    # Log demotion to today's daily file
    TODAY=$(date +%Y-%m-%d)
    LOG_FILE="$MEMORY_DIR/$TODAY.md"
    [[ -f "$LOG_FILE" ]] || echo "# Reflection Log — $TODAY" > "$LOG_FILE"
    echo "" >> "$LOG_FILE"
    echo "## [$(date +%H:%M)] demoted" >> "$LOG_FILE"
    echo "- **Demoted:** $LINE_TEXT" >> "$LOG_FILE"
    echo "- **Reason:** Unused or no longer applicable" >> "$LOG_FILE"
    echo "✓ Demoted from Layer 2 → Layer 3: $LINE_TEXT"
    exit 0
  fi
fi

echo "Pattern not found: $PATTERN" >&2
exit 1
