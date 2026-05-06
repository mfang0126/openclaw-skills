# mlx-asr

Apple Silicon local ASR skill for OpenClaw — Qwen3-ASR + MLX, server-mode.

## Features
- 🚀 Server-mode: model loaded once, ~4GB memory stable
- 🎯 Qwen3-ASR models: 1.7B (default) / 0.6B (fast)
- 📝 Output formats: txt, srt, vtt
- 🎬 Audio + Video support (ffmpeg preprocessing)
- 🔤 Hotwords support for domain-specific terms
- 🔒 No API key needed, fully local

## Install

```bash
pip install "mlx-qwen3-asr[serve]"
```

## Usage

```bash
# Start server
scripts/serve.sh start

# Transcribe
scripts/transcribe.sh audio.mp3
scripts/transcribe.sh video.mp4 --format srt --output subs.srt

# Stop
scripts/serve.sh stop
```

## Requirements
- macOS Apple Silicon
- ffmpeg
- mlx-qwen3-asr[serve]
