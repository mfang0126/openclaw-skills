---
name: html2img
description: |
  Convert HTML or Markdown to a PNG image using headless Playwright. Zero tokens,
  auto-crops to content size, no GUI required. Works on any machine with Playwright installed.

  USE FOR:
  - "转成图片", "截图这个表格", "render as image", "table to image"
  - "生成图片", "make it visual", "发个图", "screenshot this HTML"
  - "markdown to image", "HTML to PNG", "把这个变成图片发出来"
  - Converting comparison tables, reports, dashboards to shareable images
  - Rendering Markdown documents as styled PNG for Discord/Telegram/Slack

  REPLACES: html-screenshot (that skill requires desktop GUI browser)
  REQUIRES: playwright-core (node module), python3
metadata:
  openclaw:
    emoji: "🖼️"
    requires:
      bins: ["node", "python3"]
---

# html2img

**Pattern: Pipeline** (Google ADK) — Input → Convert → Render → Crop → Output

Convert HTML/Markdown files to auto-cropped PNG images. Headless, zero tokens.

## When to Use

- User wants a table, report, or document rendered as an image
- Sharing styled content to channels that don't render Markdown well
- Generating visual artifacts (comparison tables, dashboards, charts)

**Don't use when:** User just wants to view a webpage (use browser), or needs interactive screenshots of live sites (use html-screenshot or agent-browser).

## Prerequisites

- `playwright-core` installed (check: `node -e "require('playwright-core')"`)
- `python3` available (for temp HTTP server)
- Chromium browser installed for Playwright

## Quick Start

```bash
# HTML file → PNG
~/.openclaw/skills/html2img/scripts/html2img.sh input.html output.png

# Markdown file → PNG (auto-converts to styled HTML first)
~/.openclaw/skills/html2img/scripts/html2img.sh input.md output.png
```

## Pipeline

```
Input (.html or .md)
    │
    ├── .md file? → Convert to styled HTML (dark theme)
    │
    ├── Start temp HTTP server (random port)
    │
    ├── Launch headless Chromium
    │
    ├── Load page → Measure content size
    │
    ├── Resize viewport to exact content dimensions
    │
    ├── Screenshot → Save PNG
    │
    └── Cleanup (kill server, close browser)
```

## Supported Inputs

| Input | How |
|-------|-----|
| `.html` file | Direct render |
| `.md` file | Auto-convert to HTML with dark theme styling |

## Output

- PNG file, auto-cropped to content size
- No whitespace padding beyond what the HTML defines
- Typical size: 20-50KB for tables

## Examples

### Example 1: Comparison table

**User says:** "帮我把这个对比表格转成图片发出来"
**Steps:**
```bash
# Write HTML
cat > /tmp/compare.html << 'EOF'
<html><head><style>
body { background: #0d1117; padding: 16px; font-family: sans-serif; display: inline-block; }
table { border-collapse: collapse; }
th { background: #161b22; color: #58a6ff; padding: 8px 12px; }
td { color: #e6edf3; padding: 8px 12px; border-bottom: 1px solid #21262d; }
</style></head><body>
<table>
<tr><th>Feature</th><th>A</th><th>B</th></tr>
<tr><td>Speed</td><td>Fast</td><td>Slow</td></tr>
<tr><td>Cost</td><td>$10</td><td>$50</td></tr>
</table></body></html>
EOF

# Convert
html2img /tmp/compare.html /tmp/compare.png
```
**Output:** `/tmp/compare.png` — auto-cropped PNG (~30KB)
**Reply:** "已生成图片 `/tmp/compare.png`，可直接发送到 Discord/Telegram。"

### Example 2: Markdown report
```bash
echo "# Daily Report\n- Task 1 ✅\n- Task 2 ⚠️" > /tmp/report.md
html2img /tmp/report.md /tmp/report.png
```

## Error Handling

| Error | Cause | Fix |
|-------|-------|-----|
| `Cannot find module 'playwright-core'` | Not installed | Set PW_CORE path in script |
| `Port already in use` | Rare collision | Script uses random port, retry |
| `Chromium not found` | Playwright browsers not installed | `npx playwright install chromium` |

## Tips for Best Results

- Add `display: inline-block` to `<body>` in your HTML for tight cropping
- Use dark theme (`background: #0d1117`) for Discord-friendly images
- Keep tables under 1000px wide for mobile readability
