# UPGRADE_PLAN — soul-keeper

**Pattern**: Reviewer
**Reason**: Checks existing workspace files against a standard (WORKSPACE_FILES_GUIDE.md), identifies what's stale or missing, and proposes updates. It reviews input (workspace state) against a rubric — classic Reviewer pattern.

---

## Gap Analysis (vs SOP Checklist)

| SOP Requirement | Status | Notes |
|-----------------|--------|-------|
| SKILL.md exists & < 500 lines | ✅ OK | ~180 lines, well within limit |
| Description is pushy with trigger keywords | ✅ OK | Has explicit trigger/no-trigger conditions |
| Pattern labeled in SKILL.md | ❌ Missing | No `**Pattern: Reviewer**` label in body |
| scripts/ with working executables | ❌ Missing | No scripts/ directory |
| evals/evals.json ≥ 3 test cases | ❌ Missing | No evals/ directory |
| _meta.json | ❌ Missing | Not present |
| README.md | ❌ Missing | Not present |
| All scripts tested & passing | N/A | No scripts; operates via LLM reasoning |
| No GUI dependency | ✅ OK | File-based, fully headless |

**Missing files: 4** (_meta.json, README.md, scripts/, evals/evals.json)
**Additional issues: 1** (Pattern label missing)

---

## Upgrade Actions

### P0 — Quick Fixes

1. **Add Pattern label** to top of SKILL.md body (after the first heading):
   ```markdown
   **Pattern: Reviewer**
   ```

2. **Create `_meta.json`**:
   ```json
   {
     "name": "soul-keeper",
     "version": "1.0.0",
     "author": "Ming",
     "pattern": "Reviewer",
     "emoji": "🔍",
     "created": "2026-03-25",
     "requires": { "bins": [], "modules": [] },
     "tags": ["workspace", "soul", "memory", "optimization", "review"]
   }
   ```

### P1 — Critical Missing Files

3. **Create `scripts/check_workspace.sh`** — a lightweight script that lists workspace files and their last-modified times to help the agent audit staleness:
   ```bash
   #!/bin/bash
   # Usage: ./scripts/check_workspace.sh [workspace_path]
   # Outputs: file name, size, last modified, line count
   ```
   Make executable: `chmod +x scripts/check_workspace.sh`

4. **Create `evals/evals.json`** with ≥ 3 test cases:
   - Eval 1: User says "I've corrected the same thing 3 times now" → should suggest SOUL.md update
   - Eval 2: New project started, MEMORY.md not updated → should flag MEMORY.md + WORKING.md
   - Eval 3: User says "done for today, bye" → should trigger session-end hook, batch-suggest updates

5. **Create `README.md`** covering:
   - How it works (trigger detection → file read → diff analysis → suggestion)
   - The 8 workspace files and their update rhythms
   - Design decision: suggest-don't-auto-edit philosophy
   - N-Turn heartbeat and session end hook behavior
   - Pending updates management via pending-updates.md
   - Limitations: operates on signals in conversation, not file watchers

---

## Summary

| Category | Count |
|----------|-------|
| Missing required files | 4 |
| SKILL.md issues | 1 |
| Total actions | 5 |
