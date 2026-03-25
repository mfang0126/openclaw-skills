#!/bin/bash
# snap.sh — Take a screenshot of a URL using the Snap Screenshot API
# Usage: ./snap.sh <url> <api_key> [output_file]
# Example: ./snap.sh https://github.com snap_abc123 screenshot.png

set -e

URL="${1:?Usage: snap.sh <url> <api_key> [output_file]}"
API_KEY="${2:?Usage: snap.sh <url> <api_key> [output_file]}"
OUTPUT="${3:-screenshot.png}"

API="https://snap.llm.kaveenk.com"

echo "Taking screenshot of: $URL"
echo "Output: $OUTPUT"

HTTP_STATUS=$(curl -s -o "$OUTPUT" -w "%{http_code}" \
  -X POST "$API/api/screenshot" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"url\": \"$URL\"}")

if [ "$HTTP_STATUS" = "200" ]; then
  echo "✅ Screenshot saved to $OUTPUT"
else
  echo "❌ Failed with HTTP $HTTP_STATUS"
  cat "$OUTPUT"
  exit 1
fi
