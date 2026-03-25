# Upgrade Plan: mermaid-architect

> Generated: 2026-03-25 | SOP Version: 1.0

## Pattern Classification

**Pattern: Generator**
> "Fixed-format output" — takes a description and produces a rendered Mermaid diagram image (.png/.svg).

## Current State

| File | Status |
|------|--------|
| SKILL.md | ✅ Exists (incomplete) |
| README.md | ❌ Missing |
| _meta.json | ✅ Exists (minimal) |
| evals/evals.json | ❌ Missing |
| scripts/ | ❌ Missing (no scripts directory) |
| references/syntax-guide.md | ✅ Exists |

**Missing files: 3** (README.md, evals/evals.json, scripts/)

## SKILL.md Issues

SKILL.md exists but is missing multiple required sections:

| Check | Status |
|-------|--------|
| `name` + `description` frontmatter | ✅ |
| Description is pushy with trigger keywords | ✅ |
| `USE FOR:` section | ❌ Missing |
| `REPLACES:` | ❌ Missing (or explicitly N/A) |
| `REQUIRES:` dependencies | ❌ Missing |
| Pattern label (`**Pattern: Generator**`) | ❌ Missing |
| `When to Use` section | ❌ Missing |
| `Prerequisites` section | ❌ Missing |
| `Quick Start` | ✅ Exists |
| `Instructions` / workflow | ✅ Exists (Workflow section) |
| At least 1 complete `Example` | ⚠️ Partial (command only, no full example) |
| `Error Handling` table | ❌ Missing |
| < 500 lines | ✅ |

## _meta.json Issues

Current _meta.json is minimal (marketplace format only). Needs SOP-standard fields:
- Missing: `author`, `pattern`, `emoji`, `requires`, `tags`

## Action Items

### Priority 1 — Fix SKILL.md

Add the following sections:

**After frontmatter, add pattern label:**
```markdown
**Pattern: Generator**
```

**Add USE FOR: section:**
```markdown
## USE FOR
- "draw me a flowchart of X"
- "create a sequence diagram for Y"
- "visualize this architecture"
- "make a diagram showing..."
- "diagram", "flowchart", "sequence diagram", "draw this", "make a chart"
```

**Add REQUIRES: section:**
```markdown
## REQUIRES
- `mmdc` (mermaid-cli): `npm install -g @mermaid-js/mermaid-cli`
- Node.js 18+
- Puppeteer (installed with mmdc)
```

**Add Prerequisites section:**
```markdown
## Prerequisites
- mmdc installed and on PATH: `which mmdc`
- Puppeteer dependencies installed (Linux: `apt install chromium`)
```

**Add When to Use section:**
```markdown
## When to Use
Use this skill whenever the user requests any kind of diagram, chart, or visual representation.
Trigger keywords: diagram, flowchart, sequence diagram, visualize, draw this, chart, architecture diagram.
```

**Add Error Handling table:**
```markdown
## Error Handling

| Error | Cause | Fix |
|-------|-------|-----|
| `mmdc: command not found` | mermaid-cli not installed | `npm install -g @mermaid-js/mermaid-cli` |
| `Error: spawn chromium` | Puppeteer can't find browser | `npx puppeteer browsers install chrome` |
| Syntax error in .mmd | Invalid Mermaid syntax | Check node IDs (no spaces), quote special chars |
| Output file empty | Puppeteer timeout | Add `--puppeteerConfigFile` with longer timeout |
```

**Expand Example section** with a full end-to-end example (write .mmd, render, show result).

### Priority 2 — Create scripts/

```bash
mkdir -p ~/.openclaw/skills/mermaid-architect/scripts
```

Create `scripts/render.sh`:
```bash
#!/bin/bash
# Usage: render.sh <input.mmd> [output.png]
INPUT="$1"
OUTPUT="${2:-${INPUT%.mmd}.png}"
mmdc -i "$INPUT" -o "$OUTPUT" -b white -w 1600 -H 800
echo "Rendered: $OUTPUT"
```

```bash
chmod +x ~/.openclaw/skills/mermaid-architect/scripts/render.sh
```

### Priority 3 — Create evals/evals.json

```bash
mkdir -p ~/.openclaw/skills/mermaid-architect/evals
```

```json
{
  "skill_name": "mermaid-architect",
  "pattern": "Generator",
  "evals": [
    {
      "id": 1,
      "prompt": "Draw a flowchart of a user login flow",
      "input": "User login: start → enter credentials → validate → success or retry",
      "expected": "Valid .mmd file created and rendered to .png without errors"
    },
    {
      "id": 2,
      "prompt": "Create a sequence diagram for an API request",
      "input": "Client calls API, API calls DB, DB returns data, API responds to client",
      "expected": "sequenceDiagram .mmd rendered to .png with all 4 actors"
    },
    {
      "id": 3,
      "prompt": "Visualize a class hierarchy",
      "input": "Animal base class, Dog and Cat subclasses, each with name and sound methods",
      "expected": "classDiagram .mmd rendered showing inheritance relationships"
    }
  ]
}
```

### Priority 4 — Create README.md

Cover:
- How mmdc works (Puppeteer + headless Chrome)
- Why we write to .mmd first (reusable, versionable)
- Supported output formats (PNG, SVG, PDF)
- Limitations (complex diagrams may need manual layout tweaks)
- Related skills: none currently

### Priority 5 — Update _meta.json

```json
{
  "name": "mermaid-architect",
  "version": "1.0.0",
  "author": "King",
  "pattern": "Generator",
  "emoji": "🗺️",
  "created": "2026-03-25",
  "requires": {
    "bins": ["mmdc", "node"],
    "modules": []
  },
  "tags": ["diagram", "mermaid", "visualization", "chart", "flowchart"],
  "ownerId": "kn75beh7fdqwjqc7rd6q1fnk2x81082h",
  "slug": "mermaid-architect",
  "publishedAt": 1770939197462
}
```

## Final Checklist

- [ ] SKILL.md updated: pattern label, USE FOR, REQUIRES, Prerequisites, When to Use, Error Handling, full Example
- [ ] Pattern labeled as **Generator**
- [ ] scripts/render.sh created and executable
- [ ] evals/evals.json has ≥ 3 test cases
- [ ] README.md created
- [ ] _meta.json updated with SOP fields
- [ ] Script tested headless
- [ ] `openclaw config validate` passes
