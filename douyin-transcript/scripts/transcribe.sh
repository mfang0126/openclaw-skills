#!/usr/bin/env bash
# transcribe.sh — 视频转文字脚本（MLX Qwen3-ASR）
# 用法: bash transcribe.sh <video_file_path>
#
# 流程:
#   1. ffmpeg 从视频提取 16kHz mono WAV
#   2. 读取热词库 hotwords.txt，通过 --context 注入 ASR
#   3. mlx-qwen3-asr 本地转文字（Apple Silicon MLX 原生）
#   4. 输出 TXT 到 ~/.openclaw/shared/video-transcripts/transcripts/
#
# 输出文件名: YYYY-MM-DD-{video-title}.txt

set -euo pipefail

# ─── 参数检查 ─────────────────────────────────────────────────────────────────
if [[ $# -lt 1 ]]; then
    echo "错误: 缺少参数" >&2
    echo "用法: bash transcribe.sh <video_file_path>" >&2
    exit 1
fi

VIDEO_FILE="$1"

if [[ ! -f "$VIDEO_FILE" ]]; then
    echo "错误: 文件不存在: $VIDEO_FILE" >&2
    exit 1
fi

# ─── 路径配置 ─────────────────────────────────────────────────────────────────
PYTHON="$HOME/mlx-env/bin/python3"
MLX_ASR="$HOME/mlx-env/bin/mlx-qwen3-asr"
HOTWORDS_FILE="$HOME/.openclaw/skills/douyin-transcript/hotwords.txt"
TRANSCRIPTS_DIR="$HOME/.openclaw/shared/video-transcripts/transcripts"
AUDIO_TMPDIR="/tmp/douyin-asr-$$"
MODEL_ID="Qwen/Qwen3-ASR-1.7B"

mkdir -p "$TRANSCRIPTS_DIR" "$AUDIO_TMPDIR"
OUTPUT_DIR="$AUDIO_TMPDIR/asr_out"
mkdir -p "$OUTPUT_DIR"

# ─── 清理函数 ─────────────────────────────────────────────────────────────────
cleanup() {
    rm -rf "$AUDIO_TMPDIR"
}
trap cleanup EXIT

# ─── 生成输出文件名 ────────────────────────────────────────────────────────────
TODAY=$(date +%Y-%m-%d)
# 从文件名提取标题（去掉扩展名，清理特殊字符）
BASENAME=$(basename "$VIDEO_FILE")
TITLE=$(echo "${BASENAME%.*}" | sed 's/[^a-zA-Z0-9_\-\u4e00-\u9fff]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')
OUTPUT_TXT="$TRANSCRIPTS_DIR/${TODAY}-${TITLE}.txt"
AUDIO_FILE="$AUDIO_TMPDIR/audio.wav"

echo "🎬 视频文件: $VIDEO_FILE"
echo "📄 输出文件: $OUTPUT_TXT"
echo ""

# ─── Step 1: ffmpeg 提取音频 ──────────────────────────────────────────────────
echo "🔊 Step 1/2: 提取音频（16kHz mono WAV）..."

if ! command -v ffmpeg &>/dev/null; then
    echo "错误: ffmpeg 未安装。请运行: brew install ffmpeg" >&2
    exit 1
fi

if ! ffmpeg -i "$VIDEO_FILE" \
    -ar 16000 \
    -ac 1 \
    -vn \
    -y \
    "$AUDIO_FILE" \
    2>/dev/null; then
    echo "错误: ffmpeg 提取音频失败" >&2
    exit 1
fi

AUDIO_SIZE=$(du -h "$AUDIO_FILE" | cut -f1)
echo "✅ 音频提取完成 (${AUDIO_SIZE})"
echo ""

# ─── Step 2: MLX Qwen3-ASR 转文字（带热词注入）─────────────────────────────────
echo "🤖 Step 2/2: MLX Qwen3-ASR 语音识别（Apple Silicon 原生）..."

if [[ ! -x "$MLX_ASR" ]]; then
    echo "错误: mlx-qwen3-asr 未安装或不可执行: $MLX_ASR" >&2
    echo "      请运行: ~/mlx-env/bin/pip install mlx-qwen3-asr" >&2
    exit 1
fi

# 读取热词库
if [[ -f "$HOTWORDS_FILE" ]]; then
    HOTWORDS=$(cat "$HOTWORDS_FILE" | tr '\n' ' ' | sed 's/ $//')
    echo "💬 热词注入: $(echo "$HOTWORDS" | wc -w | tr -d ' ') 个词"
else
    HOTWORDS=""
    echo "⚠️  热词文件不存在: $HOTWORDS_FILE（跳过热词注入）"
fi

# 运行 ASR
if [[ -n "$HOTWORDS" ]]; then
    "$MLX_ASR" \
        --model "$MODEL_ID" \
        --language Chinese \
        --context "$HOTWORDS" \
        --output-dir "$OUTPUT_DIR" \
        --output-format txt \
        "$AUDIO_FILE" 2>&1
else
    "$MLX_ASR" \
        --model "$MODEL_ID" \
        --language Chinese \
        --output-dir "$OUTPUT_DIR" \
        --output-format txt \
        "$AUDIO_FILE" 2>&1
fi

# 找到 ASR 输出文件并复制到最终路径
ASR_TXT=$(find "$OUTPUT_DIR" -name "*.txt" | head -1)
if [[ -z "$ASR_TXT" ]]; then
    echo "错误: mlx-qwen3-asr 未生成文字文件" >&2
    exit 1
fi

cp "$ASR_TXT" "$OUTPUT_TXT"

# ─── 完成 ─────────────────────────────────────────────────────────────────────
echo ""
echo "─────────────────────────────────────────────"
if [[ -f "$OUTPUT_TXT" && -s "$OUTPUT_TXT" ]]; then
    CHAR_COUNT=$(wc -m < "$OUTPUT_TXT" | tr -d ' ')
    echo "✅ 转文字完成！"
    echo "📄 文件: $OUTPUT_TXT"
    echo "📊 字数: ${CHAR_COUNT} 字"
    echo ""
    echo "📝 内容预览（前200字）:"
    echo "─────────────────────────────────────────────"
    head -c 400 "$OUTPUT_TXT"
    echo ""
    echo "─────────────────────────────────────────────"
    echo ""
    echo "$OUTPUT_TXT"  # 最后一行输出路径，便于脚本捕获
else
    echo "错误: 输出文件为空或不存在" >&2
    exit 1
fi
