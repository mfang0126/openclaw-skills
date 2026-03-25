# Advanced Sub-Agent Patterns

> Background agents, model selection, context considerations, persona routing, hooks, nested CLAUDE.md, master-clone vs custom.

## Advanced Patterns

### Background Agents (Async Delegation)

Send agents to the background while continuing work in your main session:

**Ctrl+B** during agent execution moves it to background.

```
> Use the research-agent to analyze these 10 frameworks
[Agent starts working...]
[Press Ctrl+B]
→ Agent continues in background
→ Main session free for other work
→ Check results later with: "What did the research agent find?"
```

**Use cases**:
- Long-running research tasks
- Parallel documentation fetching
- Non-blocking code reviews

### Model Selection Strategy

**Quality-First Approach**: Default to Sonnet for most agents. The cost savings from Haiku rarely outweigh the quality loss.

| Model | Best For | Speed | Cost | Quality |
|-------|----------|-------|------|---------|
| `sonnet` | **Default for most agents** - content generation, reasoning, file creation | Balanced | Standard | ✅ High |
| `opus` | Creative work, complex reasoning, quality-critical outputs | Slower | Premium | ✅ Highest |
| `haiku` | **Only for simple script execution** where quality doesn't matter | 2x faster | 3x cheaper | ⚠️ Variable |
| `inherit` | Match main conversation | Varies | Varies | Matches parent |

**Why Sonnet Default?**

Testing showed significant quality differences:
- **Haiku**: Wrong stylesheet links, missing CSS, wrong values, incorrect patterns
- **Sonnet**: Correct patterns, proper validation, fewer errors

| Task Type | Recommended Model | Why |
|-----------|-------------------|-----|
| Content generation | Sonnet | Quality matters |
| File creation | Sonnet | Patterns must be correct |
| Code writing | Sonnet | Bugs are expensive |
| Audits/reviews | Sonnet | Judgment required |
| Creative work | Opus | Maximum quality |
| Deploy scripts | Haiku (OK) | Just running commands |
| Simple format checks | Haiku (OK) | Pass/fail only |

**Pattern**: Default Sonnet, use Opus for creative, Haiku only when quality truly doesn't matter:

```yaml
---
name: site-builder
model: sonnet  # Content quality matters - NOT haiku
tools: Read, Write, Edit, Glob, Grep
---

---
name: creative-director
model: opus  # Creative work needs maximum quality
tools: Read, Write, Edit, Glob, Grep
---

---
name: deploy-runner
model: haiku  # Just running wrangler commands - quality irrelevant
tools: Read, Bash
---
```

### Agent Context Considerations

Agent context usage depends heavily on the task:

| Scenario | Context | Tool Calls | Works? |
|----------|---------|------------|--------|
| Deep research agent | 130k | 90+ | ✅ Yes |
| Multi-file audit | 80k+ | 50+ | ✅ Yes |
| Simple format check | 3k | 5-10 | ✅ Yes |
| Chained orchestration | Varies | Varies | ✅ Depends on task |

**Reality**: Agents with 90+ tool calls and 130k context work fine when doing meaningful work. The limiting factor is task complexity, not arbitrary token limits.

**What actually matters**:
- Is the agent making progress on each tool call?
- Is context being used for real work vs redundant instructions?
- Are results coherent at the end?

**When context becomes a problem**:
- Agent starts repeating itself or losing track
- Results become incoherent or contradictory
- Agent "forgets" earlier findings in long sessions

### Persona-Based Routing

Prevent agents from drifting into adjacent domains with explicit constraints:

```yaml
---
name: frontend-specialist
description: Frontend code expert. NEVER writes backend logic.
tools: Read, Write, Edit, Glob, Grep
---

You are a frontend specialist.

BOUNDARIES:
- NEVER write backend logic, API routes, or database queries
- ALWAYS use React patterns consistent with the codebase
- If task requires backend work, STOP and report "Requires backend specialist"

FOCUS:
- React components, hooks, state management
- CSS/Tailwind styling
- Client-side routing
- Browser APIs
```

This prevents hallucination when agents encounter unfamiliar domains.

### Hooks Patterns

Hooks enable automated validation and feedback:

**Block-at-commit** (enforce quality gates):
```yaml
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: |
            if [[ "$BASH_COMMAND" == *"git commit"* ]]; then
              npm test || exit 1
            fi
```

**Hint hooks** (non-blocking feedback):
```yaml
hooks:
  PostToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "./scripts/lint-check.sh"
          # Exits 0 to continue, non-zero to warn
```

**Best practice**: Validate at commit stage, not mid-plan. Let agents work freely, catch issues before permanent changes.

### Nested CLAUDE.md Context

Claude automatically loads `CLAUDE.md` files from subdirectories when accessing those paths:

```
project/
├── CLAUDE.md              # Root context (always loaded)
├── src/
│   └── CLAUDE.md          # Loaded when editing src/**
├── tests/
│   └── CLAUDE.md          # Loaded when editing tests/**
└── docs/
    └── CLAUDE.md          # Loaded when editing docs/**
```

**Use for**: Directory-specific coding standards, local patterns, module documentation.

This is lazy-loaded context - sub-agents get relevant context without bloating main prompt.

### Master-Clone vs Custom Subagent

Two philosophies for delegation:

**Custom Subagents** (explicit specialists):
```
Main Claude → task-runner agent → result
```
- Pros: Isolated context, specialized prompts, reusable
- Cons: Gatekeeper effect (main agent loses visibility)

**Master-Clone** (dynamic delegation):
```
Main Claude → Task(general-purpose) → result
```
- Pros: Main agent stays informed, flexible routing
- Cons: Less specialized, may need more guidance

**Recommendation**: Use custom agents for well-defined, repeated tasks. Use Task(general-purpose) for ad-hoc delegation where main context matters.

---
