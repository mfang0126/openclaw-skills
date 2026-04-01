---
name: knowledge-capture
description: |
  End-to-end knowledge capture: download video → transcribe → summarize → archive as searchable Markdown.

  USE THIS SKILL whenever the user:
  - Shares a Douyin link AND wants to understand the content (not just download)
  - Says "学习这个视频", "帮我整理", "记录下来", "归档", "capture this", "知识整理"
  - Says "这个视频讲了什么" + a Douyin/video link
  - Wants a video transcribed AND organized (not just raw transcription)
  - Provides a local video/audio file and asks for structured notes

  CHAINS: douyin-dl → ffmpeg → mlx-qwen3-asr → LLM summarize → .md archive
  REPLACES: manual douyin-dl + whisper-transcribe + copy-paste workflow

  DO NOT USE FOR:
  - Just downloading a video (use douyin-dl)
  - Just transcribing audio (use whisper-transcribe)
  - YouTube/Bilibili (different downloaders needed — run manually)
  - Real-time/streaming transcription

  REQUIRES: ffmpeg, mlx-qwen3-asr (pip), python3
  OPTIONAL: tikhub_api_token (for Douyin links), GROQ_API_KEY (whisper fallback)
metadata:
  openclaw:
    emoji: "📚"
    requires:
      bins: ["ffmpeg", "python3", "mlx-qwen3-asr"]
---

# Knowledge Capture

**Pattern: Pipeline** — Download → Extract audio → Transcribe → Summarize → Archive

将视频内容转化为结构化知识笔记，自动归档到 `~/.openclaw/shared/video-transcripts/`，可被 memorySearch 索引。

## When to Use

触发条件（任意匹配）：
- 用户发了抖音链接 + 想了解内容（"这个视频讲了什么"、"帮我整理"）
- 用户说"学习"、"归档"、"capture"、"知识整理"、"记录下来"
- 用户发了本地视频文件 + 想要结构化笔记

不适用：
- 只想下载视频 → `douyin-dl`
- 只想要原始转录 → `whisper-transcribe`
- YouTube/Bilibili → 先手动下载，再用本 skill 的本地文件模式

## Prerequisites

必需：
- `ffmpeg` — `brew install ffmpeg`
- `mlx-qwen3-asr` — `pip install mlx-qwen3-asr`（中文 ASR 首选）
- `python3`

可选：
- `tikhub_api_token` — 抖音视频下载（~/.openclaw/config.json）
- `GROQ_API_KEY` — Whisper API fallback
- `whisper-cli` — whisper.cpp 本地 fallback

## Quick Start

```bash
# 完整流程：抖音链接 → 归档
python3 ~/.openclaw/skills/knowledge-capture/scripts/capture.py "https://v.douyin.com/xxxxx/"

# 本地视频文件
python3 ~/.openclaw/skills/knowledge-capture/scripts/capture.py /path/to/video.mp4

# 指定分类标签
python3 ~/.openclaw/skills/knowledge-capture/scripts/capture.py "https://v.douyin.com/xxxxx/" --tags "ai,agent"

# 指定标题（否则自动生成）
python3 ~/.openclaw/skills/knowledge-capture/scripts/capture.py /path/to/video.mp4 --title "My Video Notes"

# 只转录不整理（跳过 LLM）
python3 ~/.openclaw/skills/knowledge-capture/scripts/capture.py /path/to/video.mp4 --transcript-only

# 强制使用 whisper（跳过 mlx-qwen3-asr）
python3 ~/.openclaw/skills/knowledge-capture/scripts/capture.py /path/to/video.mp4 --asr whisper
```

## Instructions

### Step 1: 确定输入源
- 如果是抖音链接 → 调用 douyin-dl 下载视频
- 如果是本地文件 → 直接使用

```bash
# 抖音下载
python3 ~/.openclaw/skills/douyin-dl/scripts/douyin_download.py "URL" --download --output-dir ~/.openclaw/shared/video-transcripts/videos/
```

### Step 2: 提取音频
```bash
ffmpeg -y -i INPUT.mp4 -vn -acodec pcm_s16le -ar 16000 -ac 1 /tmp/kc_audio.wav
```

### Step 3: ASR 转录
优先级：
1. **mlx-qwen3-asr**（中文 CER 4.97%，远优于 Whisper）
2. **Groq Whisper API**（英文/多语种 fallback）
3. **whisper.cpp**（离线 fallback）

