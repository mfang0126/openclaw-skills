#!/bin/bash
# HTML Screenshot Script
# Usage: screenshot.sh <url_or_file> <output_path> [viewport|--full-page]

set -e

URL="$1"
OUTPUT="$2"
VIEWPORT="${3:-1440x900}"

if [ -z "$URL" ] || [ -z "$OUTPUT" ]; then
    echo "Usage: $0 <url_or_file> <output_path> [viewport|--full-page]"
    echo ""
    echo "Examples:"
    echo "  $0 /path/to/file.html output.png"
    echo "  $0 https://example.com output.png"
    echo "  $0 file.html output.png 1920x1080"
    echo "  $0 file.html output.png --full-page"
    exit 1
fi

# Convert relative file paths to absolute file:// URLs
if [ -f "$URL" ]; then
    URL="file://$(cd "$(dirname "$URL")" && pwd)/$(basename "$URL")"
fi

# Navigate to the page
echo "Opening: $URL"
agent-browser goto "$URL" >/dev/null 2>&1

# Wait for page to load
sleep 1

# Set viewport if specified
if [[ "$VIEWPORT" =~ ^[0-9]+x[0-9]+$ ]]; then
    WIDTH="${VIEWPORT%x*}"
    HEIGHT="${VIEWPORT#*x}"
    agent-browser eval "window.resizeTo($WIDTH, $HEIGHT)" >/dev/null 2>&1
fi

# Take screenshot
if [ "$VIEWPORT" = "--full-page" ]; then
    echo "Capturing full-page screenshot..."
    agent-browser screenshot --full "$OUTPUT"
else
    echo "Capturing screenshot..."
    agent-browser screenshot "$OUTPUT"
fi

# Verify output
if [ -f "$OUTPUT" ]; then
    SIZE=$(du -h "$OUTPUT" | cut -f1)
    echo "✓ Screenshot saved: $OUTPUT ($SIZE)"
    echo "$OUTPUT"
else
    echo "✗ Failed to save screenshot"
    exit 1
fi
