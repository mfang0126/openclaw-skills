#!/bin/bash
# Check if current directory is a valid Next.js App Router project
# Usage: ./scripts/check-structure.sh [project-dir]
DIR="${1:-.}"

echo "=== Next.js App Router Structure Check ==="
echo ""

[ -d "$DIR/app" ] && echo "✅ app/ directory found" || echo "❌ app/ directory missing (not App Router?)"
( [ -f "$DIR/next.config.js" ] || [ -f "$DIR/next.config.ts" ] ) && echo "✅ next.config found" || echo "⚠️  next.config not found"
[ -f "$DIR/package.json" ] && echo "✅ package.json found" || echo "❌ package.json missing"

echo ""
echo "=== Key Files ==="
for f in app/layout.tsx app/page.tsx app/globals.css; do
  [ -f "$DIR/$f" ] && echo "✅ $f" || echo "⚠️  $f missing"
done

echo ""
echo "=== Next.js Version ==="
if [ -f "$DIR/package.json" ]; then
  grep '"next"' "$DIR/package.json" | head -1
fi
