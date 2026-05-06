#!/usr/bin/env bash
# mlx-asr healthcheck
set -euo pipefail

PORT="${MLX_ASR_PORT:-8765}"
VERBOSE=0
PID_FILE="$HOME/.mlx-asr-server.pid"

for arg in "$@"; do
    case "$arg" in
        --verbose|-v) VERBOSE=1 ;;
    esac
done

if ! curl -sf "http://localhost:$PORT/health" > /dev/null 2>&1; then
    echo "Server not responding on port $PORT"
    exit 1
fi

if [[ "$VERBOSE" -eq 1 ]]; then
    echo "✅ Server healthy on port $PORT"
    # Show process info
    if [[ -f "$PID_FILE" ]]; then
        PID=$(cat "$PID_FILE")
        if kill -0 "$PID" 2>/dev/null; then
            echo "PID: $PID"
            ps -o rss=,vsize=,etime= -p "$PID" 2>/dev/null | \
                awk '{printf "Memory: %.1fMB RSS / %.1fMB VIRT\nUptime: %s\n", $1/1024, $2/1024, $3}'
        fi
    fi
    # Show health endpoint response
    echo ""
    echo "Health response:"
    curl -sf "http://localhost:$PORT/health" 2>/dev/null | python3 -m json.tool 2>/dev/null || echo "(no json response)"
else
    curl -sf "http://localhost:$PORT/health" > /dev/null
fi
