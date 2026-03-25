# platform-bridge

> 多平台视频下载统一接口。抖音、小红书、公众号、YouTube、B站一个接口全搞定。

**Pattern: Tool Wrapper** (Google ADK)

## How It Works

Platform Bridge detects the source platform from a URL, selects the best download adapter, and cascades through fallback methods if the primary fails:

```
URL 输入
    │
    ├── detect_platform(url)
    │       │
    │       ├── douyin.com / v.douyin.com → DouyinAdapter
    │       ├── xiaohongshu.com           → XiaohongshuAdapter
    │       ├── mp.weixin.qq.com          → WechatAdapter
    │       ├── youtube.com / youtu.be    → YouTubeAdapter
    │       ├── bilibili.com / b23.tv     → BilibiliAdapter
    │       └── unknown                   → UnknownPlatformError
    │
    └── adapter.download(url, options)
            │
            ├── 方法1（优先）: TikHub API / yt-dlp
            │       │
            │       └── 失败? → 方法2（备用）
            │
            └── 方法2（备用）: Playwright headless
                    │
                    └── 失败? → DownloadError
```

## Why Tool Wrapper?

This skill is a **unified API** that hides three completely different download mechanisms (TikHub API, Playwright browser automation, yt-dlp CLI) behind a single `download(url, options) → DownloadResult` interface. The caller doesn't need to know which method was used.

## Supported Platforms

| Platform | Primary | Fallback | Cost |
|----------|---------|----------|------|
| 抖音 | TikHub API | Playwright | $0.001/call |
| 小红书 | TikHub API | Playwright | $0.001/call |
| 公众号 | Playwright | — | Free |
| YouTube | yt-dlp | — | Free |
| B站 | yt-dlp | — | Free |

## TikHub Cost Model

- Default: $0.001 per API call
- Volume discounts apply at 1000+ calls/day
- Playwright fallback is free but slower (~10s vs ~2s)
- Use `prefer_method: "playwright"` to skip TikHub entirely

## Configuration

```json
// ~/.openclaw/config.json
{
  "tikhub_api_token": "your-token-here",
  "download": {
    "default_quality": "highest",
    "timeout": 300,
    "retry_count": 3,
    "prefer_method": "tikhub"
  }
}
```

## Adding a New Platform Adapter

1. Create `adapters/<platform>.py` implementing `download(url, options) → DownloadResult`
2. Add platform detection in `detect_platform()` (URL pattern matching)
3. Add row to the platform support table in SKILL.md
4. Add eval test case in `evals/evals.json`

## Limitations

- 公众号文章通常没有视频，主要提取文字和图片
- Playwright 需要 Chromium 安装 (`playwright install chromium`)
- TikHub token 有余额限制，注意监控用量
- 不支持需要登录才能访问的付费内容

## Related Skills

- `content-inbox` — 调用此 skill 的上层工作流
