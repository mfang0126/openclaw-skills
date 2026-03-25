# Agent Orchestration Patterns

> How to enable orchestration, the Orchestrator Pattern, practical examples, nesting depth, and when to orchestrate vs delegate directly.

## Agent Orchestration

Sub-agents can invoke other sub-agents, enabling sophisticated orchestration patterns. This is accomplished by including the `Task` tool in an agent's tool list.

### How It Works

When a sub-agent has access to the `Task` tool, it can:
- Spawn other sub-agents (built-in or custom)
- Coordinate parallel work across specialists
- Chain agents for multi-phase workflows

```yaml
---
name: orchestrator
description: Orchestrator agent that coordinates other specialized agents. Use for complex multi-phase tasks.
tools: Read, Grep, Glob, Task  # ← Task tool enables agent spawning
model: sonnet
---
```

### Orchestrator Pattern

```yaml
---
name: release-orchestrator
description: Coordinates release preparation by delegating to specialized agents. Use before releases.
tools: Read, Grep, Glob, Bash, Task
---

You are a release orchestrator. When invoked:

1. Use Task tool to spawn code-reviewer agent
   → Review all uncommitted changes

2. Use Task tool to spawn test-runner agent
   → Run full test suite

3. Use Task tool to spawn doc-validator agent
   → Check documentation is current

4. Collect all reports and synthesize:
   - Blockers (must fix before release)
   - Warnings (should address)
   - Ready to release: YES/NO

Spawn agents in parallel when tasks are independent.
Wait for all agents before synthesizing final report.
```

### Practical Examples

**Multi-Specialist Workflow:**
```
User: "Prepare this codebase for production"

orchestrator agent:
  ├─ Task(code-reviewer) → Reviews code quality
  ├─ Task(security-auditor) → Checks for vulnerabilities
  ├─ Task(performance-analyzer) → Identifies bottlenecks
  └─ Synthesizes findings into actionable report
```

**Parallel Research:**
```
User: "Compare these 5 frameworks for our use case"

research-orchestrator:
  ├─ Task(general-purpose) → Research framework A
  ├─ Task(general-purpose) → Research framework B
  ├─ Task(general-purpose) → Research framework C
  ├─ Task(general-purpose) → Research framework D
  ├─ Task(general-purpose) → Research framework E
  └─ Synthesizes comparison matrix with recommendation
```

### Nesting Depth

| Level | Example | Status |
|-------|---------|--------|
| 1 | Claude → orchestrator | ✅ Works |
| 2 | orchestrator → code-reviewer | ✅ Works |
| 3 | code-reviewer → sub-task | ⚠️ Works but context gets thin |
| 4+ | Deeper nesting | ❌ Not recommended |

**Best practice**: Keep orchestration to 2 levels deep. Beyond that, context windows shrink and coordination becomes fragile.

### When to Use Orchestration

| Use Orchestration | Use Direct Delegation |
|-------------------|----------------------|
| Complex multi-phase workflows | Single specialist task |
| Need to synthesize from multiple sources | Simple audit or review |
| Parallel execution important | Sequential is fine |
| Different specialists required | Same agent type |

### Orchestrator vs Direct Delegation

**Direct (simpler, often sufficient):**
```
User: "Review my code changes"
Claude: [Invokes code-reviewer agent directly]
```

**Orchestrated (when coordination needed):**
```
User: "Prepare release"
Claude: [Invokes release-orchestrator]
        orchestrator: [Spawns code-reviewer, test-runner, doc-validator]
        orchestrator: [Synthesizes all reports]
        [Returns comprehensive release readiness report]
```

### Configuration Notes

1. **Tool access propagates**: An orchestrator with `Task` can spawn any agent the session has access to
2. **Model inheritance**: Spawned agents use their configured model (or inherit if set to `inherit`)
3. **Context isolation**: Each spawned agent has its own context window
4. **Results bubble up**: Orchestrator receives agent results and can synthesize them

---
