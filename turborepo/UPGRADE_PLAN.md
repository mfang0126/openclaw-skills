# UPGRADE_PLAN — turborepo

**Pattern**: Tool Wrapper (Reference)
**Reason**: Loads Turborepo configuration knowledge on demand via decision trees and reference files. Agent consults it when configuring monorepo tasks, debugging cache, setting up CI. The skill itself doesn't run a pipeline — it routes to the right reference file for the specific problem.

---

## Gap Analysis (vs SOP Checklist)

| SOP Requirement | Status | Notes |
|-----------------|--------|-------|
| SKILL.md exists & < 500 lines | ⚠️ Borderline | ~450 lines — within limit but dense; decision trees + anti-patterns + examples all in one file |
| Description is pushy with trigger keywords | ✅ OK | Explicit trigger list: turbo.json, task pipelines, `--filter`, `--affected`, CI optimization, etc. |
| Pattern labeled in SKILL.md | ❌ Missing | No `**Pattern: Tool Wrapper**` label |
| scripts/ with working executables | ❌ Missing | No scripts/ directory (only `command/` and `references/`) |
| evals/evals.json ≥ 3 test cases | ❌ Missing | No evals/ directory |
| _meta.json | ❌ Missing | Not present |
| README.md | ❌ Missing | Not present |
| All scripts tested & passing | N/A | Reference-only skill |
| No GUI dependency | ✅ OK | CLI-based, fully headless |
| `command/turborepo.md` purpose unclear | ⚠️ Non-standard | Doesn't follow SOP directory naming — should be under `references/` or `scripts/` |

**Missing files: 4** (_meta.json, README.md, scripts/, evals/evals.json)  
**Additional issues: 2** (Pattern label missing, non-standard `command/` directory)

---

## Upgrade Actions

### P0 — Quick Fixes

1. **Add Pattern label** to top of SKILL.md body (after first heading):
   ```markdown
   **Pattern: Tool Wrapper**
   ```

2. **Create `_meta.json`**:
   ```json
   {
     "name": "turborepo",
     "version": "2.8.12-canary.2",
     "author": "Ming",
     "pattern": "Tool Wrapper",
     "emoji": "⚡",
     "created": "2026-03-25",
     "requires": { "bins": ["turbo", "node"], "modules": [] },
     "tags": ["turborepo", "monorepo", "build-system", "caching", "ci", "pipelines", "typescript"]
   }
   ```

### P1 — Directory Cleanup

3. **Clarify `command/turborepo.md`** — this non-standard directory is confusing. Two options:
   - Option A: Move to `references/cli/turborepo-command.md` and update any pointers
   - Option B: Keep but add a note at top of SKILL.md explaining its purpose
   Recommend Option A for SOP consistency.

### P2 — Critical Missing Files

4. **Create `scripts/validate_turbo_config.sh`** — checks that turbo.json exists and has required `tasks` key:
   ```bash
   #!/bin/bash
   # Usage: ./scripts/validate_turbo_config.sh [repo_root]
   # Checks: turbo.json exists, has "$schema", no root task overuse
   ```
   Make executable: `chmod +x scripts/validate_turbo_config.sh`

5. **Create `evals/evals.json`** with ≥ 3 test cases:
   - Eval 1: "My build cache keeps missing even though I haven't changed anything"
   - Eval 2: "How do I only build the packages that changed in my PR?"
   - Eval 3: "I have 3 apps sharing a UI package — how do I set up the pipeline so UI builds first?"

6. **Create `README.md`** covering:
   - How the skill is organized (SKILL.md decision trees → references/ deep dives)
   - Source: official Turborepo docs, version pinned to 2.8.12-canary.2
   - Design decision: decision trees over prose for faster navigation
   - What `command/turborepo.md` is for
   - Limitations: version-specific — check `metadata.version` before applying patterns
   - Related skills: none currently, but could pair with a CI skill

---

## Summary

| Category | Count |
|----------|-------|
| Missing required files | 4 |
| SKILL.md issues | 2 |
| Total actions | 6 |
