---
name: whisper-transcribe
description: |
  Transcribe audio/video to text using the best available ASR backend.
  
  Backend priority: MLX Qwen3-ASR (local, best for Chinese) → Groq API (fast, cloud) → whisper.cpp (local fallback)

  USE FOR:
  - "转文字", "转录", "transcribe this", "speech to text"
  - Any audio file (wav, mp3, m4a, flac, ogg, wma, aac) needs transcription
  - Video file needs transcription (extracts audio first via ffmpeg)
  - Douyin/video downloaded → auto transcribe
  - Need SRT/VTT subtitles from audio/video
  - "这个视频说的什么", "听一下这个音频"

  REPLACES: openai-whisper, openai-whisper-api, mlx-whisper, douyin-transcript (for ASR step)
  REQUIRES: ffmpeg
  OPTIONAL: mlx-qwen3-asr (pip), GROQ_API_KEY, whisper-cli (brew)
version: 2.0.0
user-invocable: true
compatibility:
  - python>=3.10
  - ffmpeg
metadata:
  author: King
  category: media
  tags: [asr, transcript, 转文字, speech-to-text, mlx, groq, whisper, srt, vtt]
  pattern: Tool Wrapper
  openclaw:
    emoji: "🎤"
    requires:
      bins: ["ffmpeg", "python3"]
---

# Whisper Transcribe

**Pattern: Tool Wrapper** — 检测音频/视频 → 预处理 → 选 ASR 后端 → 输出文字/字幕

将音频或视频文件转录为文字。后端优先级：MLX Qwen3-ASR（本地、中文最优）→ Groq API（云端极速）→ whisper.cpp（本地离线）。

## When to Use

触发条件：
- 用户说"转文字"、"转录"、"transcribe"
- 用户发了音频文件（wav/mp3/m4a/flac/ogg）
- 用户发了视频文件（mp4/mov/mkv）需要提取语音内容
- 需要带时间戳的字幕（SRT/VTT 格式）
- "这个视频说的什么"、"听一下这个音频"

不适用：
- TTS（文字转语音）
- 实时流式转录
- 翻译（先转录再单独翻译）

## Quick Start

```bash
# 自动选最优后端，输出纯文字
python3 ~/.openclaw/skills/whisper-transcribe/scripts/transcribe.py /path/to/audio.wav

# 生成 SRT 字幕
python3 ~/.openclaw/skills/whisper-transcribe/scripts/transcribe.py /path/to/video.mp4 --format srt

# 生成 VTT 字幕
python3 ~/.openclaw/skills/whisper-transcribe/scripts/transcribe.py /path/to/video.mp4 --format vtt

# 强制本地（MLX → whisper.cpp，跳过 Groq）
python3 ~/.openclaw/skills/whisper-transcribe/scripts/transcribe.py /path/to/audio.wav --local

# 指定语言
python3 ~/.openclaw/skills/whisper-transcribe/scripts/transcribe.py /path/to/audio.wav --language zh

# 强制指定后端
python3 ~/.openclaw/skills/whisper-transcribe/scripts/transcribe.py /path/to/audio.wav --backend mlx

# 输出到文件
python3 ~/.openclaw/skills/whisper-transcribe/scripts/transcribe.py /path/to/audio.wav --output /tmp/transcript.txt
```

## Instructions

### Step 1: 检测输入
确认文件存在且是支持的格式（wav/mp3/m4a/flac/ogg/wma/aac/mp4/mov/mkv/webm/avi/flv）。

### Step 2: 预处理
- 视频或非 WAV 音频 → ffmpeg 转 16kHz mono WAV（临时文件）
- WAV 文件 → 直接使用

### Step 3: 选择后端
按优先级尝试：
1. **MLX Qwen3-ASR** — `~/mlx-env/bin/mlx-qwen3-asr` 可用时优先使用，中文最优，支持热词
2. **Groq API** — `GROQ_API_KEY` 存在时使用，极速，支持多语言
3. **whisper.cpp** — `whisper-cli` 在 PATH 中时使用，完全离线

### Step 4: 转录
运行 transcribe.py，输出结果到 stdout 或 --output 指定路径。

## Hotwords（热词注入）

热词文件：`~/.openclaw/skills/whisper-transcribe/hotwords.txt`

- 每行一个词，支持中英文
- 三个后端都会使用热词（MLX: `--context`，Groq: `prompt` 参数，whisper.cpp: `--prompt`）
- 读取失败时静默跳过，不影响转录
- 随时可编辑，添加视频中出现的专有名词以提升识别准确率

## Output Formats

| 格式 | 说明 | 用途 |
|------|------|------|
| `txt` | 纯文字，无时间戳（默认） | 文章、笔记 |
| `srt` | SubRip 字幕，含时间戳 | 视频字幕 |
| `vtt` | WebVTT 字幕，含时间戳 | Web 播放器 |

## Prerequisites

必需：
- `ffmpeg`（`brew install ffmpeg`）
- `python3`

任选其一：
- `mlx-qwen3-asr`（`~/mlx-env/bin/pip install mlx-qwen3-asr`）— Apple Silicon 推荐
- `GROQ_API_KEY` — 在 `~/.openclaw/openclaw.json` 配置
- `whisper-cli`（`brew install whisper-cpp`）

## Examples

### Example 1: 抖音视频转文字
**User says:** "帮我下载这个抖音视频然后转文字"
**Steps:**
1. douyin-dl 下载视频
2. 运行 transcribe.py，视频 → ffmpeg 提音频
3. MLX Qwen3-ASR 转录（带热词注入）
**Output:** 转录文字

### Example 2: 生成 SRT 字幕
**User says:** "给这个视频生成字幕 /tmp/talk.mp4"
**Steps:**
1. ffmpeg 提取音频
2. Groq API 返回 verbose_json（含 segments）
3. 转换为 SRT 格式输出
**Output:** SRT 字幕文件

### Example 3: 本地英文播客
**User says:** "transcribe this podcast episode /tmp/podcast.mp3 --local"
**Steps:**
1. ffmpeg 转 WAV
2. MLX → whisper.cpp（跳过 Groq）
**Output:** 英文全文

## Error Handling

| 错误 | 原因 | 解决方案 |
|------|------|---------|
| `File not found` | 路径错误 | 检查路径 |
| `No ASR backend available` | 三个后端都不可用 | 安装至少一个后端（见 Prerequisites） |
| `[mlx] failed: ...` | MLX 转录失败 | 自动 fallback 到 Groq |
| `[groq] failed: ...` | API key 无效或超额度 | 自动 fallback 到 whisper.cpp |
| `ffmpeg not found` | ffmpeg 未安装 | `brew install ffmpeg` |

## Backend Details

### MLX Qwen3-ASR（首选）
- 二进制：`~/mlx-env/bin/mlx-qwen3-asr`
- 模型：`Qwen/Qwen3-ASR-1.7B`（首次运行自动下载）
- 热词：`--context` 参数
- 格式：原生支持 txt/srt/vtt/json

### Groq API（第二）
- 端点：`https://api.groq.com/openai/v1/audio/transcriptions`
- 模型：`whisper-large-v3`
- 免费额度：~8 小时/天
- 文件限制：≤ 25MB（WAV 自动压缩为 MP3 上传）
- 热词：`prompt` 参数
- SRT/VTT：`verbose_json` + 内置转换

### whisper.cpp（离线备选）
- 二进制：`whisper-cli`
- 模型：`ggml-large-v3-turbo`（~1.5GB，首次自动下载到 `~/.cache/whisper.cpp/`）
- 热词：`--prompt` 参数
- 格式：原生 -osrt/-ovtt
