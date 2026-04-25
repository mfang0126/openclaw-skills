#!/usr/bin/env bash
# reflection read [n] [--tag <tag>] [--layer <1|2|3>] [--all] [--domain <name>]
# Read recent reflections. Default: last 5 from Layer 3 (daily logs)

set -euo pipefail

MEMORY_DIR="${REFLECTION_MEMORY:-./memory}"
SOUL_FILE="${REFLECTION_SOUL:-./SOUL.md}"
REVIEW_FILE="$MEMORY_DIR/self-review.md"

COUNT=5
TAG=""
LAYER="3"
ALL=false
DOMAIN=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tag)    TAG="${2:?--tag requires a value}"; shift 2 ;;
    --layer)  LAYER="${2:?--layer requires 1, 2, or 3}"; shift 2 ;;
    --all)    ALL=true; shift ;;
    --domain) DOMAIN="${2:?--domain requires a name}"; shift 2 ;;
    [0-9]*)   COUNT="$1"; shift ;;
    *)        echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ "$ALL" == "true" ]]; then
  echo "=== Layer 1: Golden Rules (SOUL.md) ==="
  if [[ -f "$SOUL_FILE" ]]; then
    head -50 "$SOUL_FILE"
  else
    echo "(no SOUL.md found)"
  fi
  echo ""
  echo "=== Layer 2: Active Lessons (self-review.md) ==="
  if [[ -f "$REVIEW_FILE" ]]; then
    cat "$REVIEW_FILE"
  else
    echo "(no self-review.md found)"
  fi
  echo ""
  echo "=== Layer 3: Recent Daily Logs ==="
  LAYER="3"
fi

if [[ "$LAYER" == "1" && "$ALL" == "false" ]]; then
  if [[ -f "$SOUL_FILE" ]]; then
    head -50 "$SOUL_FILE"
  else
    echo "No SOUL.md found at $SOUL_FILE"
  fi
  exit 0
fi

if [[ "$LAYER" == "2" && "$ALL" == "false" ]]; then
  if [[ -f "$REVIEW_FILE" ]]; then
    cat "$REVIEW_FILE"
  else
    echo "No self-review.md found at $REVIEW_FILE"
  fi
  exit 0
fi

# Layer 3: daily logs (search domain-specific dirs if --domain given)
SEARCH_DIR="$MEMORY_DIR"
if [[ -n "$DOMAIN" ]]; then
  SEARCH_DIR="$MEMORY_DIR/domains/$DOMAIN"
  if [[ ! -d "$SEARCH_DIR" ]]; then
    echo "No domain '$DOMAIN' found in $MEMORY_DIR/domains/"
    exit 0
  fi
fi

if [[ ! -d "$SEARCH_DIR" ]]; then
  echo "No memory directory at $SEARCH_DIR"
  exit 0
fi

# Find log files, newest first
LOG_FILES=$(find "$SEARCH_DIR" -name '????-??-??.md' -type f 2>/dev/null | sort -r | head -"$COUNT")

if [[ -z "$LOG_FILES" ]]; then
  echo "No daily logs found in $MEMORY_DIR"
  exit 0
fi

for f in $LOG_FILES; do
  if [[ -n "$TAG" ]]; then
    # Filter by tag
    if grep -q "\] $TAG" "$f" 2>/dev/null; then
      echo "--- $(basename "$f" .md) ---"
      grep -A 4 "\] $TAG" "$f"
      echo ""
    fi
  else
    echo "--- $(basename "$f" .md) ---"
    cat "$f"
    echo ""
  fi
done
