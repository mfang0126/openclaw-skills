# UPGRADE_PLAN: platform-bridge

> Generated: 2026-03-25 | SOP Version: 1.0

## Pattern Classification

**Pattern: Tool Wrapper**
Rationale: Acts as a unified adapter layer that wraps multiple external platform APIs and download tools (TikHub, Playwright, yt-dlp). The skill hides implementation differences and exposes a single consistent interface — the definition of Tool Wrapper.

## Current State

| File | Status |
|------|--------|
| SKILL.md | ✅ Exists (very detailed, structure issues) |
| README.md | ❌ Missing |
| _meta.json | ❌ Missing |
| evals/evals.json | ❌ Missing |
| scripts/ | ⚠️ Directory exists but empty |
| adapters/ | ⚠️ Directory exists (contents not verified) |

**Missing files: 3** (README.md, _meta.json, evals/evals.json) + scripts need population

## SKILL.md Issues

| Check | Status | Notes |
|-------|--------|-------|
| `name` + `description` in frontmatter | ✅ | Present |
| Description is pushy with trigger keywords | ❌ | Description is functional, lacks trigger phrases |
| `USE FOR:` section | ❌ | Missing entirely |
| `REPLACES:` | ➖ | N/A |
| `REQUIRES:` | ❌ | Not in frontmatter; mentioned inline only |
| Pattern label | ❌ | Missing — add "**Pattern: Tool Wrapper**" |
| `When to Use` section | ❌ | Missing — no user-facing trigger guidance |
| `Prerequisites` section | ❌ | Missing (TikHub token, yt-dlp, Playwright setup) |
| `Quick Start` | ❌ | Missing — no entry point example |
| `Instructions` | ✅ | Adapter code is detailed |
| At least 1 complete `Example` | ❌ | No end-to-end usage examples |
| `Error Handling` table | ✅ | Has error types and HTTP status handling |
| < 500 lines | ✅ | Within limit |

## Action Plan

### Priority 1 — Fix SKILL.md

1. Update frontmatter description to be pushy:
   ```
   description: "下载抖音/小红书/B站/YouTube视频的统一接口。
   Use when: 下载视频, 抖音链接, 小红书笔记, youtube下载, bilibili, 平台下载, 视频提取"
   ```
2. Add `REQUIRES:` to frontmatter: `python3, requests, yt-dlp, playwright (optional), tikhub_api_token`
3. Add `**Pattern: Tool Wrapper**` near top of body
4. Add `When to Use` section — trigger phrases: user pastes a video URL, asks to download content, mentions any supported platform
5. Add `Prerequisites` section:
   - Python 3.8+
   - `pip install requests playwright`
   - `pip install yt-dlp`
   - TikHub API token in `~/.openclaw/config.json` (for 抖音/小红书)
6. Add `Quick Start` section:
   ```python
   from platform_bridge import download
   result = download("https://v.douyin.com/xxx", {"quality": "highest"})
   print(result["video_path"])
   ```
7. Add `USE FOR:` section with example phrases
8. Add 2+ complete end-to-end examples (抖音 + YouTube)

### Priority 2 — Verify & Create Scripts

Check `scripts/` and `adapters/` contents:
- If adapters exist → test headless: `python adapters/douyin.py <test-url>`
- If empty → create `scripts/download.py` as the unified CLI entry point:
  ```
  python scripts/download.py <url> [--quality highest] [--output-dir .]
  ```
- Ensure all scripts work without GUI (headless Playwright only)

### Priority 3 — Create Missing Files

#### `_meta.json`
```json
{
  "name": "platform-bridge",
  "version": "1.0.0",
  "author": "King",
  "pattern": "Tool Wrapper",
  "emoji": "🌉",
  "created": "2026-03-25",
  "requires": {
    "bins": ["python3", "yt-dlp"],
    "modules": ["requests", "playwright"]
  },
  "tags": ["download", "douyin", "xiaohongshu", "youtube", "bilibili", "platform"]
}
```

#### `evals/evals.json`
Minimum 3 test cases:
1. Douyin URL → expects DownloadResult with video_path, metadata, platform="douyin", method="tikhub"
2. YouTube URL → expects DownloadResult with video_path, platform="youtube", method="yt-dlp"
3. Unknown URL → expects UnknownPlatformError

#### `README.md`
- Architecture: platform detection → adapter selection → method cascade
- Why Tool Wrapper: unified API hides TikHub vs Playwright vs yt-dlp differences
- TikHub cost model and when to use Playwright fallback
- Supported platforms and known limitations (公众号 has no video usually)
- How to add a new platform adapter
- Related skills: `content-inbox`

## Estimated Effort

| Task | Effort |
|------|--------|
| Fix SKILL.md | ~30 min |
| Audit/create scripts | ~45 min |
| Write README.md | ~20 min |
| Write _meta.json | ~5 min |
| Write evals.json | ~20 min |
| Total | ~120 min |
