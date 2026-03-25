#!/bin/bash
# Smart Screenshot Sender - 根据渠道自动选择发送方式
# Usage: smart-send.sh <screenshot_path> <channel> [message]

SCREENSHOT="$1"
CHANNEL="${2:-terminal}"
MESSAGE="${3:-Screenshot}"

if [ ! -f "$SCREENSHOT" ]; then
    echo "Error: Screenshot not found: $SCREENSHOT"
    exit 1
fi

case "$CHANNEL" in
    telegram)
        # Telegram: 发送图片（省 token）
        echo "📤 Sending to Telegram..."
        echo "USE message tool:"
        echo "  action: send"
        echo "  channel: telegram"
        echo "  media: $SCREENSHOT"
        echo "  message: $MESSAGE"
        ;;
    
    webchat|browser|web)
        # 浏览器: 内联显示（Read tool 会自动显示）
        echo "🌐 Displaying in browser..."
        echo "USE Read tool:"
        echo "  path: $SCREENSHOT"
        ;;
    
    terminal|cli|console)
        # Terminal: 只给路径
        echo "📂 Screenshot saved:"
        echo "$SCREENSHOT"
        echo ""
        echo "Open with: open $SCREENSHOT"
        ;;
    
    *)
        # 未知渠道，默认给路径
        echo "Screenshot: $SCREENSHOT"
        ;;
esac
