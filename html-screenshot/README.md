# html-screenshot

> Capture screenshots of HTML files or URLs using agent-browser. Auto-screenshots on visual changes, channel-aware delivery.

## Install

Already installed at `~/.openclaw/skills/html-screenshot/`. Requires `agent-browser`.

```bash
npm install -g @antiwork/agent-browser
```

## Usage

```bash
# Screenshot local HTML file
~/.openclaw/skills/html-screenshot/scripts/screenshot.sh /path/to/file.html /tmp/output.png

# Screenshot URL
~/.openclaw/skills/html-screenshot/scripts/screenshot.sh https://example.com /tmp/output.png

# Custom viewport size
~/.openclaw/skills/html-screenshot/scripts/screenshot.sh /path/to/file.html /tmp/output.png 1920x1080

# Full page screenshot
~/.openclaw/skills/html-screenshot/scripts/screenshot.sh /path/to/file.html /tmp/output.png --full-page
```

## How It Works

**Pattern: Tool Wrapper** (Google ADK)

```
Trigger (visual change detected OR user requests screenshot)
  │
  ├─ Check: is this a visual change?
  │   ├─ Telegram → loose check (any CSS/layout/text change)
  │   └─ Browser/Terminal → strict check (significant changes only)
  │
  ├─ Call scripts/screenshot.sh → agent-browser → Chromium renders → PNG
  │
  └─ Deliver by channel:
      ├─ telegram → message tool (sends image directly)
      ├─ webchat → Read tool (inline display)
      └─ others → return file path
```

## Channel-Specific Auto-Screenshot Rules

**Telegram** (loose trigger — user can't see local files):
- ✅ Any CSS style changes (colors, fonts, sizes, spacing)
- ✅ Any layout changes (margins, padding, positioning)
- ✅ Adding/removing/modifying visible elements
- ✅ Changing visible text
- ❌ Skip: comments, code formatting, invisible attributes

**Browser/Terminal** (strict trigger — user can view themselves):
- ✅ Significant visual changes (color scheme, major layout, new elements)
- ❌ Skip: minor tweaks, small text changes, subtle spacing

**Universal Exclusions** (all channels):
- ❌ Code refactoring (class/variable renaming)
- ❌ Adding/removing comments
- ❌ Code formatting / indentation

## Design Decisions

- **Why Telegram = loose, Browser = strict?** Telegram users depend entirely on screenshots to see output — they have no way to open local HTML files. Browser users can always preview themselves, so auto-screenshots should only appear for significant changes.
- **Why agent-browser (not html2img)?** html-screenshot uses the desktop browser (supports JS, CSS animations, complex layouts). html2img is headless-only and better for static rendering.
- **Deterministic rendering**: Same HTML always produces the same screenshot, making it reliable for comparison and testing.

## User Control

| User says | Action |
|-----------|--------|
| "看看效果" / "截图" / "show me" | Screenshot immediately |
| "不用看" / "不用截图" / "skip" | Skip this time |
| (no input) | Auto-screenshot if visual change detected |

## Error Handling

**Never fail silently.**

| Failure | Response |
|---------|----------|
| File not found | "Screenshot failed: File not found at [path]" |
| agent-browser not running | "Screenshot failed: Browser not available. File is at: [path]" |
| Render timeout | Retry once → "Screenshot timeout. Open manually: [path]" |
| Telegram send failed | "Screenshot ready but send failed: [path]" |

Always provide: error message + file path + retry option.

## Limitations

- Static HTML only — pages requiring backend interaction (login, API calls) may not render correctly
- Requires `agent-browser` to be installed and functional
- Does not support animated GIFs as output (PNG only)
- Viewport max recommended: 1920px wide

## Related Skills

- `html2img` — Headless PNG rendering (no GUI required, better for CI/automation)
- `agent-browser` — Interactive browser for complex page interactions
- `deploy-artifact` — Share HTML via public URL instead of screenshot
