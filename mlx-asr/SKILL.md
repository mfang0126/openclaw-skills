---
name: mlx-asr
description: |
  Apple Silicon local ASR via Qwen3-ASR + MLX. Server-mode for stable memory.
  
  USE FOR:
  - "转文字", "转录", "transcribe this", "speech to text"
  - 任何音频/视频文件需要转文字时
  - SRT/VTT 字幕生成
  - 用户发音频/视频文件说"这个说的什么"
  - douyin-dl 下载后自动转文字
  - Agent 需要处理语音内容时

  ⚠️ ALWAYS use this skill for any audio/video transcription on Apple Silicon.
  Do NOT use whisper-transcribe (disabled).

  Apple Silicon only. No API key needed. No cloud dependency.
  Uses server-mode (model loaded once, ~4GB memory stable).

version: 1.0.0
user-invocable: true
compatibility:
  - macOS Apple Silicon
  - ffmpeg (brew install ffmpeg)
  - python3
  - mlx-qwen3-asr[serve] (pip install "mlx-qwen3-asr[serve]")
metadata:
  author: Ming
  category: media
  tags: [asr, transcript, 转文字, speech-to-text, mlx, qwen, srt, vtt, apple-silicon]
  pattern: Tool Wrapper
  openclaw:
    emoji: "🎙️"
    requires:
      bins: ["ffmpeg"]
---

# MLX ASR — Apple Silicon Speech-to-Text

**Pattern: Tool Wrapper** — 音频/视频 → ffmpeg 预处理 → Qwen3-ASR server → 输出文字/字幕

Apple Silicon 专用 ASR，基于 Qwen3-ASR + MLX。Server 常驻模式，内存稳定 ~4GB，无需 API key。

## When to Use

触发条件：
- 用户说"转文字"、"转录"、"transcribe"
- 音频文件需要转文字（wav/mp3/m4a/flac/ogg）
- 视频文件需要提取语音（mp4/mov/mkv）
- 需要带时间戳的字幕（SRT/VTT）
- "这个视频说的什么"、"听一下这个音频"

不适用：
- 非 Apple Silicon 设备 → 用 whisper-transcribe
- 需要多语言实时流式转写

## Prerequisites

```bash
# 1. Install mlx-qwen3-asr with server support
~/mlx-env/bin/pip install "mlx-qwen3-asr[serve]"

# 2. Models auto-download on first use

# 3. Start server
SKILL_DIR="$(dirname "$0")/.."
$SKILL_DIR/scripts/serve.sh start

# 4. (Optional) Use smaller model (faster, less memory)
$SKILL_DIR/scripts/serve.sh start --small
```

## Commands

### Server Management
```bash
SKILL_DIR="$(dirname "$0")/.."

# Start server (default 1.7B model)
$SKILL_DIR/scripts/serve.sh start

# Start with 0.6B model (faster, less accurate)
$SKILL_DIR/scripts/serve.sh start --small

# Start with debug logging + memory metrics
$SKILL_DIR/scripts/serve.sh start --debug

# Stop server
$SKILL_DIR/scripts/serve.sh stop

# Check status
$SKILL_DIR/scripts/serve.sh status

# Verbose healthcheck (memory, uptime)
$SKILL_DIR/scripts/healthcheck.sh --verbose
```

### Transcription
```bash
# Basic transcription (stdout)
scripts/transcribe.sh audio.mp3

# With format options
scripts/transcribe.sh video.mp4 --format srt --output subs.srt
scripts/transcribe.sh audio.wav --format vtt --output subs.vtt

# With language hint
scripts/transcribe.sh audio.mp3 --language zh

# Debug mode (logs to ~/.mlx-asr.log)
scripts/transcribe.sh audio.mp3 --debug
```

## Architecture

```
transcribe.sh
    ↓
ffmpeg → 16kHz mono WAV
    ↓
curl POST /v1/audio/transcriptions (OpenAI-compatible)
    ↓
mlx-qwen3-asr server (port 8765, model loaded once)
    ↓
text / srt / vtt output
```

**Memory**: Server 常驻 ~4GB (1.7B) / ~2GB (0.6B)，不再每次 CLI 调用重新加载。

## Hotwords

Edit `hotwords.txt` to add domain-specific terms. These are passed as prompt context to improve recognition accuracy.

## Examples for Agent

Use `$(find ~/.openclaw/skills ~/Code/openclaw-skills -name transcribe.sh -path '*/mlx-asr/*' -print -quit)` to locate the script.

```
User: 转文字 recording.m4a
→ exec: <skill_dir>/scripts/transcribe.sh recording.m4a

User: 生成字幕 video.mp4
→ exec: <skill_dir>/scripts/transcribe.sh video.mp4 --format srt --output video.srt

User: 这个视频说的什么
→ exec: <skill_dir>/scripts/transcribe.sh video.mp4 --format txt
```

## Limits

| Limit | Value |
|-------|-------|
| Max file size | 2GB |
| Max audio duration | 8 hours |
| Max concurrent requests | Serialized (one at a time) |
| Queue depth | 10 jobs |
| Memory (1.7B) | ~4.7GB stable |
| Memory (0.6B) | ~2GB stable |

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Server won't start | Check `~/.mlx-asr-server.log` |
| Port in use | `lsof -i :8765` or `MLX_ASR_PORT=8766` |
| Out of memory | Use `--small` flag for 0.6B model |
| Transcription empty | Check audio has speech, try `--language` hint |
| Hotwords not working | Check `hotwords.txt` format (one word per line) |

### Debug Mode

Enable debug logging to troubleshoot transcription issues:

```bash
# Transcribe with debug logging
scripts/transcribe.sh audio.mp3 --debug
# → logs to ~/.mlx-asr.log

# Server with debug + memory metrics
scripts/serve.sh start --debug
# → logs to ~/.mlx-asr-server.log + ~/.mlx-asr-server-metrics.log

# Verbose healthcheck
scripts/healthcheck.sh --verbose
# → shows RSS memory, uptime, health response
```

### Log Files

| File | Purpose |
|------|----------|
| `~/.mlx-asr.log` | Transcribe debug log (per-call timing, memory, status) |
| `~/.mlx-asr-server.log` | Server stdout/stderr |
| `~/.mlx-asr-server-metrics.log` | Server memory metrics (every 60s in debug mode) |

### Sharing Logs

When reporting issues, attach the relevant log files:
```bash
# Last 50 lines of transcribe log
tail -50 ~/.mlx-asr.log

# Server metrics
tail -20 ~/.mlx-asr-server-metrics.log
```
