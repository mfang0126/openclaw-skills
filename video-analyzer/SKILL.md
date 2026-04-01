---
user-invocable: false
name: video-analyzer
description: |
  深度分析视频内容：转写、验证、素材化，输出结构化 Markdown 笔记。

  USE FOR:
  - "分析这个视频", "analyze this video", "帮我转写视频"
  - "把视频转成文字", "transcribe this", "视频内容提取"
  - "总结这个 YouTube 视频", "summarize this video content"
  - "把这个抖音/B站视频做成素材", "extract key points from video"
  - "下载并分析视频", "video to notes", "视频转笔记"

  REQUIRES:
  - ffmpeg (音频提取)
  - Whisper (本地转写，pip install openai-whisper)
  - research-hub skill (内容验证，Level C/D)
metadata:
  openclaw:
    emoji: "🎬"
    requires:
      bins: ["ffmpeg", "whisper"]
---

# Video Analyzer

**Pattern: Pipeline** — Video URL → Download → Audio Extract → Whisper Transcribe → Validate → Materialize → Markdown Output

> ⚠️ **scripts/ 目录为空** — Pipeline 脚本（download.sh、transcribe.sh、validate.sh、materialize.sh）均缺失，需先按 README.md 安装后才能执行。

## When to Use

Use when the user wants to **extract, transcribe, or analyze video content** from YouTube, 抖音, B站 etc. Typical triggers:
- User shares a video URL and wants a summary, transcript, or notes
- Content creator needs to repurpose video into blog posts or study materials
- "把这个视频转成笔记/素材"

**Don't use when:** User wants to edit/trim video (use video editors), just wants to download without analysis, or video is < 1 min (transcribe manually instead).

## Prerequisites

1. **ffmpeg** installed: `brew install ffmpeg` or `apt install ffmpeg`
2. **Whisper** installed: `pip install openai-whisper`
3. **Pipeline scripts** present in `scripts/` directory — see `README.md` for setup
4. **research-hub** skill installed (required for Level C/D validation only)
5. Sufficient disk space (~500 MB per hour of video)

## Quick Start

This skill is normally invoked by `content-inbox`. To call manually, spawn a subagent:

```bash
# Spawn via OpenClaw (recommended)
sessions_spawn(
  runtime="subagent",
  task="用 video-analyzer 处理：<video_url_or_path>，操作：C"
)
```

### Processing Levels

| Level | Includes | Est. Time |
|-------|----------|-----------|
| **B** | Whisper transcription only | ~5 min |
| **C** | B + fact validation + materialize | ~20 min |
| **D** | C + blog draft | ~30 min |

## Examples

### Example 1: Analyze a YouTube video (Level C)

**User says:** "帮我分析这个健身视频，做成素材 https://youtube.com/watch?v=abc123"

**Action:** Spawn subagent with task:
```
用 video-analyzer 处理：https://youtube.com/watch?v=abc123，操作：C
```

**Output** (saved to `content-inbox/youtube/media/2026-03-25/`):
```
├── 增肌饮食误区.mp4
└── 增肌饮食误区.md   ← 转写 + 验证结论 + 关键素材点
```

**Reply to user:** "✅ 视频分析完成，素材已保存至 content-inbox/youtube/media/2026-03-25/增肌饮食误区.md"

### Example 2: Transcription only (Level B)

**User says:** "把这个抖音视频转成文字就行，不用验证"

**Action:**
```
用 video-analyzer 处理：douyin_video.mp4，操作：B
```

**Output:** Single `.md` file containing full Whisper transcription with timestamps.

## Error Handling

| Error | Cause | Solution |
|-------|-------|----------|
| `scripts/ 目录为空` | Pipeline 脚本未安装 | 按 README.md 安装所有 scripts/ 脚本 |
| `ffmpeg: command not found` | ffmpeg 未安装 | `brew install ffmpeg` 或 `apt install ffmpeg` |
| `whisper: command not found` | Whisper 未安装 | `pip install openai-whisper` |
| Download failed / 403 | 平台限制或 URL 失效 | 检查 URL；尝试 `yt-dlp` 替换下载脚本 |
| Transcription timeout | 视频过长（>2小时） | 分段处理；改用更快模型 `--model tiny` |
| research-hub not found | 验证 skill 未安装 | 安装 research-hub 或降级到 Level B |
| Out of disk space | 视频文件过大 | 清理 `/tmp`；处理后删除原始视频 |

## 场景适配

| 场景 | 验证重点 |
|------|---------|
| 健身/营养 | PubMed/WHO 权威来源 |
| 情感/心理 | 心理学研究 |
| 科普 | 多源交叉验证 |
| 观点 | 逻辑 + 反方观点 |
| 案例 | 普适性 + 相反案例 |

## 输出结构

```
content-inbox/{platform}/media/YYYY-MM-DD/
├── 视频标题.mp4        ← 原始视频
└── 视频标题.md         ← 分析结果
```

**输出模板** → `templates/blog-material.md`

## 详细文档

- `references/levels.md` — A/B/C/D 处理级别详解
- `references/scenarios.md` — 场景适配说明
- `templates/blog-material.md` — 输出 Markdown 模板
