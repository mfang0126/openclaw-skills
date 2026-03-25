# html2img

> Convert HTML or Markdown to auto-cropped PNG images. Headless, zero tokens, no GUI.

## Install

Already installed at `~/.openclaw/skills/html2img/`. Requires `playwright-core` and `python3`.

## Usage

```bash
# HTML → PNG
html2img input.html output.png

# Markdown → PNG (auto-converts with dark theme)
html2img input.md output.png
```

## How It Works

**Pattern: Pipeline** (Google ADK)

```
Input (.html or .md)
  → [Gate: .md?] Convert Markdown to styled HTML
  → Start temp HTTP server
  → Launch headless Chromium
  → Measure content size (body.scrollWidth/Height)
  → Resize viewport to exact content dimensions
  → Screenshot → PNG
  → Cleanup
```

## Design Decisions

- **Headless over desktop browser**: Works without GUI, liurouduan can use it too
- **Auto-crop via inline-block**: `body { display: inline-block }` makes content tight
- **Temp HTTP server**: Chromium can't open `file://` directly, 0.3s overhead
- **playwright-core**: Reuses project's existing installation, no extra deps

## Supported Inputs

| Type | Extension | Processing |
|------|-----------|------------|
| HTML | `.html` | Direct render |
| Markdown | `.md` | Python regex → styled HTML → render |

## Output

- Format: PNG
- Size: Typically 10-50KB
- Dimensions: Auto-matched to content (no fixed viewport)

## Limitations

- Markdown conversion is basic (headers, bold, lists, checkboxes). No tables, no code blocks with syntax highlighting.
- Requires `playwright-core` installed somewhere on the system.
- Max recommended content width: ~1200px (wider may look small on mobile).

## Scripts

| Script | Purpose |
|--------|---------|
| `html2img.sh` | Full version: HTML + Markdown support |
| `html2img-core.sh` | Minimal: HTML only |

## Related Skills

- `html-screenshot` — Desktop browser version (deprecated by this skill)
- `agent-browser` — Interactive browser automation (uses tokens)
- `snap` — Cloud screenshot service (needs API key + public URL)
