#!/usr/bin/env bash
# reflection promote <pattern-text>
# Promote a lesson: Layer 3→2 (daily log → self-review.md) or Layer 2→1 (self-review → SOUL.md)
# Searches all layers for matching text, promotes to next layer up.

set -euo pipefail

MEMORY_DIR="${REFLECTION_MEMORY:-./memory}"
SOUL_FILE="${REFLECTION_SOUL:-./SOUL.md}"
REVIEW_FILE="$MEMORY_DIR/self-review.md"

PATTERN="${1:?Usage: reflection promote <pattern-text>}"

# Search Layer 3 first (daily logs)
FOUND_IN=""
FOUND_LINE=""
for f in $(find "$MEMORY_DIR" -name '????-??-??.md' -type f 2>/dev/null | sort -r); do
  MATCH=$(grep -n "$PATTERN" "$f" 2>/dev/null | head -1 || true)
  if [[ -n "$MATCH" ]]; then
    FOUND_IN="$f"
    FOUND_LINE=$(echo "$MATCH" | cut -d: -f2-)
    break
  fi
done

if [[ -n "$FOUND_IN" ]]; then
  # Promote Layer 3 → Layer 2
  mkdir -p "$MEMORY_DIR"
  [[ -f "$REVIEW_FILE" ]] || echo "# Active Lessons" > "$REVIEW_FILE"
  echo "" >> "$REVIEW_FILE"
  echo "- $FOUND_LINE (promoted $(date +%Y-%m-%d))" >> "$REVIEW_FILE"
  echo "✓ Promoted to Layer 2 (self-review.md): $FOUND_LINE"
  exit 0
fi

# Search Layer 2
if [[ -f "$REVIEW_FILE" ]]; then
  MATCH=$(grep -n "$PATTERN" "$REVIEW_FILE" 2>/dev/null | head -1 || true)
  if [[ -n "$MATCH" ]]; then
    LINE=$(echo "$MATCH" | cut -d: -f2-)
    # Promote Layer 2 → Layer 1 (append to SOUL.md)
    echo "" >> "$SOUL_FILE"
    echo "- $LINE (promoted $(date +%Y-%m-%d))" >> "$SOUL_FILE"
    echo "✓ Promoted to Layer 1 (SOUL.md): $LINE"
    exit 0
  fi
fi

echo "Pattern not found: $PATTERN" >&2
exit 1
