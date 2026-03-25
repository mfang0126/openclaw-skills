# UPGRADE_PLAN — skill-creator

**Pattern**: Pipeline
**Reason**: Multi-step iterative process (intent → draft → test → evaluate → improve → repeat) with strict ordering and feedback loops.

---

## Gap Analysis (vs SOP Checklist)

| SOP Requirement | Status | Notes |
|-----------------|--------|-------|
| SKILL.md exists & < 500 lines | ⚠️ Exists but **far exceeds 500 lines** | ~700+ lines; needs hierarchy/splitting |
| Description is pushy with trigger keywords | ✅ OK | Covers broad creation/eval/optimize cases |
| Pattern labeled in SKILL.md | ❌ Missing | No `**Pattern: Pipeline**` label at top |
| scripts/ with working executables | ✅ OK | Rich scripts/ directory with Python modules |
| evals/evals.json ≥ 3 test cases | ❌ Missing | No `evals/` directory exists |
| _meta.json | ❌ Missing | Not present |
| README.md | ❌ Missing | Not present |
| All scripts tested & passing | ⚠️ Untested | No eval history to confirm |
| No GUI dependency | ✅ OK | Headless-friendly (uses `--static` flag) |

**Missing files: 3** (evals/evals.json, _meta.json, README.md)
**Additional issues: 2** (SKILL.md over 500 lines, Pattern label missing)

---

## Upgrade Actions

### P0 — Quick Fixes

1. **Add Pattern label** to top of SKILL.md body (after frontmatter):
   ```markdown
   **Pattern: Pipeline**
   ```

2. **Create `_meta.json`**:
   ```json
   {
     "name": "skill-creator",
     "version": "1.0.0",
     "author": "Anthropic / Ming",
     "pattern": "Pipeline",
     "emoji": "🛠️",
     "created": "2026-03-25",
     "requires": { "bins": ["python3", "claude"], "modules": [] },
     "tags": ["skills", "evals", "benchmarks", "iteration", "description-optimization"]
   }
   ```

### P1 — Critical Missing Files

3. **Create `evals/evals.json`** with ≥ 3 test cases:
   - Eval 1: "I want to create a skill that converts JSON to CSV"
   - Eval 2: "My skill isn't triggering — help me improve the description"
   - Eval 3: "Run evals on my existing draft-email skill and show me the results"

4. **Create `README.md`** covering:
   - Architecture overview (Pipeline loop, subagent structure, eval viewer)
   - How scripts/ relate to each phase
   - Design decision: why viewer before self-evaluation
   - Supported environments (Claude Code vs Claude.ai vs Cowork)
   - Limitations (subagents required for parallel baseline runs)

### P2 — SKILL.md Refactor

5. **Split SKILL.md** (currently ~700+ lines) by extracting verbose sections into `references/`:
   - Move "Running and evaluating test cases" detail → `references/eval-loop.md`
   - Move "Description Optimization" detail → `references/description-optimization.md`
   - Keep SKILL.md as overview + pointers → target < 500 lines

---

## Summary

| Category | Count |
|----------|-------|
| Missing required files | 3 |
| SKILL.md issues | 2 |
| Total actions | 5 |
