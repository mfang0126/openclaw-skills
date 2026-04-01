---
user-invocable: false
name: douyin-dl
description: |
  Download Douyin (抖音) videos via the TikHub API — no login required.

  USE THIS SKILL whenever the user:
  - Shares a Douyin link (v.douyin.com, douyin.com, or any URL containing "douyin")
  - Pastes a modal_id or aweme_id (16–19 digit number)
  - Says "下载视频", "帮我下载", "save this video", "download this douyin"
  - Shares a short-link like "复制链接" text containing v.douyin.com
  - Asks to save, grab, or fetch a Douyin clip

  Always use this skill when you detect a Douyin URL or a numeric video ID — even if
  the user doesn't explicitly say "download". Just seeing a v.douyin.com link is enough.

  DO NOT USE FOR:
  - YouTube, Bilibili, Instagram, or other platforms (use their respective tools)
  - Douyin live streams (not supported by the API)
  - Douyin image carousels / 图集 (video-only)

  REQUIRES: ~/.openclaw/config.json with tikhub_api_token; python3
metadata:
  openclaw:
    emoji: "📹"
    requires:
      bins: ["python3", "wget"]
---

# Douyin Downloader

**Pattern: Tool Wrapper** (Google ADK) — 检测链接/ID → TikHub API → 获取真实视频 URL → 下载到本地

Download Douyin videos using the TikHub API. Handles short links, full URLs, and bare video IDs.

## When to Use

## Prerequisites

无需特殊依赖，装了就能用。

Use when the user shares a Douyin link or video ID and wants to save the video locally. Triggers automatically on any `v.douyin.com` or `douyin.com` URL — even if the user doesn't say "download".

**Don't use when:** The link is for YouTube, Bilibili, Instagram, or another platform (use their tools). Douyin **live streams** and **image carousels (图集)** are not supported.

## Configuration

Requires a TikHub API token in `~/.openclaw/config.json`:

```json
{ "tikhub_api_token": "your-token-here" }
```

Free tokens: https://user.tikhub.io/register

## Workflow

1. **Detect input** — identify a Douyin link or modal_id from the user's message
2. **Run the script** — call `python3 {baseDir}/scripts/douyin_download.py`
3. **Show result** — report the modal_id and either the video URL or the saved file path

## Examples

### Example 1: Download a Douyin video

**User says:** "帮我下载这个抖音视频 https://v.douyin.com/iABCxyz/"
**Steps:**
```bash
python3 {baseDir}/scripts/douyin_download.py "https://v.douyin.com/iABCxyz/" --download
```
**Output:** `Downloaded: ~/Downloads/douyin/douyin_7615599455526585067.mp4 (24.3 MB)`
**Reply:** "已下载完成！视频保存到 `~/Downloads/douyin/douyin_7615599455526585067.mp4`（24.3 MB）。"

## Commands

### Get video info (no download)
```bash
python3 {baseDir}/scripts/douyin_download.py "https://v.douyin.com/xxxxx/"
```

### Download to default location (~/Downloads/douyin/)
```bash
python3 {baseDir}/scripts/douyin_download.py "https://v.douyin.com/xxxxx/" --download
```

### Download to a custom directory
```bash
python3 {baseDir}/scripts/douyin_download.py "https://v.douyin.com/xxxxx/" --download --output-dir /path/to/dir
```

### Use a bare modal_id
```bash
python3 {baseDir}/scripts/douyin_download.py "7615599455526585067" --download
```

## Accepted Input Formats

| Format | Example |
|--------|---------|
| Short link | `https://v.douyin.com/iABCxyz/` |
| Full URL with modal_id | `https://www.douyin.com/video/7615599455526585067` |
| URL query param | `https://www.douyin.com/jingxuan?modal_id=7615599455526585067` |
| Bare modal_id | `7615599455526585067` |

## Output

- **Without `--download`**: prints modal_id + direct video URL
- **With `--download`**: downloads to `~/Downloads/douyin/douyin_<modal_id>.mp4` (or custom dir)

## Error Handling

| Error | Cause | Solution |
|-------|-------|----------|
| `tikhub_api_token` missing | Token not set in config | Add `"tikhub_api_token": "..."` to `~/.openclaw/config.json` |
| HTTP 401 / Unauthorized | Token expired or invalid | Get a new token at https://user.tikhub.io and update config |
| `No video URL found` | Video is a live stream or image carousel | Douyin lives and 图集 are unsupported; inform user |
| `wget: command not found` | wget not installed | `brew install wget` |
| Short link doesn't resolve | Link expired or region-blocked | Ask user to share the full URL from the Douyin app |
| `python3: command not found` | Python not installed | `brew install python3` |
