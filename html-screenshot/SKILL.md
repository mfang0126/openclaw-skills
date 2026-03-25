---
name: html-screenshot
description: |
  Capture screenshots of HTML files or URLs using agent-browser. Auto-screenshot after visual changes (colors, layout, elements). Cost-free local rendering.

  USE FOR:
  - "截图" / "screenshot" / "帮我截图"
  - "看看效果" / "show me how it looks" / "preview"
  - "渲染一下" / "render this HTML" / "visualize"
  - "帮我看看" / "let me see the result" / "generate preview"
  - User wants to see what an HTML file or URL looks like
  - Auto-trigger after any visual modification (colors, layout, elements)

  REQUIRES:
  - `agent-browser` CLI installed globally
metadata:
  openclaw:
    emoji: "📸"
    requires:
      bins: ["agent-browser"]
---

# HTML Screenshot (Simplified)

**Pattern: Tool Wrapper** (Google ADK) — 检测视觉变更 → 调用 agent-browser → 截图 → 按频道发送

Capture screenshots of HTML files using agent-browser. Auto-screenshot after **visual modifications** only.

**Key Principle**: Only screenshot when it matters (visual changes), not for code refactoring or comments.

## When to Use

- User wants to visualize HTML code
- Generate website mockups or previews
- Create visual documentation
- Compare design variations
- Keywords: "screenshot", "preview", "show me how it looks", "render", "visualize"

**Don't use when:** The user needs an image file from HTML/Markdown (use html2img), or only needs to read text content without visual rendering (use web_fetch).

## Quick Start

```bash
# Screenshot local HTML file
{baseDir}/scripts/screenshot.sh /path/to/file.html /tmp/output.png

# Screenshot URL
{baseDir}/scripts/screenshot.sh https://example.com /tmp/output.png

# Custom viewport size
{baseDir}/scripts/screenshot.sh /path/to/file.html /tmp/output.png 1920x1080

# Full page screenshot
{baseDir}/scripts/screenshot.sh /path/to/file.html /tmp/output.png --full-page
```

## Output

- Returns the path to the saved screenshot
- Default viewport: 1440x900
- Format: PNG with transparency support

## Dependencies

Requires `agent-browser` CLI. Install via:
```bash
npm install -g @antiwork/agent-browser
```

## Examples

### Visualize HTML code
```bash
# After generating HTML, show the user what it looks like
{baseDir}/scripts/screenshot.sh ./design.html /tmp/preview.png
```

### Compare designs
```bash
# Screenshot multiple variations
{baseDir}/scripts/screenshot.sh ./design-v1.html /tmp/v1.png
{baseDir}/scripts/screenshot.sh ./design-v2.html /tmp/v2.png
```

### Generate portfolio mockups
```bash
# Create preview for portfolio section
{baseDir}/scripts/screenshot.sh ./portfolio-section.html /tmp/mockup.png --full-page
```

## When to Screenshot

### Channel-Specific Rules

**Telegram** (High Need - User can't see local files):
- ✅ Any CSS style changes (colors, fonts, sizes, spacing, borders, shadows)
- ✅ Any layout changes (margins, padding, positioning, display)
- ✅ Adding/removing/modifying visible elements
- ✅ Changing visible text (even small changes)
- ❌ Only skip: comments, code formatting, invisible attributes

**Browser/Terminal** (Medium/Low Need - User can view themselves):
- ✅ Significant visual changes (colors, major layout, new elements)
- ❌ Minor tweaks (small text changes, subtle spacing)
- ❌ Code refactoring, comments, formatting

### Universal Exclusions (All Channels)
- ❌ Code refactoring (renaming classes, variables)
- ❌ Adding/removing comments
- ❌ Code formatting (indentation, line breaks)
- ❌ Changing alt text, meta tags, or other invisible content

### User Control

| User says | Action |
|-----------|--------|
| "看看效果" / "截图" / "show me" | Screenshot immediately |
| "不用看" / "不用截图" / "skip" | Don't screenshot this time |
| (nothing) | Auto-screenshot if visual change |

### Judgment Logic

```
Completed modification
  ↓
Check channel
  ├─ Telegram → Is it ANY visual change (loose)?
  │   ├─ Yes → Auto-screenshot and send
  │   └─ No (comments/formatting) → Don't screenshot
  │
  └─ Browser/Terminal → Is it SIGNIFICANT visual change?
      ├─ Yes → Auto-screenshot and send
      └─ No → Don't screenshot, user can view themselves
```

**Rationale**: Telegram users depend on screenshots (can't view local files), while Browser/Terminal users can preview themselves.

## Error Handling

**Never fail silently**. Always inform user if screenshot fails.

### Failure Scenarios

| Failure | Response |
|---------|----------|
| File path error | "Screenshot failed: File not found at [path]" |
| agent-browser not running | "Screenshot failed: Browser not available. File is at: [path]" |
| Render timeout | Retry once, then: "Screenshot timeout. You can open the file manually: [path]" |
| Telegram send failed | "Screenshot ready but send failed: [path]" |

### Fallback
When screenshot fails, always provide:
1. Clear error message
2. File path for manual opening
3. Ask if user wants to retry

**Example**:
```
❌ Screenshot failed: Browser not available
📁 You can open the file here: /path/to/file.html
🔄 Want me to retry?
```

## Smart Channel Adaptation

**Automatically choose the best delivery method based on current channel**:

#### Telegram (`channel=telegram`)
```javascript
// Send image directly (saves tokens, immediate preview)
message({
  action: "send",
  channel: "telegram",
  media: "/tmp/screenshot.png",
  message: "已修改：[说明]"
})
```

#### Web/Browser (`channel=webchat`)
```javascript
// Use Read tool (inline image display)
Read({path: "/tmp/screenshot.png"})
// User sees image directly in chat
```

#### Terminal/CLI (others)
```javascript
// Return file path only
"✓ Screenshot saved: /tmp/screenshot.png\nOpen with: open /tmp/screenshot.png"
```

**Detection**: Check runtime context for `channel` parameter
- `channel=telegram` → Send via message tool
- `channel=webchat` → Use Read tool
- Others → Return path only

### Standard Workflow

When user requests to "see how it looks" or "show me the result":

1. **Generate or locate HTML file**
2. **Take screenshot**: Use scripts/screenshot.sh
3. **Send to user**: Use message tool with the screenshot

```bash
# Step 1 & 2: Generate HTML and screenshot
{baseDir}/scripts/screenshot.sh /path/to/design.html /tmp/preview.png

# Step 3: Send via message tool
# Use: message(action="send", media="/tmp/preview.png", message="Your design preview")
```

### Common Scenarios

**Scenario A: HTML Design Preview**
- User: "生成一个网站预览" or "帮我看看这个 HTML 效果"
- Action: Screenshot HTML → Send to current channel

**Scenario B: Before/After Comparison**
- User: "对比一下两个版本"
- Action: Screenshot both → Send as album or separate messages

**Scenario C: Design Iteration**
- User: "调整一下颜色，再给我看看"
- Action: Modify HTML → Screenshot → Send updated preview

### Integration with Other Skills

- **ui-ux-pro-max**: Generate design → Screenshot → Show preview
- **agent-browser**: Complex interactions → Screenshot result → Send
- **content-research-writer**: Generate article HTML → Screenshot → Preview layout

## Notes

- For file:// URLs, use absolute paths
- agent-browser uses Chromium for rendering
- Screenshots are deterministic (same HTML = same image)
- Supports responsive viewports
- **Always send screenshots to user** when they want to "see" results
