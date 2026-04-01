---
name: whisper-transcribe
description: |
  Transcribe audio/video to text using Groq API (free, fast) or whisper.cpp (local fallback on Apple Silicon).

  USE FOR:
  - "转文字", "转录", "transcribe this", "speech to text"
  - Any audio file (wav, mp3, m4a, mp4, flac, ogg) needs transcription
  - Video file needs transcription (extracts audio first)
  - Douyin/video downloaded → auto transcribe
  - "这个视频说的什么", "听一下这个音频"

  REPLACES: openai-whisper, openai-whisper-api, mlx-whisper
  REQUIRES: ffmpeg, whisper-cli (brew install whisper-cpp)
  FALLBACK: Groq API → whisper.cpp (local)
metadata:
  openclaw:
    emoji: "🎤"
    requires:
      bins: ["ffmpeg", "whisper-cli"]
    install:
      - id: brew
        kind: brew
        formula: whisper-cpp
        bins: ["whisper-cli"]
        label: "Install whisper.cpp (brew)"
      - id: ffmpeg
        kind: brew
        formula: ffmpeg
        bins: ["ffmpeg"]
        label: "Install ffmpeg (brew)"
---

# Whisper Transcribe

**Pattern: Tool Wrapper** — 检测音频/视频 → 选 provider → 转录 → 输出文本

将音频或视频文件转录为文字。优先使用 Groq API（免费、极速），不可用时回退到 whisper.cpp（本地 Apple Silicon Metal 加速）。

## When to Use

触发条件：
- 用户说"转文字"、"转录"、"transcribe"
- 用户发了音频文件（wav/mp3/m4a/flac/ogg）
- 用户发了视频文件（mp4/mov/mkv）需要提取语音内容
- douyin-dl 下载视频后需要转录
- 用户说"这个视频说的什么"、"听一下这个音频"

不适用：
- 只需要 TTS（文字转语音）→ 用 `tts` 工具
- 需要实时流式转录 → whisper.cpp 支持但此 skill 不覆盖
- 需要翻译（transcribe + translate）→ 先转录再单独翻译

## Prerequisites

必需：
- `ffmpeg`（`brew install ffmpeg`）
- `whisper-cli`（`brew install whisper-cpp`）
- whisper.cpp 模型（首次使用自动下载到 `~/.cache/whisper.cpp/`）

可选（云端加速）：
- `GROQ_API_KEY` — Groq 免费注册：https://console.groq.com
- 配置：在 `~/.openclaw/openclaw.json` 添加 `"GROQ_API_KEY": "gsk_..."`

检查：
```bash
which whisper-cli    # whisper.cpp CLI
which ffmpeg         # 音频处理
ls ~/.cache/whisper.cpp/ggml-large-v3-turbo.bin  # 模型文件
```

## Quick Start

```bash
# 转录音频文件（自动选择 provider）
python3 ~/.openclaw/skills/whisper-transcribe/scripts/transcribe.py /path/to/audio.wav

# 转录视频（自动提取音频）
python3 ~/.openclaw/skills/whisper-transcribe/scripts/transcribe.py /path/to/video.mp4

# 强制使用本地
python3 ~/.openclaw/skills/whisper-transcribe/scripts/transcribe.py /path/to/audio.wav --local

# 指定语言
python3 ~/.openclaw/skills/whisper-transcribe/scripts/transcribe.py /path/to/audio.wav --language en
```

## Instructions

### Step 1: 检测输入
确认文件存在且是支持的格式（wav/mp3/m4a/flac/ogg/mp4/mov/mkv/webm）。

### Step 2: 预处理
- 如果是视频 → 用 ffmpeg 提取音频，转 16kHz mono WAV
- 如果音频文件 > 25MB 且使用 Groq → 压缩到 16kHz mono WAV
- 输出到 `/tmp/whisper_input.wav`

### Step 3: 选择 Provider
按优先级尝试：
1. **Groq API** — 检查 `GROQ_API_KEY` 是否可用 → 调用 `/v1/audio/transcriptions`
2. **whisper.cpp** — 本地 Metal GPU 推理，使用 `ggml-large-v3-turbo` 模型

### Step 4: 转录
- 自动检测语言，也可通过 `--language` 指定
- 输出纯文本到 `/tmp/whisper_output.txt`

### Step 5: 返回结果
- 返回转录文本
- 附带：耗时、使用的 provider、文件大小

## Examples

### Example 1: 转录抖音视频
**User says:** "帮我下载这个抖音视频然后转文字 https://v.douyin.com/xxx/"
**Steps:**
1. douyin-dl 下载视频到 `~/Downloads/douyin/douyin_xxx.mp4`
2. 运行 transcribe.py，检测到视频，ffmpeg 提取音频
3. Groq API 不可用，回退 whisper.cpp
4. 转录完成，输出文本
**Output:** "今天聊一个 Anthropic 刚发布的实战案例..."
**Reply:** "📹 视频已转录（whisper.cpp, 2.8s）\n\n今天聊一个 Anthropic 刚发布的实战案例..."

### Example 2: 转录本地音频文件
**User says:** "转文字 /tmp/meeting.wav"
**Steps:**
1. 检查文件存在
2. Groq API 可用，直接调用
3. 转录完成
**Output:** 会议纪要文本
**Reply:** "🎤 已转录（Groq API, 0.5s）\n\n[会议内容...]"

### Example 3: 英文播客转录
**User says:** "transcribe this podcast episode /tmp/podcast.mp3"
**Steps:**
1. 检查文件，32MB mp3
2. ffmpeg 压缩到 16kHz mono WAV
3. Groq API 转录
**Output:** 英文播客全文
**Reply:** "🎤 Transcribed (Groq API, 1.2s, 32MB→3.7MB compressed)\n\n[Podcast content...]"

## Error Handling

| 错误 | 原因 | 解决方案 |
|------|------|---------|
| `File not found` | 路径错误 | 检查路径，支持相对路径和绝对路径 |
| `Unsupported format` | 不认识的文件扩展名 | 用 ffmpeg 先转成 wav |
| `Groq 401` | API key 过期/无效 | 回退到 whisper.cpp，提醒用户更新 key |
| `Groq 429` | 超出免费额度 | 回退到 whisper.cpp |
| `Groq 413` | 文件太大（>25MB） | ffmpeg 压缩到 16kHz mono |
| `whisper.cpp model not found` | 模型未下载 | 脚本自动下载到 `~/.cache/whisper.cpp/` |
| `ffmpeg not found` | ffmpeg 未安装 | `brew install ffmpeg` |
| Empty output | 静音文件或无语音 | 告知用户文件无语音内容 |

## Provider Details

### Groq API（首选）
- Endpoint: `https://api.groq.com/openai/v1/audio/transcriptions`
- Model: `whisper-large-v3`
- 免费额度: ~8 小时音频/天
- 速度: 2分钟音频 < 1s
- 限制: 文件 ≤ 25MB

### whisper.cpp（离线）
- 模型: `ggml-large-v3-turbo`（1.5GB）
- 速度: 2分钟音频 ~2.8s（M4 Max 实测）
- 优势: 离线、无限制、隐私
- 加速: Metal GPU + CoreML
