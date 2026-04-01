---
user-invocable: false
name: snap
source: clawhub.ai/snap (v1.0.2) — snap
description: |
  Give your agent the ability to instantly take screenshots of any website with just the URL.
  Cloud-based, free, open source. Powered by headless Chromium.

  USE FOR:
  - "screenshot", "截图", "帮我截个图", "capture this website"
  - "take a photo of", "what does X look like", "show me the page"
  - "snap a screenshot", "get a screenshot of"
  - 任何 URL + 视觉请求（"这个网站长什么样？"）
  - "网页截图" / "帮我拍下这个页面" / "看看这个页面"
  - User pastes a URL and wants to see what it looks like
metadata:
  author: Kav-K
  version: "1.0"
---
# SnapService — Screenshot as a Service

**Pattern: Tool Wrapper**

Free screenshot API at `https://snap.llm.kaveenk.com`.
POST a URL, get a PNG/JPEG back. Powered by headless Chromium.

## When to Use

Use when the user wants a **visual snapshot of a webpage**: asking what a site looks like, capturing a page for sharing, or verifying a deployed page. Triggers on any "screenshot", "截图", "snap", "capture" request paired with a URL.

**Don't use when:** The user needs to *interact* with the page (use the browser tool instead), or needs a live browser session rather than a static snapshot.

## Prerequisites

- `curl` on PATH (for CLI usage)
- A registered API key from `https://snap.llm.kaveenk.com/api/register` (free, one per IP)
- Network access to `snap.llm.kaveenk.com` (cloud service, no local install required)

## Quick Start (2 steps)

### Step 1: Register for an API key

```bash
curl -s -X POST https://snap.llm.kaveenk.com/api/register \
  -H "Content-Type: application/json" \
  -d '{"name":"my-agent"}'
```

Response:
```json
{"key":"snap_abc123...","name":"my-agent","limits":{"per_minute":2,"per_day":200}}
```

**IMPORTANT:** Store `key` securely. It cannot be recovered.

Each IP address can only register one API key.

### Step 2: Take screenshots

```bash
curl -s -X POST https://snap.llm.kaveenk.com/api/screenshot \
  -H "Authorization: Bearer snap_yourkey" \
  -H "Content-Type: application/json" \
  -d '{"url":"https://example.com"}' \
  -o screenshot.png
```

That's it. Two steps.

## Screenshot Options

All options go in the POST body alongside `url`:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `url` | string | **required** | URL to screenshot |
| `format` | string | `"png"` | `"png"` or `"jpeg"` |
| `full_page` | boolean | `false` | Capture entire scrollable page |
| `width` | integer | `1280` | Viewport width (pixels) |
| `height` | integer | `720` | Viewport height (pixels) |
| `dark_mode` | boolean | `false` | Emulate dark color scheme |
| `selector` | string | — | CSS selector to screenshot specific element |
| `wait_ms` | integer | `0` | Extra wait time after page load (max 10000) |
| `scale` | number | `1` | Device scale factor (1-3, for retina) |
| `cookies` | array | — | Array of `{name, value, domain}` objects |
| `headers` | object | — | Custom HTTP headers |
| `block_ads` | boolean | `false` | Block common ad/tracker domains |

## Rate Limits

- **2 screenshots per minute** per key
- **200 screenshots per day** per key
- **1 API key per IP address**
- Max page height: 16384px (full-page mode)
- Max screenshot size: 10MB

## Response

- **200**: PNG or JPEG image binary
- **400**: Invalid request (missing URL, invalid options)
- **401**: Missing or invalid API key
- **409**: IP already has an API key (on registration)
- **429**: Rate limit exceeded
- **500**: Internal error

## Example with all options

```bash
curl -s -X POST https://snap.llm.kaveenk.com/api/screenshot \
  -H "Authorization: Bearer snap_yourkey" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://example.com",
    "format": "jpeg",
    "full_page": true,
    "width": 1920,
    "height": 1080,
    "dark_mode": true,
    "wait_ms": 2000,
    "block_ads": true
  }' \
  -o screenshot.jpg
```

## Python example

```python
import requests

API = "https://snap.llm.kaveenk.com"

# Register (one-time)
r = requests.post(f"{API}/api/register", json={"name": "my-agent"})
key = r.json()["key"]

# Screenshot
r = requests.post(f"{API}/api/screenshot",
    headers={"Authorization": f"Bearer {key}"},
    json={"url": "https://example.com", "full_page": True})
with open("shot.png", "wb") as f:
    f.write(r.content)
```

## Example

**User says:** "帮我截个图看看 google.com 长什么样"

**Steps:**
1. Check for stored API key; if none, register: `curl -s -X POST https://snap.llm.kaveenk.com/api/register -H "Content-Type: application/json" -d '{"name":"my-agent"}'`
2. Take screenshot: `curl -s -X POST https://snap.llm.kaveenk.com/api/screenshot -H "Authorization: Bearer snap_yourkey" -H "Content-Type: application/json" -d '{"url":"https://google.com"}' -o /tmp/snap-google.png`
3. Display the saved PNG image to the user

**Output:** PNG image of google.com at 1280×720 viewport

**Reply:** "这是 google.com 现在的样子 👆 如需全页截图或调整尺寸，告诉我。"

## Error Handling

| Error | Cause | Solution |
|-------|-------|----------|
| HTTP 401 | Missing or invalid API key | Re-register or check stored key value |
| HTTP 409 | IP already has an API key | Retrieve existing key from storage; each IP gets one key |
| HTTP 429 | Rate limit exceeded (2/min or 200/day) | Wait before retrying; consider caching screenshots |
| HTTP 400 | Invalid request (missing URL or bad option) | Verify URL is well-formed and options match the schema |
| HTTP 500 | Internal server error (page crash or timeout) | Retry with `wait_ms` increased; try without `full_page` |
| Screenshot file is 0 bytes | Page blocked or returned empty | Check URL is publicly accessible; try `block_ads: true` |
