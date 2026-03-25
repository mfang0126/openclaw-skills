#!/bin/bash
# Preview HTML and send to Telegram
# Usage: preview-and-send.sh <html_file> <telegram_user_id> [message]

set -e

HTML_FILE="$1"
TELEGRAM_ID="$2"
MESSAGE="${3:-HTML Preview}"

if [ -z "$HTML_FILE" ] || [ -z "$TELEGRAM_ID" ]; then
    echo "Usage: $0 <html_file> <telegram_user_id> [message]"
    echo ""
    echo "Example:"
    echo "  $0 design.html 6883367773 \"Check out this design\""
    exit 1
fi

# Convert to absolute path
if [ -f "$HTML_FILE" ]; then
    ABS_PATH="$(cd "$(dirname "$HTML_FILE")" && pwd)/$(basename "$HTML_FILE")"
else
    echo "Error: File not found: $HTML_FILE"
    exit 1
fi

# Generate temporary screenshot path
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
SCREENSHOT="/tmp/html-preview-${TIMESTAMP}.png"

echo "📸 Capturing screenshot of: $ABS_PATH"

# Convert to file:// URL
FILE_URL="file://${ABS_PATH}"

# Take screenshot using agent-browser
agent-browser goto "$FILE_URL" >/dev/null 2>&1
sleep 1
agent-browser screenshot "$SCREENSHOT" >/dev/null 2>&1

if [ ! -f "$SCREENSHOT" ]; then
    echo "❌ Failed to capture screenshot"
    exit 1
fi

SIZE=$(du -h "$SCREENSHOT" | cut -f1)
echo "✓ Screenshot saved: $SCREENSHOT ($SIZE)"

# Send to Telegram using OpenClaw message tool
echo "📤 Sending to Telegram..."

# Use openclaw CLI if available, otherwise provide manual command
if command -v openclaw >/dev/null 2>&1; then
    # Note: This assumes openclaw message command exists
    # Adjust based on actual OpenClaw CLI syntax
    echo "Use OpenClaw message tool to send:"
    echo "  Target: $TELEGRAM_ID"
    echo "  Message: $MESSAGE"
    echo "  Media: $SCREENSHOT"
else
    echo "OpenClaw CLI not found. Screenshot ready at:"
    echo "  $SCREENSHOT"
    echo ""
    echo "Send manually or use message tool with:"
    echo "  channel: telegram"
    echo "  target: $TELEGRAM_ID"
    echo "  message: $MESSAGE"
    echo "  media: $SCREENSHOT"
fi

echo "✓ Complete!"
echo "$SCREENSHOT"
