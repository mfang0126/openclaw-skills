# mermaid-architect

> Generate and render Mermaid diagrams to PNG/SVG images using mermaid-cli (mmdc).

## Install

```bash
npm install -g @mermaid-js/mermaid-cli
# Linux only: apt install chromium
```

## Usage

```bash
# Write diagram to .mmd file, then render
mmdc -i diagram.mmd -o diagram.png -b white -w 1600 -H 800

# Or use the helper script
~/.openclaw/skills/mermaid-architect/scripts/render.sh diagram.mmd diagram.png
```

## How It Works

**Pattern: Generator** (Google ADK)

```
User description
  → Write Mermaid syntax to .mmd file
  → mmdc (mermaid-cli) invokes Puppeteer
  → Puppeteer launches headless Chromium
  → Renders diagram to viewport
  → Screenshots → PNG/SVG/PDF output
```

## Design Decisions

- **Write to .mmd first**: The source diagram file is reusable and versionable. Never render inline without saving.
- **White background by default**: Works in both light and dark interfaces.
- **1600px wide**: Better for complex diagrams; mmdc auto-scales content.
- **PNG over SVG for sharing**: PNG works universally in Discord/Telegram/Slack; SVG only needed when editing.

## Supported Diagram Types

| Type | Keyword | Example Use |
|------|---------|-------------|
| Flowchart | `flowchart TD` | Process flows, decision trees |
| Sequence | `sequenceDiagram` | API calls, protocol flows |
| Class | `classDiagram` | OOP inheritance, data models |
| State | `stateDiagram-v2` | FSMs, lifecycle states |
| ER | `erDiagram` | Database schemas |
| Gantt | `gantt` | Project timelines |
| Pie | `pie` | Distribution charts |

## Output Formats

| Format | Flag | Use |
|--------|------|-----|
| PNG | `-o file.png` | Sharing, embedding |
| SVG | `-o file.svg` | Editing, scaling |
| PDF | `-o file.pdf` | Reports, printing |

## Limitations

- Complex diagrams with 50+ nodes may need manual layout tweaks
- Subgraph IDs must not contain spaces (use camelCase)
- Font rendering depends on system fonts — different machines may look slightly different
- Puppeteer requires Chromium; on headless servers, install `chromium-browser`

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/render.sh` | Thin wrapper: `render.sh input.mmd [output.png]` |

## References

- [Syntax Guide](references/syntax-guide.md)
- [Official Mermaid Docs](https://mermaid.js.org/)
