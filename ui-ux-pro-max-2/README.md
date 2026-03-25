# ui-ux-pro-max-2

> UI/UX design intelligence skill. 50+ styles, 97 color palettes, 57 font pairings, 99 UX guidelines, 25 chart types across 9 stacks.

## Pattern: Tool Wrapper

Wraps a Python CLI (`search.py`) that queries a design knowledge database on demand. User asks for UI/UX guidance → skill queries `search.py` → returns design system recommendations, color palettes, typography, and UX best practices.

## ⚠️ Known Issue: scripts/search.py Missing

**The `scripts/` directory does not exist in this skill installation.**

SKILL.md references:
```bash
python3 skills/ui-ux-pro-max/scripts/search.py "<query>" --design-system
```

But `~/.openclaw/skills/ui-ux-pro-max-2/scripts/` does not exist. This skill appears to be a v2 copy of `ui-ux-pro-max` where the `scripts/` directory was not copied over.

**Workaround until fixed:**
1. Check if the original `ui-ux-pro-max` skill has `scripts/search.py`
2. If yes: `cp -r ~/.openclaw/skills/ui-ux-pro-max/scripts ~/.openclaw/skills/ui-ux-pro-max-2/`
3. Or use the SKILL.md Quick Reference sections directly (no script needed) — covers accessibility, touch targets, responsive layout, typography, and animation rules inline.

**Without `search.py`:** The design system generation (`--design-system`) and domain searches (`--domain`) won't work, but the inline Quick Reference in SKILL.md still provides actionable UX rules without any CLI tools.

## Install

```bash
# Check if Python is available
python3 --version

# If scripts/ is missing, copy from original skill (if present)
cp -r ~/.openclaw/skills/ui-ux-pro-max/scripts ~/.openclaw/skills/ui-ux-pro-max-2/
```

## Usage

Ask for UI/UX help naturally:

- "Design a landing page for a fintech SaaS startup"
- "What UI style fits a luxury spa wellness brand?"
- "Review this button component for UX issues"
- "Create a dark mode dashboard with glassmorphism"
- "What color palette should I use for a healthcare app?"

## Design Decisions

- **50+ design styles catalogued**: From glassmorphism to brutalism, each mapped to product types and industries.
- **Reasoning rules in CSV**: `ui-reasoning.csv` selects best style/color/font match based on product type + industry keywords.
- **9 tech stacks supported**: html-tailwind (default), React, Next.js, Vue, Svelte, SwiftUI, React Native, Flutter, shadcn/ui.
- **Hierarchical design systems**: `--persist` creates `design-system/MASTER.md` + per-page overrides for consistent multi-page projects.
- **Priority-based rules**: Accessibility > Touch > Performance > Layout > Typography > Animation > Style > Charts.

## Limitations

- `search.py` and its CSV data files are not included in this v2 install — see ⚠️ above.
- The inline Quick Reference in SKILL.md works without scripts for most common rules.
- Complex design system generation (`--design-system`) requires the Python CLI.
- `shadcn/ui MCP` integration noted in description requires separate MCP setup.

## Related Skills

- `ui-ux-pro-max` — Original v1 (may have the scripts)
- `html2img` — Render UI to PNG for preview
