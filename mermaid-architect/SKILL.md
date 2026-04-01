---
user-invocable: false
name: mermaid-architect
source: clawhub.ai/mermaid-architect (v1.0.0) — mermaid-architect
description: Generate and render Mermaid diagrams to PNG/SVG images. Use when user asks for "diagram", "flowchart", "sequence diagram", "visualize", "draw this", "make a chart", "architecture diagram", or "visualize this flow".
---

# Mermaid Architect

**Pattern: Generator** (Google ADK) — Describe → Write .mmd → Render → Output image

Generate beautiful diagrams and render them to images using mermaid-cli (mmdc).

## USE FOR
- "draw me a flowchart of X"
- "create a sequence diagram for Y"
- "visualize this architecture"
- "make a diagram showing..."
- "diagram", "flowchart", "sequence diagram", "draw this", "make a chart"
- "class diagram", "state diagram", "ER diagram", "Gantt chart"
- "把这个画成图", "画个流程图", "做个架构图"

## REPLACES
- N/A (no predecessor skill)

## REQUIRES
- `mmdc` (mermaid-cli): `npm install -g @mermaid-js/mermaid-cli`
- Node.js 18+
- Puppeteer (installed automatically with mmdc)

## When to Use

Use this skill whenever the user requests any kind of diagram, chart, or visual representation of a process, system, or data structure.

Trigger keywords: diagram, flowchart, sequence diagram, class diagram, visualize, draw this, chart, architecture diagram, 画图, 流程图, 架构图.

**Don't use when:** User wants a complex interactive visualization (use a JS charting library), or needs to edit an existing image (use an image editor).

## Prerequisites

- `mmdc` installed and on PATH: `which mmdc`
- If not installed: `npm install -g @mermaid-js/mermaid-cli`
- Puppeteer dependencies (Linux): `apt install chromium`

## Quick Start

```bash
# 1. Write diagram to .mmd file
# 2. Render with mmdc
mmdc -i diagram.mmd -o diagram.png -b white -w 1600 -H 800

# Or use the render script
~/.openclaw/skills/mermaid-architect/scripts/render.sh diagram.mmd diagram.png
```

## Workflow

1. **Write Mermaid code** to `.mmd` file based on user's description
2. **Render** with `mmdc` to PNG/SVG
3. **Show** the image to user

## mmdc Options

| Option | Description | Default |
|--------|-------------|---------|
| `-i` | Input file (.mmd) | required |
| `-o` | Output file (.png/.svg/.pdf) | input + .svg |
| `-b` | Background color | white |
| `-w` | Width (px) | 800 |
| `-H` | Height (px) | 600 |
| `-t` | Theme (default/forest/dark/neutral) | default |

## Diagram Types

- `flowchart` / `graph` — Flowcharts
- `sequenceDiagram` — Sequence diagrams
- `classDiagram` — Class diagrams
- `stateDiagram-v2` — State diagrams
- `erDiagram` — ER diagrams
- `gantt` — Gantt charts
- `pie` — Pie charts

## Example

**User:** "Draw a flowchart for user login"

```
# 1. Write diagram.mmd
cat > /tmp/login.mmd << 'EOF'
flowchart TD
    A([Start]) --> B[Enter Credentials]
    B --> C{Valid?}
    C -- Yes --> D[Dashboard]
    C -- No --> E[Show Error]
    E --> B
EOF

# 2. Render
mmdc -i /tmp/login.mmd -o /tmp/login.png -b white -w 1200 -H 800
```

Result: `/tmp/login.png` — a clean flowchart image ready to share.

**Output:** `/tmp/login.png` — rendered PNG flowchart showing the login decision tree.
**Reply:** "Here's your login flowchart! [attaches `/tmp/login.png`]"

## Syntax Tips

- Node IDs: no spaces, use camelCase
- Labels with special chars: use quotes `"Label Text"`
- Layout: `TD` (top-down), `LR` (left-right), `RL`, `BT`
- Subgraphs: `subgraph id [Label]` (no spaces in id)

## Error Handling

| Error | Cause | Fix |
|-------|-------|-----|
| `mmdc: command not found` | mermaid-cli not installed | `npm install -g @mermaid-js/mermaid-cli` |
| `Error: spawn chromium` | Puppeteer can't find browser | `npx puppeteer browsers install chrome` |
| Syntax error in .mmd | Invalid Mermaid syntax | Check node IDs (no spaces), quote special chars |
| Output file empty | Puppeteer timeout | Add `--puppeteerConfigFile` with longer timeout |
| `ENOENT: no such file` | Input .mmd not found | Check file path is absolute or relative to cwd |

## References

- [Syntax Guide](references/syntax-guide.md)
- [Mermaid Docs](https://mermaid.js.org/syntax/flowchart.html)
