# UPGRADE_PLAN: reflection

> Generated: 2026-03-25 | SOP Version: 1.0

## Pattern Classification

**Pattern: Pipeline**
Rationale: Strict step-by-step process with defined stages (Capture → Organize → Apply), stage gates (correction detected → log → check promotion → apply), and explicit trigger conditions. The three-layer memory promotion/demotion system is a multi-stage pipeline, not a simple tool call.

## Current State

| File | Status |
|------|--------|
| SKILL.md | ✅ Exists (excellent, comprehensive) |
| README.md | ❌ Missing |
| _meta.json | ⚠️ Exists but incomplete (missing pattern, emoji, tags, version format) |
| evals/evals.json | ✅ Exists (3 test cases — meets minimum) |
| scripts/ | ✅ All scripts present (check, log, read, promote, demote, stats, apply) |
| references/ | ✅ All 3 reference files present (boundaries, operations, triggers) |

**Missing files: 1** (README.md)

## SKILL.md Issues

| Check | Status | Notes |
|-------|--------|-------|
| `name` + `description` in frontmatter | ✅ | Detailed and clear |
| Description is pushy with trigger keywords | ✅ | USE FOR section in frontmatter |
| `USE FOR:` section | ✅ | In frontmatter (could add to body too) |
| `REPLACES:` | ✅ | Documented in frontmatter |
| `REQUIRES:` | ✅ | `jq, date` in frontmatter and metadata |
| Pattern label | ❌ | Missing — add "**Pattern: Pipeline**" to body |
| `When to Use` section | ✅ | 5 trigger conditions, well-explained |
| `Prerequisites` section | ✅ | Documented |
| `Quick Start` | ✅ | Present with command examples |
| `Pipeline` section | ✅ | 3-stage pipeline clearly defined |
| At least 1 complete `Example` | ✅ | 3 complete examples |
| `Error Handling` table | ✅ | 6 error cases with causes and fixes |
| < 500 lines | ✅ | Within limit |

## _meta.json Issues

Current `_meta.json` is missing SOP-required fields:
- ❌ `pattern` field
- ❌ `emoji` field  
- ❌ `tags` field
- ❌ `author` field
- ❌ `created` field
- ⚠️ `scripts` section uses non-standard format

## Action Plan

### Priority 1 — Fix SKILL.md (minimal)

1. Add `**Pattern: Pipeline**` near top of body (one-line fix)

### Priority 2 — Fix _meta.json

Replace with SOP-compliant version:
```json
{
  "name": "reflection",
  "version": "1.0.0",
  "author": "hopyky",
  "pattern": "Pipeline",
  "emoji": "🪞",
  "created": "2026-03-25",
  "description": "Unified self-reflection and self-improvement with three-layer memory",
  "license": "MIT",
  "homepage": "https://github.com/openclaw/skills/tree/main/skills/hopyky/reflection",
  "replaces": ["self-improving", "self-reflection"],
  "companion": ["soul-keeper"],
  "requires": {
    "bins": ["jq", "date"],
    "modules": []
  },
  "tags": ["memory", "reflection", "self-improvement", "learning", "meta"],
  "scripts": {
    "check": "scripts/reflection check",
    "log": "scripts/reflection log",
    "read": "scripts/reflection read",
    "stats": "scripts/reflection stats",
    "promote": "scripts/reflection promote",
    "demote": "scripts/reflection demote"
  }
}
```

### Priority 3 — Write README.md

#### `README.md` (the only missing required file)
- **How it works**: three-layer memory architecture, promotion/demotion mechanics
- **Design decisions**:
  - Why markdown files over a database: human-readable, version-controllable, no deps
  - Why three layers: different volatility — golden rules are permanent, daily logs are ephemeral
  - Why `jq`: structured state file without a database
- **Supported inputs/outputs**: correction triggers, heartbeat check, manual commands
- **Layer size limits and enforcement** (link to references/operations.md)
- **Limitations**:
  - Lessons are workspace-scoped — won't transfer between workspaces automatically
  - Requires `jq` — not available on all systems by default
  - No encryption — don't store sensitive data in lessons
- **Companion skill**: soul-keeper — when to use both vs. just reflection
- **Related skills**: soul-keeper, heartbeat

### Priority 4 — Enhance evals.json

Current evals meet minimum (3 cases) but could be stronger:
- Add a **negative test**: agent does NOT log when no correction detected
- Add a **stats test**: verify output format of `reflection stats`
- Upgrade to include `pattern` field (currently missing from evals.json)

## Estimated Effort

| Task | Effort |
|------|--------|
| Add pattern label to SKILL.md | ~2 min |
| Fix _meta.json | ~5 min |
| Write README.md | ~25 min |
| Enhance evals.json (optional) | ~15 min |
| Total | ~47 min |

## Notes

This is the most complete skill of the 6 reviewed. Only 1 required file missing (README.md) and minor _meta.json gaps. The SKILL.md quality is high — detailed examples, comprehensive error handling, and clear pipeline documentation. Upgrade effort is minimal.
