# douyin-dl

> Download Douyin (抖音) videos via TikHub API. No login, no browser, just a token and a link.

## Install

Already installed at `~/.openclaw/skills/douyin-dl/`. Requires a TikHub API token.

## Setup

Add your TikHub token to `~/.openclaw/config.json`:

```json
{
  "tikhub_api_token": "your-token-here"
}
```

**Get a free token**: https://user.tikhub.io/register (free tier: ~500 requests/day)

## Usage

```bash
# Get video info (no download)
python3 ~/.openclaw/skills/douyin-dl/scripts/douyin_download.py "https://v.douyin.com/iABCxyz/"

# Download to ~/Downloads/douyin/
python3 ~/.openclaw/skills/douyin-dl/scripts/douyin_download.py "https://v.douyin.com/iABCxyz/" --download

# Use a bare modal_id
python3 ~/.openclaw/skills/douyin-dl/scripts/douyin_download.py "7615599455526585067" --download

# Download to custom directory
python3 ~/.openclaw/skills/douyin-dl/scripts/douyin_download.py "https://v.douyin.com/iABCxyz/" --download --output-dir /tmp/videos
```

## How It Works

**Pattern: Tool Wrapper** (Google ADK)

```
Input (URL or modal_id)
  → Resolve short link (v.douyin.com → actual URL with modal_id)
  → Extract modal_id from URL or use directly if already numeric
  → Call TikHub API: GET /api/v1/douyin/web/fetch_one_video?aweme_id={modal_id}
  → Parse response → extract direct video URL (no watermark)
  → Download via wget to ~/Downloads/douyin/douyin_{modal_id}.mp4
  → Report: title, author, file path
```

## Why TikHub Instead of Playwright?

| Approach | Stability | Speed | Login Required | Cost |
|----------|-----------|-------|----------------|------|
| **TikHub API** | ✅ High | ✅ Fast (< 3s) | ❌ No | Free tier |
| Playwright scrape | ⚠️ Fragile | 🐢 Slow (15s+) | ✅ Sometimes | Higher infra |

TikHub handles CDN redirects, watermark removal, and API rate limits automatically.

## Accepted Input Formats

| Format | Example |
|--------|---------|
| Short link | `https://v.douyin.com/iABCxyz/` |
| Full URL with video path | `https://www.douyin.com/video/7615599455526585067` |
| URL with modal_id param | `https://www.douyin.com/jingxuan?modal_id=7615599455526585067` |
| Bare modal_id (16–19 digits) | `7615599455526585067` |

## Output

```
Modal ID: 7615599455526585067
Title: 视频标题
Author: @creator_name
Duration: 2:34
File: ~/Downloads/douyin/douyin_7615599455526585067.mp4 (45.2 MB)
```

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `tikhub_api_token missing` | Config not set | Clear setup instructions + link to register |
| `401 Unauthorized` | Token invalid/expired | Prompt to check/renew token |
| `404 Not Found` | Video deleted or private | "Video not available (deleted or private)" |
| `429 Rate Limited` | API quota exceeded | Wait message + quota info |
| Link expired | Short link no longer valid | "Link expired, please copy a new link" |

## Limitations

- **No live streams**: Real-time streams cannot be downloaded
- **No image carousels (图集)**: Photo posts are not supported — video only
- **No private videos**: Account login not supported
- **Free tier quota**: ~500 API calls/day (TikHub free plan)

## Related Skills

- `content-inbox` — Orchestrates douyin-dl as part of the full content pipeline
- `video-analyzer` — Transcribe and analyze downloaded videos
