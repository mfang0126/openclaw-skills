# UPGRADE_PLAN: plan-mode

> Generated: 2026-03-25 | SOP Version: 1.0

## Pattern Classification

**Pattern: Pipeline**
Rationale: Enforces a strict step-by-step process (Capture Intent → Inventory → Plan → Confirm → Execute/Cancel) with defined stages, gates between stages, and explicit exit conditions. The structured output format and flowchart-driven logic make this a Pipeline.

## Current State

| File | Status |
|------|--------|
| SKILL.md | ✅ Exists (well-written, minor gaps) |
| README.md | ❌ Missing |
| _meta.json | ❌ Missing |
| evals/evals.json | ❌ Missing |
| scripts/ | ❌ Missing |

**Missing files: 4** (README.md, _meta.json, evals/evals.json, scripts/)

## SKILL.md Issues

| Check | Status | Notes |
|-------|--------|-------|
| `name` + `description` in frontmatter | ✅ | Present and pushy |
| Description is pushy with trigger keywords | ✅ | Excellent — 9 trigger phrases listed |
| `USE FOR:` section | ❌ | Missing — not in body (triggers in frontmatter only) |
| `REPLACES:` | ➖ | N/A |
| `REQUIRES:` | ➖ | Pure cognitive skill, no bins needed |
| Pattern label | ❌ | Missing — add "**Pattern: Pipeline**" |
| `When to Use` section | ✅ | Trigger tables are detailed and complete |
| `Prerequisites` section | ❌ | Missing (though requirements are minimal) |
| `Quick Start` | ❌ | Missing — no "most common usage" entry point |
| `Instructions` / `Pipeline` section | ✅ | Flowchart and stage breakdown present |
| At least 1 complete `Example` | ✅ | Example 1 (blog comment system) is complete |
| `Error Handling` table | ⚠️ | Edge cases covered but not in table format |
| < 500 lines | ✅ | Well-formatted, ~160 lines |

## Action Plan

### Priority 1 — Fix SKILL.md (light touch)

1. Add `**Pattern: Pipeline**` label near top of body
2. Add `USE FOR:` section duplicating/expanding the trigger phrases from frontmatter into the body
3. Add `Prerequisites` section: "None — pure reasoning skill, no external dependencies"
4. Add `Quick Start` block:
   ```
   Say: "/plan <your task>"
   → Agent enters plan mode, outputs structured plan, waits for "动手" to execute
   ```
5. Convert edge-case list (境界情况处理) into a proper `Error Handling` table with Cause / Fix columns

### Priority 2 — Create Missing Files

#### `_meta.json`
```json
{
  "name": "plan-mode",
  "version": "1.0.0",
  "author": "King",
  "pattern": "Pipeline",
  "emoji": "🗺️",
  "created": "2026-03-25",
  "requires": { "bins": [], "modules": [] },
  "tags": ["planning", "safety", "workflow", "meta"]
}
```

#### `evals/evals.json`
Minimum 3 test cases:
1. `/plan 给博客加评论系统` → expects structured 5-section output (🎯 📦 🧠 ❓ 🚫), no tool calls
2. `帮我删掉这个文件` (explicit action) → expects NO plan mode trigger, direct execution
3. `我想重构整个后端` (ambiguous large task) → expects agent to ask "要先 plan 吗？"

#### `scripts/`
Pure cognitive skill — no runtime scripts needed.
Consider `scripts/save-plan.sh` for the "搁置" (shelve) path that saves to `~/plan-drafts/`.

#### `README.md`
- How it works: interceptor pattern — detects intent before execution
- Design decisions: why zero tool calls in plan mode (safety, reversibility)
- The 3-exit-path model: execute / cancel / shelve
- Limitations: relies on trigger phrase detection; may miss implicit planning needs
- Related skills: none (meta-skill that wraps all others)

## Estimated Effort

| Task | Effort |
|------|--------|
| Fix SKILL.md | ~20 min |
| Write README.md | ~20 min |
| Write _meta.json | ~5 min |
| Write evals.json | ~15 min |
| Write scripts/save-plan.sh | ~15 min |
| Total | ~75 min |
