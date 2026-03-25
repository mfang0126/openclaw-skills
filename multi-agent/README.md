# multi-agent

> Orchestrate parallel and serial multi-agent task pipelines across the OpenClaw agent roster.

## Install

No installation needed. Uses `sessions_spawn` and `message` tools built into OpenClaw.

## Usage

```javascript
// Parallel spawn
sessions_spawn(agentId="researcher", task="Research X")
sessions_spawn(agentId="content", task="Write about Y")

// Serial spawn (wait for result before next)
// 1. Spawn first
sessions_spawn(agentId="researcher", task="Research X")
// 2. After result → spawn next with output
sessions_spawn(agentId="content", task="Write based on: {research_result}")
```

## How It Works

**Pattern: Pipeline** (Google ADK)

```
User request
  → Analyze task dependencies (parallel vs serial?)
  → Route to appropriate agents (routing table)
  → Spawn sub-agents via sessions_spawn
  → Each agent runs + reports to Discord
  → Main collects results
  → Summarize and reply to user
```

## Design Decisions

- **Parallel by default**: Independent tasks run simultaneously (up to 8 concurrent)
- **Serial when dependent**: If B needs A's output, always wait for A first
- **Discord 留痕 is mandatory**: Every spawn includes Discord reporting instructions — audit trail required
- **Main as coordinator only**: Agents never talk directly to each other; main routes results
- **Simple tasks inline**: Don't spawn an agent for a single search or small edit — overhead not worth it

## Agent Roster

| Agent | ID | Specialty |
|-------|----|-----------|
| Researcher | `researcher` | Research, analysis, data collection |
| Content Writer | `content` | Blog posts, LinkedIn, copywriting |
| Tech Lead | `tech-lead` | Architecture, task breakdown, code |
| Product Owner | `product-owner` | User stories, requirements, acceptance |
| Verifier | `verifier` | QA, validation, acceptance checks |

## When NOT to Use

- Single search queries → do inline
- Simple edits or one-liner answers → do inline  
- Tasks one agent handles fine → single agent, no orchestration overhead
- Only use multi-agent when parallelism or specialization genuinely saves time

## maxConcurrent

Hard limit: **8 parallel agents**. Beyond this, queue or serialize.

## Limitations

- Agents cannot communicate directly — all coordination flows through main
- Discord reporting is optional but strongly recommended for visibility
- Sub-agents must call `sessions_yield` to return results; silence = stall

## Related Skills

- None (standalone orchestration skill)
