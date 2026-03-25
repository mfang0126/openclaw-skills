# Upgrade Plan: multi-agent

> Generated: 2026-03-25 | SOP Version: 1.0

## Pattern Classification

**Pattern: Pipeline**
> "Strict step-by-step process" — orchestrates tasks across multiple agents in defined parallel or serial sequences, with routing logic and Discord reporting.

## Current State

| File | Status |
|------|--------|
| SKILL.md | ✅ Exists (no frontmatter, incomplete) |
| README.md | ❌ Missing |
| _meta.json | ❌ Missing |
| evals/evals.json | ❌ Missing |
| scripts/ | ❌ Missing |

**Missing files: 4** (README.md, _meta.json, evals/evals.json, scripts/)

## SKILL.md Issues

SKILL.md has solid content (agent roster, routing table, examples) but is missing structural/formal requirements:

| Check | Status |
|-------|--------|
| `name` + `description` frontmatter | ❌ Missing (no frontmatter at all) |
| Description is pushy with trigger keywords | ⚠️ Has trigger words section but no frontmatter |
| `USE FOR:` section | ❌ Missing (has 触发词 but not in USE FOR: format) |
| `REPLACES:` | ❌ Missing |
| `REQUIRES:` dependencies | ❌ Missing |
| Pattern label (`**Pattern: Pipeline**`) | ❌ Missing |
| `When to Use` section | ❌ Missing (has routing table instead) |
| `Prerequisites` section | ❌ Missing |
| `Quick Start` | ❌ Missing |
| `Instructions` / logic | ✅ Detailed (调用方式 section) |
| At least 1 complete `Example` | ✅ Full example at bottom |
| `Error Handling` table | ❌ Missing |
| < 500 lines | ✅ |

## Action Items

### Priority 1 — Fix SKILL.md

**Add frontmatter at top of file:**
```markdown
---
name: multi-agent
description: Orchestrate parallel and serial multi-agent task pipelines. Use when user says "multi-agent", "parallel processing", "assign to agent", "use multiple agents", "team collaboration", or asks researcher/content/tech-lead/verifier to do something.
---
```

**Add pattern label** after the h1:
```markdown
**Pattern: Pipeline**
```

**Add Quick Start section:**
```markdown
## Quick Start
```
// Parallel (independent tasks)
sessions_spawn(agentId="researcher", task="Research X")
sessions_spawn(agentId="content", task="Write outline for Y")

// Serial (dependent)
1. sessions_spawn(agentId="researcher", task="Research X")
2. Wait for result → sessions_spawn(agentId="content", task="Write based on: {result}")
```
```

**Add Prerequisites section:**
```markdown
## Prerequisites
- Agents configured in openclaw.json: researcher, content, tech-lead, product-owner, verifier
- Discord channels set up for each agent (see Agent Roster table)
- sessions_spawn tool available
```

**Add REQUIRES: section:**
```markdown
## REQUIRES
- OpenClaw multi-agent support (sessions_spawn)
- Discord bot configured for each agent
- Agent IDs: researcher, content, tech-lead, product-owner, verifier
```

**Add When to Use section:**
```markdown
## When to Use
Use when a task requires multiple specialized agents OR when parallelism would save significant time.
Do NOT use for simple tasks a single agent can handle — overhead not worth it.
Trigger: multi-agent, parallel, assign to agent, use researcher/content/tech-lead.
```

**Add Error Handling table:**
```markdown
## Error Handling

| Error | Cause | Fix |
|-------|-------|-----|
| Agent not responding | Sub-agent stalled or crashed | Check sessions_history, re-spawn or do inline |
| Discord message not sent | Bot token issue or wrong channel ID | Verify accountId and channel ID in agent roster |
| Result never arrives | Missing sessions_yield | Ensure sub-agent calls sessions_yield |
| Wrong agent used | Misrouted task | Consult task routing table before spawning |
```

### Priority 2 — Create scripts/

This is a meta/orchestration skill — no shell script is strictly needed. However, create a helper:

```bash
mkdir -p ~/.openclaw/skills/multi-agent/scripts
```

Create `scripts/check-agents.sh` — lists available agents and their status:
```bash
#!/bin/bash
# Check which agents are configured in openclaw.json
cat ~/.openclaw/openclaw.json | python3 -c "
import json, sys
cfg = json.load(sys.stdin)
agents = cfg.get('agents', {}).get('list', [])
for a in agents:
    print(f\"{a.get('emoji', '?')} {a.get('name')} ({a.get('id')})\")
"
```

```bash
chmod +x ~/.openclaw/skills/multi-agent/scripts/check-agents.sh
```

### Priority 3 — Create _meta.json

```json
{
  "name": "multi-agent",
  "version": "1.0.0",
  "author": "King",
  "pattern": "Pipeline",
  "emoji": "🤝",
  "created": "2026-03-25",
  "requires": {
    "bins": [],
    "modules": [],
    "tools": ["sessions_spawn", "message"]
  },
  "tags": ["multi-agent", "orchestration", "parallel", "pipeline", "delegation"]
}
```

### Priority 4 — Create evals/evals.json

```bash
mkdir -p ~/.openclaw/skills/multi-agent/evals
```

```json
{
  "skill_name": "multi-agent",
  "pattern": "Pipeline",
  "evals": [
    {
      "id": 1,
      "prompt": "Use multi-agent to research MCP protocol and write a blog post",
      "input": "Research MCP then write blog",
      "expected": "Serial pipeline: researcher first, content after with research results passed in"
    },
    {
      "id": 2,
      "prompt": "Simultaneously research 3 topics: LLMs, RAG, and Vector DBs",
      "input": "Parallel research on 3 independent topics",
      "expected": "3 parallel researcher spawns, no serial dependency"
    },
    {
      "id": 3,
      "prompt": "Full product flow: break down requirements, design tech solution, verify",
      "input": "Build a task management feature",
      "expected": "Serial: product-owner → tech-lead → verifier, each waiting on previous"
    }
  ]
}
```

### Priority 5 — Create README.md

Cover:
- Design philosophy (parallel vs serial decision tree)
- Why Discord留痕 is mandatory (audit trail)
- maxConcurrent: 8 limit and why
- Why main doesn't let agents talk to each other directly
- When NOT to use multi-agent (simple tasks)
- Related skills: task routing, discord integration

## Final Checklist

- [ ] SKILL.md updated: frontmatter added, pattern label, USE FOR, REQUIRES, Prerequisites, Quick Start, When to Use, Error Handling
- [ ] Pattern labeled as **Pipeline**
- [ ] scripts/check-agents.sh created and executable
- [ ] evals/evals.json has ≥ 3 test cases
- [ ] _meta.json created
- [ ] README.md created
- [ ] `openclaw config validate` passes
