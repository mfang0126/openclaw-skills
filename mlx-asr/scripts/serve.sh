#!/usr/bin/env bash
# mlx-asr server management script
set -euo pipefail

MLX_ENV="$HOME/mlx-env"
MLX_BIN="$MLX_ENV/bin/mlx-qwen3-asr"
PID_FILE="$HOME/.mlx-asr-server.pid"
LOG_FILE="$HOME/.mlx-asr-server.log"
METRICS_LOG="$HOME/.mlx-asr-server-metrics.log"
PORT="${MLX_ASR_PORT:-8765}"
API_KEY="${MLX_ASR_API_KEY:-local}"
MODEL="Qwen/Qwen3-ASR-1.7B"
DEBUG=0
METRICS_PID_FILE="$HOME/.mlx-asr-metrics.pid"

usage() {
    echo "Usage: mlx-asr serve {start|stop|restart|status} [--small] [--debug]"
    echo ""
    echo "Options:"
    echo "  --small   Use 0.6B model instead of default 1.7B"
    echo "  --debug   Verbose logging + periodic memory metrics"
    exit 1
}

is_running() {
    [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null
}

# Parse global flags
for arg in "$@"; do
    case "$arg" in
        --small) MODEL="Qwen/Qwen3-ASR-0.6B" ;;
        --debug) DEBUG=1 ;;
    esac
done

# Background metrics collector
start_metrics() {
    stop_metrics 2>/dev/null || true
    (
        while kill -0 "$(cat "$PID_FILE")" 2>/dev/null; do
            PID=$(cat "$PID_FILE")
            STATS=$(ps -o rss=,vsize= -p "$PID" 2>/dev/null | tr -s ' ' | sed 's/^ //')
            if [[ -n "$STATS" ]]; then
                echo "$(date -Iseconds) $STATS" >> "$METRICS_LOG"
            fi
            sleep 60
        done
    ) &
    echo $! > "$METRICS_PID_FILE"
}

stop_metrics() {
    if [[ -f "$METRICS_PID_FILE" ]]; then
        kill "$(cat "$METRICS_PID_FILE")" 2>/dev/null || true
        rm -f "$METRICS_PID_FILE"
    fi
}

case "${1:-}" in
    start)
        if is_running; then
            echo "Server already running (PID $(cat "$PID_FILE"))"
            exit 0
        fi

        START_TS=$(date -Iseconds)
        echo "Starting mlx-asr server (model=$MODEL, port=$PORT)..."
        
        if [[ "$DEBUG" -eq 1 ]]; then
            echo "[$START_TS] Debug mode: logging to $LOG_FILE + metrics to $METRICS_LOG" >&2
            "$MLX_BIN" serve \
                --host 127.0.0.1 \
                --port "$PORT" \
                --api-key "$API_KEY" \
                --model "$MODEL" \
                >> "$LOG_FILE" 2>&1 &
        else
            nohup "$MLX_BIN" serve \
                --host 127.0.0.1 \
                --port "$PORT" \
                --api-key "$API_KEY" \
                --model "$MODEL" \
                > "$LOG_FILE" 2>&1 &
        fi
        echo $! > "$PID_FILE"

        # Wait for server to be ready
        for i in $(seq 1 30); do
            if curl -sf "http://localhost:$PORT/health" > /dev/null 2>&1; then
                READY_TS=$(date -Iseconds)
                echo "Server ready (PID $(cat "$PID_FILE")) started=$START_TS ready=$READY_TS"
                # Start metrics collector in debug mode
                if [[ "$DEBUG" -eq 1 ]]; then
                    start_metrics
                    echo "Metrics collector started (PID $(cat "$METRICS_PID_FILE"))"
                fi
                exit 0
            fi
            sleep 1
        done
        echo "ERROR: Server failed to start. Check $LOG_FILE"
        exit 1
        ;;

    stop)
        stop_metrics
        if ! is_running; then
            echo "Server not running"
            rm -f "$PID_FILE"
            exit 0
        fi
        PID=$(cat "$PID_FILE")
        echo "Stopping server (PID $PID)..."
        kill "$PID" 2>/dev/null || true
        for i in $(seq 1 10); do
            if ! kill -0 "$PID" 2>/dev/null; then
                rm -f "$PID_FILE"
                echo "Server stopped"
                exit 0
            fi
            sleep 0.5
        done
        kill -9 "$PID" 2>/dev/null || true
        rm -f "$PID_FILE"
        echo "Server killed"
        ;;

    restart)
        "$0" stop
        sleep 1
        "$0" start "${@:2}"
        ;;

    status)
        if is_running; then
            PID=$(cat "$PID_FILE")
            echo "Server running (PID $PID)"
            curl -sf "http://localhost:$PORT/health" 2>/dev/null | python3 -m json.tool 2>/dev/null || echo "(health endpoint unreachable)"
            # Show uptime and memory
            STATS=$(ps -o rss=,vsize=,etime= -p "$PID" 2>/dev/null)
            if [[ -n "$STATS" ]]; then
                echo "Process: $STATS"
            fi
        else
            echo "Server not running"
            exit 1
        fi
        ;;

    *)
        usage
        ;;
esac
