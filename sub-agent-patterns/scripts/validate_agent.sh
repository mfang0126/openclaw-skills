#!/bin/bash
# validate_agent.sh — Check that a .claude/agents/*.md file has required frontmatter
# Usage: ./scripts/validate_agent.sh <agent-file.md>

set -e

FILE="${1:?Usage: validate_agent.sh <agent-file.md>}"

if [ ! -f "$FILE" ]; then
  echo "❌ File not found: $FILE"
  exit 1
fi

echo "Validating: $FILE"
ERRORS=0

# Check for frontmatter
if ! grep -q "^---" "$FILE"; then
  echo "❌ Missing YAML frontmatter (no --- delimiter)"
  ERRORS=$((ERRORS+1))
fi

# Check required fields
for field in "name:" "description:"; do
  if ! grep -q "^$field" "$FILE"; then
    echo "❌ Missing required field: $field"
    ERRORS=$((ERRORS+1))
  else
    echo "✅ Found: $field"
  fi
done

# Check tools field (warning only)
if ! grep -q "^tools:" "$FILE"; then
  echo "⚠️  No 'tools:' field — agent will inherit all tools (includes Bash, may cause approval spam)"
fi

# Check model field (suggestion)
if ! grep -q "^model:" "$FILE"; then
  echo "⚠️  No 'model:' field — defaults to sonnet (usually correct)"
fi

if [ "$ERRORS" -eq 0 ]; then
  echo "✅ Agent config is valid"
  exit 0
else
  echo "❌ $ERRORS error(s) found"
  exit 1
fi
