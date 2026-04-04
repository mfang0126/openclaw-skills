# Upgrade Plan: memory-audit

> Generated: 2026-03-25 | SOP Version: 1.0

## Pattern Classification

**Pattern: Reviewer**
> "Check/review existing input" — audits and reports on the state of an agent's memory files.

## Current State

| File | Status |
|------|--------|
| SKILL.md | ❌ Missing |
| README.md | ✅ Exists |
| _meta.json | ❌ Missing |
| evals/evals.json | ❌ Missing |
| scripts/ | ❌ Missing (run.sh exists at root, not in scripts/) |
| memory-audit.py | ✅ Exists (root level) |
| requirements.txt | ✅ Exists |

**Missing files: 4** (SKILL.md, _meta.json, evals/evals.json, scripts/)

## SKILL.md Issues

SKILL.md does not exist at all. Must be created from scratch with all required sections.

## Action Items

### Priority 1 — Create SKILL.md
```markdown
---
name: memory-audit
description: Audit and review agent memory files for quality, staleness, and gaps. Use when user says "audit memory", "check memory", "review memory files", "what's in memory", or "clean up memory".
---
```

Required sections to include:
- [ ] Frontmatter: `name` + `description` with trigger keywords
- [ ] `USE FOR:` section with example phrases
- [ ] `REQUIRES:` Python 3, memory files
- [ ] `**Pattern: Reviewer**` label
- [ ] `When to Use` section
- [ ] `Prerequisites` section
- [ ] `Quick Start` (most common usage)
- [ ] `Instructions` — how to run the audit and interpret output
- [ ] At least 1 complete `Example` with sample output
- [ ] `Error Handling` table
- [ ] Keep < 500 lines

### Priority 2 — Create scripts/ directory + move run.sh
```bash
mkdir -p ~/.openclaw/skills/memory-audit/scripts
cp ~/.openclaw/skills/memory-audit/run.sh ~/.openclaw/skills/memory-audit/scripts/run.sh
chmod +x ~/.openclaw/skills/memory-audit/scripts/run.sh
```
Verify the script works headless (no GUI dependency).

### Priority 3 — Create _meta.json
```json
{
  "name": "memory-audit",
  "version": "1.0.0",
  "author": "King",
  "pattern": "Reviewer",
  "emoji": "🧠",
  "created": "2026-03-25",
  "requires": {
    "bins": ["python3"],
    "modules": ["requirements.txt"]
  },
  "tags": ["memory", "audit", "review", "maintenance"]
}
```

### Priority 4 — Create evals/evals.json
```bash
mkdir -p ~/.openclaw/skills/memory-audit/evals
```

Minimum 3 test cases covering:
1. Agent with healthy, up-to-date memory → expected: "Memory looks good"
2. Agent with stale/old entries → expected: staleness warning
3. Agent with missing memory sections → expected: gap report

```json
{
  "skill_name": "memory-audit",
  "pattern": "Reviewer",
  "evals": [
    {
      "id": 1,
      "prompt": "Audit my memory files",
      "input": "~/.openclaw/workspace-main/memory/",
      "expected": "Audit report with counts, staleness flags, and recommendations"
    },
    {
      "id": 2,
      "prompt": "Check if my memory is outdated",
      "input": "Memory files last modified 30+ days ago",
      "expected": "Staleness warning with specific old entries listed"
    },
    {
      "id": 3,
      "prompt": "Review memory for gaps",
      "input": "Memory with missing required sections",
      "expected": "Gap report listing missing sections"
    }
  ]
}
```

### Priority 5 — Update README.md
Current README.md exists but verify it includes:
- [ ] How it works (detailed)
- [ ] Design decisions
- [ ] Supported inputs/outputs
- [ ] Limitations
- [ ] Related skills

## Final Checklist

- [ ] SKILL.md created with all required sections
- [ ] Pattern labeled as **Reviewer**
- [ ] scripts/ has working run.sh (moved from root)
- [ ] evals/evals.json has ≥ 3 test cases
- [ ] _meta.json created
- [ ] README.md reviewed and updated
- [ ] Scripts tested headless
- [ ] `openclaw config validate` passes
