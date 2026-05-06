#!/usr/bin/env bash
# mlx-asr transcribe script
set -euo pipefail

PORT="${MLX_ASR_PORT:-8765}"
API_KEY="${MLX_ASR_API_KEY:-local}"
FORMAT="txt"
LANGUAGE=""
OUTPUT=""
INPUT=""
DEBUG=0
DEBUG_LOG="$HOME/.mlx-asr.log"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOTWORDS_FILE="$SCRIPT_DIR/../hotwords.txt"

# Get process RSS in KB
get_rss() {
    local pid="$1"
    ps -o rss= -p "$pid" 2>/dev/null | tr -d ' ' || echo "0"
}

debug_log() {
    [[ "$DEBUG" -eq 1 ]] && echo "$1" >> "$DEBUG_LOG"
}

usage() {
    echo "Usage: mlx-asr transcribe <input> [options]"
    echo ""
    echo "Options:"
    echo "  --format txt|srt|vtt   Output format (default: txt)"
    echo "  --language zh|en|...   Language hint"
    echo "  --output <path>        Output file (default: stdout)"
    echo "  --debug                Enable debug logging to $DEBUG_LOG"
    echo "  --help                 Show this help"
    exit 1
}

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --format) FORMAT="$2"; shift 2 ;;
        --language) LANGUAGE="$2"; shift 2 ;;
        --output) OUTPUT="$2"; shift 2 ;;
        --debug) DEBUG=1; shift ;;
        --help|-h) usage ;;
        -*)
            echo "Unknown option: $1"
            usage
            ;;
        *)
            if [[ -z "$INPUT" ]]; then
                INPUT="$1"
            else
                echo "Multiple inputs not supported"
                usage
            fi
            shift
            ;;
    esac
done

if [[ -z "$INPUT" ]]; then
    echo "Error: No input file specified"
    usage
fi
if [[ ! -f "$INPUT" ]]; then
    echo "Error: File not found: $INPUT"
    exit 1
fi

# File info
INPUT_SIZE=$(stat -f%z "$INPUT" 2>/dev/null || stat -c%s "$INPUT" 2>/dev/null)
CALL_START=$(python3 -c "import time; print(time.time())")

# Check server is running, auto-start if not
if ! curl -sf "http://localhost:$PORT/health" > /dev/null 2>&1; then
    echo "Server not running, starting..." >&2
    "$SCRIPT_DIR/serve.sh" start
fi

# Get server PID for memory tracking
SERVER_PID=""
if [[ -f "$HOME/.mlx-asr-server.pid" ]]; then
    SERVER_PID=$(cat "$HOME/.mlx-asr-server.pid")
fi

RSS_BEFORE="0"
if [[ -n "$SERVER_PID" ]] && kill -0 "$SERVER_PID" 2>/dev/null; then
    RSS_BEFORE=$(get_rss "$SERVER_PID")
fi

# Preprocess audio: convert to 16kHz mono WAV via ffmpeg
TMP_WAV=$(mktemp /tmp/mlx-asr-XXXXXX.wav)
trap 'rm -f "$TMP_WAV"' EXIT

FFMPEG_START=$(python3 -c "import time; print(time.time())")
ffmpeg -i "$INPUT" -ar 16000 -ac 1 -nostdin -y "$TMP_WAV" -loglevel error
FFMPEG_END=$(python3 -c "import time; print(time.time())")
FFMPEG_ELAPSED=$(python3 -c "print(f'{$FFMPEG_END - $FFMPEG_START:.2f}s')")

# Build curl request to OpenAI-compatible endpoint
OPENAI_FORMAT="$FORMAT"
if [[ "$FORMAT" == "txt" ]]; then
    OPENAI_FORMAT="text"
fi

# Build prompt from hotwords
PROMPT=""
if [[ -f "$HOTWORDS_FILE" ]]; then
    PROMPT=$(paste -sd ',' "$HOTWORDS_FILE" | sed 's/,$//; s/^,//')
fi

CURL_ARGS=(
    -s
    -w "\n%{time_total}"
    -X POST "http://localhost:$PORT/v1/audio/transcriptions"
    -H "Authorization: Bearer $API_KEY"
    -F "file=@$TMP_WAV"
    -F "response_format=$OPENAI_FORMAT"
)
[[ -n "$LANGUAGE" ]] && CURL_ARGS+=(-F "language=$LANGUAGE")
[[ -n "$PROMPT" ]] && CURL_ARGS+=(-F "prompt=$PROMPT")

SERVER_START=$(python3 -c "import time; print(time.time())")
CURL_OUT=$(curl "${CURL_ARGS[@]}")
SERVER_END=$(python3 -c "import time; print(time.time())")
SERVER_ELAPSED=$(python3 -c "print(f'{$SERVER_END - $SERVER_START:.2f}s')")

# Extract response time from curl -w output (last line)
RESPONSE_TIME=$(echo "$CURL_OUT" | tail -1)
RESULT=$(echo "$CURL_OUT" | sed '$d')

# Get RSS after call
RSS_AFTER="0"
if [[ -n "$SERVER_PID" ]] && kill -0 "$SERVER_PID" 2>/dev/null; then
    RSS_AFTER=$(get_rss "$SERVER_PID")
fi

CALL_END=$(python3 -c "import time; print(time.time())")

# Check for errors
STATUS="success"
if echo "$RESULT" | python3 -c "import sys,json; d=json.load(sys.stdin); sys.exit(0 if 'error' in d else 1)" 2>/dev/null; then
    STATUS="failed"
    echo "Error: $RESULT" >&2
    debug_log "[$(date -Iseconds)] ERROR: $RESULT"
    exit 1
fi

# Output
OUTPUT_LEN=${#RESULT}
if [[ -n "$OUTPUT" ]]; then
    echo "$RESULT" > "$OUTPUT"
    echo "Written to $OUTPUT" >&2
else
    echo "$RESULT"
fi

# Debug logging
debug_log "=== transcribe @ $(date -Iseconds) ==="
debug_log "  input: $INPUT ($INPUT_SIZE bytes)"
debug_log "  ffmpeg: $FFMPEG_ELAPSED"
debug_log "  server_call: $SERVER_ELAPSED"
debug_log "  response_time: ${RESPONSE_TIME}s"
debug_log "  rss_before: ${RSS_BEFORE}KB  rss_after: ${RSS_AFTER}KB"
debug_log "  format: $FORMAT  output_len: $OUTPUT_LEN  status: $STATUS"
