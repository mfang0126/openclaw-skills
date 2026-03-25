# UPGRADE_PLAN — sub-agent-patterns

**Pattern**: Tool Wrapper (Reference)
**Reason**: Loads authoritative knowledge about sub-agent configuration and delegation patterns on demand. The skill itself doesn't execute a pipeline — it surfaces structured reference knowledge so the agent can correctly configure and invoke sub-agents.

---

## Gap Analysis (vs SOP Checklist)

| SOP Requirement | Status | Notes |
|-----------------|--------|-------|
| SKILL.md exists & < 500 lines | ⚠️ Exists but **exceeds 500 lines** | ~650+ lines; the skill references an external rules/ file which adds to load |
| Description is pushy with trigger keywords | ✅ OK | Good coverage: creating agents, delegating, parallel research, configuration |
| Pattern labeled in SKILL.md | ❌ Missing | No `**Pattern: Tool Wrapper**` label |
| scripts/ with working executables | ❌ Missing | No scripts/ directory |
| evals/evals.json ≥ 3 test cases | ❌ Missing | No evals/ directory |
| _meta.json | ❌ Missing | Not present |
| README.md | ❌ Missing | Not present |
| All scripts tested & passing | N/A | Reference-only skill |
| No GUI dependency | ✅ OK | Documentation skill, headless |

**Missing files: 4** (_meta.json, README.md, scripts/, evals/evals.json)
**Additional issues: 2** (Pattern label missing, SKILL.md over 500 lines)

---

## Upgrade Actions

### P0 — Quick Fixes

1. **Add Pattern label** to top of SKILL.md body:
   ```markdown
   **Pattern: Tool Wrapper**
   ```

2. **Create `_meta.json`**:
   ```json
   {
     "name": "sub-agent-patterns",
     "version": "1.0.0",
     "author": "Ming",
     "pattern": "Tool Wrapper",
     "emoji": "🤖",
     "created": "2026-03-25",
     "requires": { "bins": [], "modules": [] },
     "tags": ["sub-agents", "delegation", "orchestration", "claude-code", "context-hygiene"]
   }
   ```

### P1 — SKILL.md Size Reduction

3. **Split SKILL.md** (currently ~650+ lines) — move verbose sections to `references/`:
   - Extract "Example Custom Sub-Agents" section → `references/example-agents.md`
   - Extract "Prompt Templates" section → `references/prompt-templates.md`
   - Keep SKILL.md as overview + decision trees + anti-patterns → target < 500 lines
   - Update `rules/sub-agent-patterns.md` pointer if needed

### P2 — Critical Missing Files

4. **Create `scripts/validate_agent.sh`** — checks that a `.claude/agents/*.md` file has required frontmatter fields (name, description):
   ```bash
   #!/bin/bash
   # Usage: ./scripts/validate_agent.sh <agent-file.md>
   ```
   Make executable: `chmod +x scripts/validate_agent.sh`

5. **Create `evals/evals.json`** with ≥ 3 test cases:
   - Eval 1: "Create a custom sub-agent that reviews my code after each edit"
   - Eval 2: "I'm getting tons of approval prompts from my agent — how do I fix it?"
   - Eval 3: "How do I run 20 audits in parallel using sub-agents?"

6. **Create `README.md`** covering:
   - What this skill does (reference guide for sub-agent config/delegation)
   - Relationship between SKILL.md and rules/sub-agent-patterns.md
   - When to use orchestration vs direct delegation
   - Design decision: why Bash approval spam matters and the tool-access principle
   - Limitations: session restart required for new agents; no nesting beyond depth 2

---

## Summary

| Category | Count |
|----------|-------|
| Missing required files | 4 |
| SKILL.md issues | 2 |
| Total actions | 6 |
