# UPGRADE_PLAN — ui-ux-pro-max-2

> Generated: 2026-03-25 | SOP Version: 1.0

---

## Pattern Classification

**Pattern: Tool Wrapper**

Rationale: This skill wraps a Python search CLI (`search.py`) that queries a design knowledge database on demand. The user asks for UI/UX guidance → skill calls `search.py` → returns design system recommendations. It loads knowledge on demand from a database, not a fixed pipeline. → Tool Wrapper.

---

## Current State Audit

### Files Present
| File | Present | Notes |
|------|---------|-------|
| SKILL.md | ✅ | Comprehensive — 400+ lines |
| _meta.json | ✅ | Exists |
| .clawhub/origin.json | ✅ | Marketplace origin tracking |
| README.md | ❌ | Missing |
| evals/evals.json | ❌ | Missing (no evals/ dir) |
| scripts/ | ❌ | Missing — SKILL.md references `search.py` but no scripts/ dir |

**Missing files: 3 required (README.md, evals/evals.json, scripts/)**

> ⚠️ **Critical gap**: SKILL.md references `python3 skills/ui-ux-pro-max/scripts/search.py` — but this is `ui-ux-pro-max-2` and `scripts/` directory doesn't exist. Path may be wrong or scripts weren't copied on clone.

---

## _meta.json Current State

```json
// Need to read to verify — file exists but content not checked
```

Verify _meta.json contains: `name`, `version`, `author`, `pattern`, `emoji`, `created`, `requires`, `tags`.

---

## SKILL.md Gaps

| SOP Requirement | Status | Detail |
|----------------|--------|--------|
| `name` + `description` in frontmatter | ✅ | Present, very keyword-dense |
| Description is **pushy** with trigger keywords | ✅ | Excellent — 50+ trigger keywords |
| `USE FOR:` section with example phrases | ⚠️ | No explicit `USE FOR:` block — Example Workflow covers this partially |
| `REPLACES:` section | ➖ | Unclear if replaces `ui-ux-pro-max` v1 |
| `REQUIRES:` dependencies | ✅ | Python prerequisite documented |
| Pattern label | ❌ | No `**Pattern: Tool Wrapper**` label |
| `When to Apply` section | ✅ | Present as "When to Apply" |
| `Prerequisites` section | ✅ | Python install instructions present |
| `Quick Start` section | ⚠️ | No explicit Quick Start — Step 2 is closest |
| `Instructions` | ✅ | Detailed step-by-step workflow |
| At least 1 complete `Example` | ✅ | Full example workflow present |
| `Error Handling` table | ❌ | Missing |
| < 500 lines total | ⚠️ | Likely 450–500+ lines — audit needed |

---

## Upgrade Tasks

### Priority 1 — Critical: Fix Script Path
- [ ] Verify if `scripts/search.py` (and supporting CSVs) need to be present in `ui-ux-pro-max-2/scripts/`
- [ ] If this is a copy of `ui-ux-pro-max`, confirm whether scripts should be copied or symlinked
- [ ] Create `scripts/` directory and add working `search.py` or document the correct path

### Priority 2 — SKILL.md Fixes
- [ ] Add `**Pattern: Tool Wrapper**` label near top
- [ ] Add explicit `USE FOR:` block with 5–8 natural trigger phrases
- [ ] Add `Quick Start` section (single most common command)
- [ ] Add `Error Handling` table: Error | Cause | Fix (e.g., Python not found, search.py not found, no results)
- [ ] Clarify `REPLACES:` if this replaces ui-ux-pro-max v1
- [ ] Audit line count — confirm < 500 lines

### Priority 3 — Create Missing Files
- [ ] Create `evals/evals.json` with ≥ 3 design system query test cases
- [ ] Create `README.md` with design decisions, CSV data sources, limitations
- [ ] Verify and complete `_meta.json` with all required fields

---

## Error Handling Table (to add to SKILL.md)

| Error | Cause | Fix |
|-------|-------|-----|
| `python3: command not found` | Python not installed | Install via brew/apt/winget |
| `No such file: search.py` | scripts/ dir missing | Copy from ui-ux-pro-max or reinstall skill |
| `No results found` | Query too specific | Broaden keywords |
| Design system output empty | Missing CSV data files | Check data/ directory in skill |

---

## evals/evals.json Template

```json
{
  "skill_name": "ui-ux-pro-max-2",
  "pattern": "Tool Wrapper",
  "evals": [
    {
      "id": 1,
      "prompt": "Design a landing page for a fintech SaaS startup",
      "input": "fintech saas dashboard startup",
      "expected": "Design system with dark/professional style, Inter/Roboto fonts, blue accent palette"
    },
    {
      "id": 2,
      "prompt": "What UI style fits a luxury spa wellness brand?",
      "input": "beauty spa wellness elegant",
      "expected": "Minimalism or glassmorphism, serif heading font, soft warm palette"
    },
    {
      "id": 3,
      "prompt": "Review this button component for UX issues",
      "input": "button without cursor-pointer, no loading state",
      "expected": "Flag missing cursor-pointer, suggest disabled state during async"
    }
  ]
}
```

---

## Summary

| Item | Count |
|------|-------|
| Missing files | 3 (README.md, evals/evals.json, scripts/) |
| SKILL.md gaps | 4 sections missing or malformed |
| Critical issues | 1 (scripts/ directory missing — skill may not function) |
| Estimated effort | ~60 min (includes investigating script path issue) |
