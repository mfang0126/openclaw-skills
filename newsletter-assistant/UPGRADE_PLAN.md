# Upgrade Plan: newsletter-assistant

> Generated: 2026-03-25 | SOP Version: 1.0

## Pattern Classification

**Pattern: Pipeline**
> "Strict step-by-step process" — classify → extract → archive → delete, with multi-layer AI fallback and active learning across the full pipeline.

## Current State

| File | Status |
|------|--------|
| SKILL.md | ✅ Exists (fairly complete, missing some sections) |
| README.md | ❌ Missing |
| _meta.json | ❌ Missing (metadata embedded in frontmatter instead) |
| evals/evals.json | ❌ Missing |
| scripts/ | ❌ Missing (has src/ but not scripts/) |

**Missing files: 4** (README.md, _meta.json, evals/evals.json, scripts/)

## SKILL.md Issues

SKILL.md is the most complete of the 6 skills but still has gaps:

| Check | Status |
|-------|--------|
| `name` + `description` frontmatter | ✅ |
| Description is pushy with trigger keywords | ⚠️ Description mentions features, not trigger phrases |
| `USE FOR:` section | ❌ Missing |
| `REPLACES:` | ❌ Missing |
| `REQUIRES:` | ✅ In frontmatter metadata (bins, env) |
| Pattern label (`**Pattern: Pipeline**`) | ❌ Missing |
| `When to Use` section | ❌ Missing |
| `Prerequisites` section | ⚠️ Has "Requirements" (install steps) but not SOP Prerequisites format |
| `Quick Start` | ✅ Exists |
| `Instructions` / Pipeline | ✅ Detailed (How It Works section) |
| At least 1 complete `Example` | ✅ 2 code examples |
| `Error Handling` table | ⚠️ Has Troubleshooting section (not standard table format) |
| < 500 lines | ✅ |

## Action Items

### Priority 1 — Fix SKILL.md

**Update description in frontmatter** to include trigger keywords:
```yaml
description: AI-powered newsletter classification, extraction, and archiving pipeline. Use when user says "process newsletters", "classify emails", "archive newsletters", "clean my inbox", "newsletter pipeline", or "delete newsletters from Gmail".
```

**Add pattern label** after the h1:
```markdown
**Pattern: Pipeline**
```

**Add USE FOR: section:**
```markdown
## USE FOR
- "process my newsletters"
- "classify and archive emails"
- "clean up my Gmail newsletters"
- "run newsletter pipeline"
- "archive newsletters from inbox"
- "delete newsletters after archiving"
```

**Add When to Use section:**
```markdown
## When to Use
Use when user has newsletters piling up in Gmail and wants to:
1. Classify what's a newsletter vs regular email
2. Extract clean content for local archiving
3. Remove processed newsletters from Gmail

Trigger keywords: newsletter, classify emails, archive inbox, clean Gmail.
```

**Add Prerequisites section** (SOP format, separate from Installation):
```markdown
## Prerequisites
- Python 3.11+ installed
- Himalaya CLI configured with Gmail account
- `GLM_API_KEY` set in environment or openclaw.json
- `pip install -r requirements.txt` completed
```

**Convert Troubleshooting to Error Handling table:**
```markdown
## Error Handling

| Error | Cause | Fix |
|-------|-------|-----|
| Low accuracy after training | Insufficient training data | Run more training batches (50-100 emails) |
| High AI costs | Memory DB not populated | Check DB coverage, verify pattern rules |
| Himalaya auth failure | Gmail credentials expired | Re-run `himalaya account add` |
| `GLM_API_KEY` not found | Missing env var | Set in `~/.openclaw/openclaw.json` |
| `readability-lxml` import error | Missing Python dep | `pip install -r requirements.txt` |
```

### Priority 2 — Create scripts/

The skill has `src/` Python modules but no `scripts/` wrapper per SOP. Create thin shell wrappers:

```bash
mkdir -p ~/.openclaw/skills/newsletter-assistant/scripts
```

Create `scripts/process.sh`:
```bash
#!/bin/bash
# Full pipeline: classify → extract → archive → delete
# Usage: ./scripts/process.sh [--dry-run]
cd "$(dirname "$0")/.."
python3 src/newsletter_processor.py process --input data/gmail-all --delete "$@"
```

Create `scripts/classify.sh`:
```bash
#!/bin/bash
# Classify only (no deletion)
cd "$(dirname "$0")/.."
python3 src/newsletter_processor.py classify --input data/gmail-all --output data/results.json
```

```bash
chmod +x ~/.openclaw/skills/newsletter-assistant/scripts/*.sh
```

### Priority 3 — Create _meta.json

(Move metadata out of SKILL.md frontmatter into standalone file per SOP):

```json
{
  "name": "newsletter-assistant",
  "version": "1.0.0",
  "author": "King",
  "pattern": "Pipeline",
  "emoji": "📧",
  "created": "2026-03-25",
  "requires": {
    "bins": ["himalaya", "python3"],
    "modules": ["readability-lxml", "requests"],
    "env": ["GLM_API_KEY"]
  },
  "tags": ["newsletter", "email", "gmail", "classification", "archive", "active-learning"]
}
```

### Priority 4 — Create evals/evals.json

```bash
mkdir -p ~/.openclaw/skills/newsletter-assistant/evals
```

```json
{
  "skill_name": "newsletter-assistant",
  "pattern": "Pipeline",
  "evals": [
    {
      "id": 1,
      "prompt": "Classify this email as newsletter or not",
      "input": {"from": "digest@substack.com", "subject": "Weekly Digest #42", "body_preview": "This week's top stories..."},
      "expected": {"is_newsletter": true, "confidence": 0.95, "method": "domain_whitelist"}
    },
    {
      "id": 2,
      "prompt": "Classify this email",
      "input": {"from": "boss@company.com", "subject": "Re: Meeting tomorrow", "body_preview": "Can we move it to 3pm?"},
      "expected": {"is_newsletter": false, "confidence": 0.99, "method": "pattern_match"}
    },
    {
      "id": 3,
      "prompt": "Run the full newsletter pipeline on my inbox",
      "input": "50 emails in data/gmail-all",
      "expected": "Classification report + archived newsletters + deletion confirmation"
    }
  ]
}
```

### Priority 5 — Create README.md

Cover:
- Three-layer classification architecture (Memory → Pattern → AI)
- Active Learning design decision (why train once, run forever)
- Cost analysis (training $0.50, production $0)
- Why Himalaya (headless Gmail access)
- Limitations (Gmail only, requires initial training batch)
- Future: Outlook support, Web UI
- Related skills: none currently

## Final Checklist

- [ ] SKILL.md updated: description trigger keywords, pattern label, USE FOR, When to Use, Prerequisites (SOP format), Error Handling table
- [ ] Pattern labeled as **Pipeline**
- [ ] scripts/ created with process.sh and classify.sh, both executable
- [ ] evals/evals.json has ≥ 3 test cases
- [ ] _meta.json created (standalone file)
- [ ] README.md created
- [ ] Scripts tested headless
- [ ] `openclaw config validate` passes
