# UPGRADE_PLAN: python-code-review

> Generated: 2026-03-25 | SOP Version: 1.0

## Pattern Classification

**Pattern: Reviewer**
Rationale: Checks and reviews existing input (Python code) against defined standards. Classic Reviewer pattern — input is provided, output is a structured findings report with issues, severities, and fixes.

## Current State

| File | Status |
|------|--------|
| SKILL.md | ✅ Exists (good quality, missing key SOP fields) |
| README.md | ❌ Missing |
| _meta.json | ❌ Missing |
| evals/evals.json | ❌ Missing |
| scripts/ | ❌ Missing |
| references/ | ✅ All 5 reference files present |

**Missing files: 4** (README.md, _meta.json, evals/evals.json, scripts/)

## SKILL.md Issues

| Check | Status | Notes |
|-------|--------|-------|
| `name` + `description` in frontmatter | ✅ | Present and clear |
| Description is pushy with trigger keywords | ✅ | Trigger phrases in description |
| `USE FOR:` section | ❌ | Missing — not in body |
| `REPLACES:` | ➖ | N/A |
| `REQUIRES:` | ❌ | Missing from frontmatter (needs: python3) |
| Pattern label | ❌ | Missing — add "**Pattern: Reviewer**" |
| `When to Use` section | ⚠️ | "When to Load References" table exists but no "When to Use" for the skill itself |
| `Prerequisites` section | ❌ | Missing |
| `Quick Start` | ❌ | Missing — no entry point |
| `Instructions` / review flow | ⚠️ | Checklist exists but no step-by-step review flow |
| At least 1 complete `Example` | ❌ | Missing — no before/after code example |
| `Error Handling` table | ❌ | Missing |
| < 500 lines | ✅ | Well within limit |

## Action Plan

### Priority 1 — Fix SKILL.md

1. Add `**Pattern: Reviewer**` near top of body
2. Add `REQUIRES:` to frontmatter: `python3 >=3.10` (for `T | None` syntax checks)
3. Add `USE FOR:` section with example triggers:
   - "review this Python file"
   - "check my async code"
   - "are my type hints correct?"
   - "review exception handling"
4. Add proper `When to Use` section (not just "when to load references"):
   - Any `.py` file submitted for review
   - Before merging Python PRs
   - After writing new async functions
5. Add `Prerequisites` section:
   - Python 3.10+ recommended (for modern type syntax)
   - Provide the code to review (paste or file path)
6. Add `Quick Start`:
   ```
   Paste your Python code and say:
   "review this" → full review across all categories
   "check types only" → type safety pass only
   "check async patterns" → async/await pass only
   ```
7. Add step-by-step review flow:
   ```
   1. Receive code
   2. Load relevant references (based on what's in the code)
   3. Run through checklist categories
   4. Output findings as: Severity | Location | Issue | Fix
   5. Summary: X issues found (Y critical, Z warnings)
   ```
8. Add at least 1 complete `Example`:
   - Bad code (missing type hints, bare except, mutable default)
   - Review output with findings table
   - Fixed code
9. Add `Error Handling` table:
   - "No code provided" → ask user to paste or specify file path
   - "File not found" → check path, ask to paste inline
   - "Python 2 syntax" → note: skill optimized for Python 3.10+

### Priority 2 — Create Missing Files

#### `_meta.json`
```json
{
  "name": "python-code-review",
  "version": "1.0.0",
  "author": "King",
  "pattern": "Reviewer",
  "emoji": "🐍",
  "created": "2026-03-25",
  "requires": { "bins": ["python3"], "modules": [] },
  "tags": ["python", "code-review", "type-safety", "async", "pep8"]
}
```

#### `evals/evals.json`
Minimum 3 test cases:
1. Function with bare `except:` + missing type hints → expects findings on both issues
2. Async function calling `time.sleep()` → expects async pattern violation flagged
3. Clean, correct Python code → expects "No issues found" (true negative test)

#### `scripts/`
This is a cognitive Reviewer skill — no runtime script strictly required.
Consider `scripts/run-review.sh` that runs `mypy` + `flake8` as a static analysis supplement:
```bash
#!/bin/bash
# Runs static analysis tools as a supplement to AI review
mypy "$1" --strict
flake8 "$1" --max-line-length=79
```

#### `README.md`
- How it works: load relevant references based on code content, run checklist
- Why reference files: modular — can update pep8 rules without touching SKILL.md
- Output format: severity-tagged findings table
- Limitations: AI review, not a linter — use mypy/flake8 for machine-precise checks
- Integration: pair with scripts/run-review.sh for combined AI + static analysis
- Related skills: `review-verification-protocol`

## Estimated Effort

| Task | Effort |
|------|--------|
| Fix SKILL.md | ~30 min |
| Write README.md | ~20 min |
| Write _meta.json | ~5 min |
| Write evals.json | ~20 min |
| Write scripts/run-review.sh | ~15 min |
| Total | ~90 min |
