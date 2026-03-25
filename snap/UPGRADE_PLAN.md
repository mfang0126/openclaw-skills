# UPGRADE_PLAN — snap

**Pattern**: Tool Wrapper
**Reason**: Wraps an external service (snap.llm.kaveenk.com screenshot API) and loads its usage knowledge on demand. No pipeline steps, no generation logic — pure API delegation.

---

## Gap Analysis (vs SOP Checklist)

| SOP Requirement | Status | Notes |
|-----------------|--------|-------|
| SKILL.md exists & < 500 lines | ✅ OK | ~80 lines, well within limit |
| Description is pushy with trigger keywords | ❌ Weak | Describes the service but doesn't list trigger keywords like "screenshot", "capture website", "take a screenshot of" |
| Pattern labeled in SKILL.md | ❌ Missing | No `**Pattern: Tool Wrapper**` label |
| scripts/ with working executables | ❌ Missing | No scripts/ directory |
| evals/evals.json ≥ 3 test cases | ❌ Missing | No evals/ directory |
| _meta.json | ✅ Exists | Present |
| README.md | ❌ Missing | Not present |
| All scripts tested & passing | N/A | No scripts to test |
| No GUI dependency | ✅ OK | API-based, fully headless |

**Missing files: 3** (scripts/, evals/evals.json, README.md)
**Additional issues: 2** (weak description, no Pattern label)

---

## Upgrade Actions

### P0 — Quick Fixes

1. **Add Pattern label** to top of SKILL.md body:
   ```markdown
   **Pattern: Tool Wrapper**
   ```

2. **Improve description** in SKILL.md frontmatter — make it pushy with trigger keywords:
   ```
   Give your agent the ability to instantly take screenshots of any website with just the URL.
   Use when user says: "screenshot", "capture this website", "take a photo of", "what does X look like",
   "show me the page", "snap a screenshot", "get a screenshot of", or any URL + visual request.
   Cloud-based, free, open source.
   ```

### P1 — Critical Missing Files

3. **Create `scripts/snap.sh`** — a helper shell script to take a screenshot given a URL and API key:
   ```bash
   #!/bin/bash
   # Usage: ./scripts/snap.sh <url> <api_key> [output_file]
   ```
   Make executable: `chmod +x scripts/snap.sh`

4. **Create `evals/evals.json`** with ≥ 3 test cases:
   - Eval 1: "Take a screenshot of https://github.com"
   - Eval 2: "Show me what anthropic.com looks like right now"
   - Eval 3: "Capture a full-page screenshot of https://example.com in dark mode"

5. **Create `README.md`** covering:
   - How it works (registers API key once, then uses it per-screenshot)
   - Rate limits (2/min, 200/day)
   - Design decision: cloud API, no local browser dependency
   - Limitations: 1 API key per IP, no recovery of lost keys
   - Error handling guidance

---

## Summary

| Category | Count |
|----------|-------|
| Missing required files | 3 |
| SKILL.md issues | 2 |
| Total actions | 5 |
