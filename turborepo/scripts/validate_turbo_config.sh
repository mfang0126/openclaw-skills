#!/bin/bash
# validate_turbo_config.sh — Check that turbo.json exists and has required structure
# Usage: ./scripts/validate_turbo_config.sh [repo_root]
# Default: current directory

set -e

REPO_ROOT="${1:-$(pwd)}"
TURBO_JSON="$REPO_ROOT/turbo.json"
ERRORS=0

echo "Checking Turborepo config in: $REPO_ROOT"
echo "---"

# Check turbo.json exists
if [ ! -f "$TURBO_JSON" ]; then
  echo "❌ turbo.json not found at $TURBO_JSON"
  exit 1
fi

echo "✅ turbo.json exists"

# Check for $schema (best practice)
if ! grep -q '"\$schema"' "$TURBO_JSON"; then
  echo "⚠️  Missing \$schema field (recommended: https://turbo.build/schema.json)"
fi

# Check for 'tasks' key (required in Turbo v2+)
if ! grep -q '"tasks"' "$TURBO_JSON"; then
  echo "❌ Missing 'tasks' key — required in Turborepo v2+"
  ERRORS=$((ERRORS+1))
else
  echo "✅ 'tasks' key present"
fi

# Check for root tasks (warn — usually wrong)
if grep -q '"//#' "$TURBO_JSON"; then
  echo "⚠️  Root tasks (//#taskname) found — ensure these truly cannot live in packages"
fi

# Check package.json files delegate to turbo
ROOT_PKG="$REPO_ROOT/package.json"
if [ -f "$ROOT_PKG" ]; then
  if grep -q '"build".*turbo run' "$ROOT_PKG"; then
    echo "✅ Root package.json delegates to turbo run"
  elif grep -q '"build"' "$ROOT_PKG"; then
    echo "⚠️  Root package.json has 'build' script — verify it uses 'turbo run build'"
  fi
fi

if [ "$ERRORS" -eq 0 ]; then
  echo "---"
  echo "✅ Config looks valid"
  exit 0
else
  echo "---"
  echo "❌ $ERRORS error(s) found"
  exit 1
fi
