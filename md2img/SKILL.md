---
user-invocable: false
name: md2img
description: |
  Convert Markdown to high-quality PNG/JPG images with zero whitespace, syntax
  highlighting (Shiki), and optional KaTeX math support. Uses Playwright (Chromium)
  for rendering with GitHub-style default theme.

  USE FOR:
  - Any request to render Markdown as an image
  - Code snippet screenshots with syntax highlighting
  - Markdown with math formulas (use --math flag)
  - Generating styled images for Discord/Telegram/Slack
  - "markdown转图片", "把这段md变成图片", "render markdown as image", "screenshot this code"
  - Converting README, changelogs, or docs to shareable images

  REQUIRES: md2img (npm global), playwright-core, chromium browser
metadata:
  openclaw:
    emoji: "🖼️"
    requires:
      bins: ["md2img", "node"]
---

# 🖼️ md2img — Markdown to Image

> **Pattern: Tool Wrapper** — Provides knowledge for rendering Markdown to images via the `md2img` CLI. Zero-whitespace, syntax-highlighted, math-ready.

## The Problem

Markdown is plain text — you can't share it as a visual on Discord, Telegram, or Slack without losing formatting. Screenshots from editors are inconsistent and often include editor chrome.

## The Solution

`md2img` renders Markdown via Playwright (headless Chromium) and auto-crops to exact content size. GitHub-style theme out of the box, Shiki syntax highlighting, KaTeX math support.

## When to Use

- User wants Markdown rendered as an image
- Sharing code snippets with syntax highlighting as images
- Converting technical docs (with math) to visual format
- Generating styled PNG for channels that don't render Markdown

**Don't use when:** User wants HTML→image (use html2img), or needs interactive screenshots (use browser skills).

## Prerequisites

1. `md2img` CLI installed: `npm install -g md2img`
2. Playwright Chromium: `npx playwright install chromium`

Verify:
```bash
md2img --help
```

## Usage

### File → Image
```bash
md2img input.md -o output.png
```

### stdin → Image
```bash
echo "# Hello World" | md2img -o output.png
```

### With Math (KaTeX)
```bash
md2img input.md -o output.png --math
```

### JPEG Output
```bash
md2img input.md -o output.jpg --format jpg
```

### Custom Width
```bash
md2img input.md -o output.png --width 1200
```

### Custom CSS
```bash
md2img input.md -o output.png --css custom.css
```

## Parameters

| Param | Description | Default |
|-------|-------------|---------|
| `<input>` or stdin | Markdown file path or piped content | required |
| `-o, --output <path>` | Output image path (auto-detects format from extension) | required |
| `--format <png\|jpg>` | Force output format | png |
| `--math` | Enable KaTeX math rendering (`$...$`, `$$...$$`) | off |
| `--css <path>` | Custom CSS override | GitHub theme |
| `--width <px>` | Render width | 800 |
| `-h, --help` | Show help | — |

## Pipeline

```
Input (.md file or stdin)
    │
    ├── Parse Markdown → HTML
    │
    ├── Shiki syntax highlighting (code blocks)
    │
    ├── KaTeX rendering (if --math)
    │
    ├── Apply GitHub-style theme (or --css override)
    │
    ├── Playwright headless render
    │
    ├── Zero-whitespace crop (scan + trim)
    │
    └── Save PNG/JPG
```

## Agent Integration Rules

**Use this skill when:** Any task requires converting Markdown content to an image.

### ✅ Always Use md2img For:
- Rendering Markdown as PNG/JPG
- Code snippet screenshots with syntax highlighting
- Math formulas as images
- Visual output for chat platforms

### ❌ Don't Use For:
- HTML→image (use html2img skill)
- Interactive page screenshots (use browser skills)
- File format conversions (use ffmpeg or imagemagick)

## Examples

### Example 1: Code snippet → image

**User says:** "把这个代码截图发出来"
```bash
cat > /tmp/snippet.md << 'EOF'
```typescript
function greet(name: string): string {
  return `Hello, ${name}!`;
}
console.log(greet("World"));
\```
EOF
md2img /tmp/snippet.md -o /tmp/snippet.png
```

### Example 2: Math formulas

**User says:** "把这段数学公式转成图片"
```bash
md2img /tmp/formulas.md -o /tmp/formulas.png --math
```

### Example 3: Quick one-liner via stdin

```bash
echo "# Report\n\n- Item 1 ✅\n- Item 2 ⚠️" | md2img -o /tmp/report.png
```

### Example 4: Custom width for social media

```bash
md2img /tmp/announcement.md -o /tmp/announcement.png --width 1200
```

## Error Handling

| Error | Cause | Fix |
|-------|-------|-----|
| `md2img: command not found` | CLI not installed globally | `npm install -g md2img` |
| `Chromium not found` | Playwright browsers missing | `npx playwright install chromium` |
| `Cannot find module 'playwright-core'` | Dependency missing | `npm install -g playwright-core` |
| Empty / blank output | Input file empty or unreadable | Check file exists and has content |
| Permission denied | Output path not writable | Use `/tmp/` or verify directory permissions |
| `EPIPE` broken pipe | stdin closed prematurely | Ensure input is piped correctly |

## Output

- PNG or JPG, auto-cropped to exact content size (zero whitespace padding)
- GitHub-style default theme (dark code blocks, clean typography)
- Typical size: 20-100KB depending on content
