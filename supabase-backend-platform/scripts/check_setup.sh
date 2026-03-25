#!/bin/bash
# check_setup.sh — Verify Supabase project environment is configured
# Usage: ./scripts/check_setup.sh

echo "Checking Supabase environment setup..."
echo "---"
ERRORS=0

# Check env vars
for var in NEXT_PUBLIC_SUPABASE_URL NEXT_PUBLIC_SUPABASE_ANON_KEY; do
  if [ -n "${!var}" ]; then
    echo "✅ $var is set"
  else
    echo "❌ $var is not set"
    ERRORS=$((ERRORS+1))
  fi
done

# Warn about service role key
if [ -n "$SUPABASE_SERVICE_ROLE_KEY" ]; then
  echo "✅ SUPABASE_SERVICE_ROLE_KEY is set (server-only — never expose client-side)"
else
  echo "⚠️  SUPABASE_SERVICE_ROLE_KEY not set (needed for admin operations)"
fi

# Check supabase CLI
if command -v supabase &> /dev/null; then
  echo "✅ supabase CLI: $(supabase --version 2>/dev/null || echo 'installed')"
else
  echo "⚠️  supabase CLI not installed (run: npm install -D supabase)"
fi

# Check supabase-js
if [ -f "node_modules/@supabase/supabase-js/package.json" ]; then
  VERSION=$(node -e "console.log(require('./node_modules/@supabase/supabase-js/package.json').version)" 2>/dev/null)
  echo "✅ @supabase/supabase-js: v$VERSION"
else
  echo "❌ @supabase/supabase-js not installed (run: npm install @supabase/supabase-js)"
  ERRORS=$((ERRORS+1))
fi

echo "---"
if [ "$ERRORS" -eq 0 ]; then
  echo "✅ Supabase setup looks good"
else
  echo "❌ $ERRORS issue(s) found"
fi