```bash
# mlx-qwen3-asr（推荐）— 同时生成 txt 和 srt
mlx-qwen3-asr /tmp/kc_audio.wav --output-dir /tmp/kc_asr --output-format all --no-progress

# whisper fallback
python3 ~/.openclaw/skills/whisper-transcribe/scripts/transcribe.py INPUT.mp4 -o /tmp/kc_transcript.txt
```

### Step 4: LLM 整理（由 agent 执行）
收到原始转录后，agent 用 LLM 生成结构化笔记：

**Progressive Disclosure 输出格式：**

```markdown
# [标题]

- **来源**: [平台/作者]
- **原始链接**: [URL]
- **日期**: [YYYY-MM-DD]
- **标签**: [tag1, tag2, ...]
- **视频文件**: ./videos/[filename].mp4
- **转录文件**: ./transcripts/[filename]-transcript.txt

## L0: 一句话摘要
[50字以内概括核心观点]

## L1: 关键要点
1. [要点1]
2. [要点2]
3. [要点3]
...

## L2: 详细笔记
[去口语化的完整内容整理，保留专业术语和关键细节]

## L3: 原始转录
[完整原始转录文本，或指向 transcript 文件的路径]
```

### Step 5: 归档
文件保存到：
```
~/.openclaw/shared/video-transcripts/
├── videos/          ← 视频文件（YYYY-MM-DD-slug.mp4）
├── transcripts/     ← 原始转录（YYYY-MM-DD-slug-transcript.txt + .srt）
└── info/            ← 结构化笔记（YYYY-MM-DD-slug-info.md）← memorySearch 索引
```

命名规则：`YYYY-MM-DD-slug`，slug 从标题生成（kebab-case，中文用拼音或英文关键词）。

### Step 6: memorySearch 自动索引
因为 `.md` 文件在 `~/.openclaw/shared/` 下，memorySearch 会自动扫描到。无需额外操作。

## Agent Workflow（推荐）

当用户发来抖音链接时，agent 应该按以下步骤执行：

```
1. exec: python3 ~/.openclaw/skills/knowledge-capture/scripts/capture.py "URL"
   → 这会自动完成 下载 + 提取音频 + ASR 转录 + 归档原始文件
   → 输出 JSON，包含 transcript_text, srt_path, video_path 等

2. 读取转录文本，用 LLM 整理成结构化笔记（按 L0-L3 格式）

3. 写入 info .md 文件到 ~/.openclaw/shared/video-transcripts/info/

4. 向用户返回 L0 摘要 + L1 要点，告知完整笔记已归档
```

## Examples

### Example 1: 抖音视频知识归档
**User says:** "帮我整理这个视频 https://v.douyin.com/iABCxyz/"
**Steps:**
1. 运行 capture.py，下载视频，ASR 转录
2. LLM 整理转录文本
3. 归档到 video-transcripts/
**Reply:**
```
📚 已整理并归档！

**一句话摘要：** Agent 开发的5种核心设计模式，包括 ToolWrapper、Generator 等。

**关键要点：**
1. ToolWrapper — 按需注入知识
2. Generator — 输出结构稳定
3. Reviewer — 审查标准分离

完整笔记已保存到 video-transcripts/info/2026-03-30-agent-skill-patterns-info.md
```

### Example 2: 本地视频
**User says:** "整理一下 ~/Downloads/lecture.mp4 打上 ml 标签"
**Steps:**
1. capture.py 处理本地文件
2. LLM 整理 + 标签 ml
3. 归档
**Reply:** "📚 已整理并归档！[摘要]..."

### Example 3: 只要转录
**User says:** "帮我转录这个视频 https://v.douyin.com/xxx/ 不用整理"
**Steps:**
1. capture.py --transcript-only
2. 返回原始转录
**Reply:** 直接输出转录文本

## Error Handling

| 错误 | 原因 | 解决 |
|------|------|------|
| `mlx-qwen3-asr not found` | 未安装 | `pip install mlx-qwen3-asr` |
| `douyin download failed` | Token/网络 | 检查 tikhub_api_token，或用户手动提供视频文件 |
| `ASR produced empty output` | 静音视频 | 告知用户视频无语音 |
| `ffmpeg not found` | 未安装 | `brew install ffmpeg` |

## Classification Logic

自动分类策略（按优先级）：
1. **用户指定** — `--tags "ai,agent"` 直接使用
2. **LLM 推断** — 在整理步骤中，LLM 根据内容推荐 1-3 个标签
3. **默认** — `uncategorized`

常用标签参考：`ai`, `agent`, `ml`, `programming`, `product`, `design`, `business`, `life`, `tech`
