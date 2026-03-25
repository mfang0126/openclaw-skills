#!/bin/bash
# run-review.sh — Supplement AI review with static analysis tools
# Usage: ./scripts/run-review.sh <python_file>

set -e

FILE="$1"

if [ -z "$FILE" ]; then
  echo "Usage: $0 <python_file>"
  exit 1
fi

if [ ! -f "$FILE" ]; then
  echo "File not found: $FILE"
  exit 1
fi

echo "=== mypy (type checking) ==="
if command -v mypy &>/dev/null; then
  mypy "$FILE" --strict 2>&1 || true
else
  echo "mypy not installed (pip install mypy)"
fi

echo ""
echo "=== flake8 (PEP8 style) ==="
if command -v flake8 &>/dev/null; then
  flake8 "$FILE" --max-line-length=79 2>&1 || true
else
  echo "flake8 not installed (pip install flake8)"
fi
