# snap

> Instantly screenshot any public URL via the Snap cloud API. No local browser required.

## Install

No installation needed. Uses `curl` to call the cloud API.

## Usage

```bash
# Register once (per IP)
curl -s -X POST https://snap.llm.kaveenk.com/api/register \
  -H "Content-Type: application/json" \
  -d '{"name":"my-agent"}'

# Screenshot any URL
./scripts/snap.sh https://example.com snap_yourkey output.png
```

## How It Works

**Pattern: Tool Wrapper** (Google ADK)

```
User request (URL)
  → Register API key (one-time per IP)
  → POST /api/screenshot with options
  → Snap service renders with headless Chromium
  → Returns PNG/JPEG binary
  → Save to file
```

## Rate Limits

| Limit | Value |
|-------|-------|
| Per minute | 2 screenshots |
| Per day | 200 screenshots |
| API keys per IP | 1 |

## Design Decisions

- **Cloud API over local browser**: Zero setup, no Playwright/Puppeteer deps, works in any environment
- **One key per IP**: Prevents abuse; key cannot be recovered if lost
- **Supports dark mode, full-page, selectors**: Covers most screenshot use cases

## Limitations

- Requires a public URL (no localhost, no private IPs)
- 1 API key per IP — cannot register multiple keys from same machine
- Rate limited to 200/day — not suitable for bulk screenshot jobs
- Key cannot be recovered if lost — store it securely

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/snap.sh` | CLI wrapper: URL + key → PNG file |

## Related Skills

- `html2img` — Local HTML/Markdown to PNG (no API key needed, works offline)
- `agent-browser` — Interactive browser automation (uses tokens, for dynamic sites)
