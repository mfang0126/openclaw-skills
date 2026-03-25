---
name: sub-agent-patterns
description: |
  Comprehensive guide to sub-agents in Claude Code: built-in agents (Explore, Plan, general-purpose), custom agent creation, configuration, and delegation patterns.

  USE FOR:
  - "创建子代理", "create a sub-agent", "delegate this task to an agent"
  - "parallel research", "run agents in parallel", "spawn a sub-agent"
  - "agent context hygiene", "bulk operations with agents", "batch processing"
  - "how do I use sub-agents?", "configure agent tools", "custom agent config"
  - User needs orchestration, background agents, or wants to understand agent routing
user-invocable: true
---

# Sub-Agents in Claude Code

**Pattern: Tool Wrapper**

## When to Use

Use when you need to **delegate work to isolated AI workers** with their own context windows. Typical triggers: running parallel research across multiple files/topics, orchestrating bulk operations (audit 50+ files, batch updates), keeping main context clean from verbose tool outputs, or configuring custom agents for repeated workflows.

**Don't use when:** The task is a simple one-off query with no repetition, no verbose output, and no parallel work—just do it inline.

## Example

**User says:** "Audit all 30 skill SKILL.md files and check if they have a 'Don't use when' section. Fix any that are missing it."

**Steps:**
1. List all skills: `ls ~/.openclaw/skills/`
2. Divide into 4 batches of ~8 skills each
3. Launch 4 parallel agents with this prompt template:
   - Read SKILL.md → Check for "Don't use when" → If missing, add one based on the skill's context → Report what was changed
4. Wait for all 4 agents to complete
5. Review `git diff` on changed files, spot-check a few
6. Commit: `git commit -m "fix(skills): add Don't use when to 12 skills"`

**Output:** 12 files updated, 18 already had the section. Each agent returned a structured report: `[skill-name]: added / already present`.

**Reply:** "Done — 12 skills updated with 'Don't use when' guidance. Changes committed. Want me to do a second pass on any specific skill?"

## Prerequisites

1. Claude Code with sub-agent support (built-in Explore, Plan, and general-purpose agents are always available)
2. For custom agents: Create `.claude/agents/*.md` (project-level) or `~/.claude/agents/*.md` (user-level)
3. Restart Claude Code session after adding new agent files
4. Optional: `Task` tool in agent config to enable orchestration (nesting)

**Status**: Production Ready ✅
**Last Updated**: 2026-01-14
**Source**: https://code.claude.com/docs/en/sub-agents

Sub-agents are specialized AI assistants that Claude Code can delegate tasks to. Each sub-agent has its own context window, configurable tools, and custom system prompt.

---

## Why Use Sub-Agents: Context Hygiene

The primary value of sub-agents isn't specialization—it's **keeping your main context clean**.

**Without agent** (context bloat):
```
Main context accumulates:
├─ git status output (50 lines)
├─ npm run build output (200 lines)
├─ tsc --noEmit output (100 lines)
├─ wrangler deploy output (100 lines)
├─ curl health check responses
├─ All reasoning about what to do next
└─ Context: 📈 500+ lines consumed
```

**With agent** (context hygiene):
```
Main context:
├─ "Deploy to cloudflare"
├─ [agent summary - 30 lines]
└─ Context: 📊 ~50 lines consumed

Agent context (isolated):
├─ All verbose tool outputs
├─ All intermediate reasoning
└─ Discarded after returning summary
```

**The math**: A deploy workflow runs ~10 tool calls. That's 500+ lines in main context vs 30-line summary with an agent. Over a session, this compounds dramatically.

**When this matters most**:
- Repeatable workflows (deploy, migrate, audit, review)
- Verbose tool outputs (build logs, test results, API responses)
- Multi-step operations where only the final result matters
- Long sessions where context pressure builds up

**Key insight**: Use agents for **workflows you repeat**, not just for specialization. The context savings compound over time.

---

## Built-in Sub-Agents

Claude Code includes three built-in sub-agents available out of the box:

### Explore Agent

Fast, lightweight agent optimized for **read-only** codebase exploration.

| Property | Value |
|----------|-------|
| **Model** | Haiku (fast, low-latency) |
| **Mode** | Strictly read-only |
| **Tools** | Glob, Grep, Read, Bash (read-only: ls, git status, git log, git diff, find, cat, head, tail) |

**Thoroughness levels** (specify when invoking):
- `quick` - Fast searches, targeted lookups
- `medium` - Balanced speed and thoroughness
- `very thorough` - Comprehensive analysis across multiple locations

**When Claude uses it**: Searching/understanding codebase without making changes. Findings don't bloat the main conversation.

```
User: Where are errors from the client handled?
Claude: [Invokes Explore with "medium" thoroughness]
       → Returns: src/services/process.ts:712
```

### Plan Agent

Specialized for **plan mode** research and information gathering.

| Property | Value |
|----------|-------|
| **Model** | Sonnet |
| **Mode** | Read-only research |
| **Tools** | Read, Glob, Grep, Bash |
| **Invocation** | Automatic in plan mode |

**When Claude uses it**: In plan mode when researching codebase to create a plan. Prevents infinite nesting (sub-agents cannot spawn sub-agents).

### General-Purpose Agent

Capable agent for complex, multi-step tasks requiring both exploration AND action.

| Property | Value |
|----------|-------|
| **Model** | Sonnet |
| **Mode** | Read AND write |
| **Tools** | All tools |
| **Purpose** | Complex research, multi-step operations, code modifications |

**When Claude uses it**:
- Task requires both exploration and modification
- Complex reasoning needed to interpret search results
- Multiple strategies may be needed
- Task has multiple dependent steps

---

## Creating Custom Sub-Agents

> **See `references/custom-agent-config.md`** for full config fields, tool reference table, Bash spam prevention, and examples.

### File Locations

| Type | Location | Priority |
|------|----------|----------|
| Project | `.claude/agents/*.md` | Highest |
| User | `~/.claude/agents/*.md` | Lower |
| CLI | `--agents '{...}'` | Middle |

**⚠️ Session Restart Required** — new agent files are only loaded at session startup.

### Minimal Config

```yaml
---
name: code-reviewer
description: Expert code reviewer. Use proactively after code changes.
tools: Read, Grep, Glob, Bash
model: sonnet
---
Your system prompt here.
```

### Tool Access Principle (CRITICAL)

**Don't give Bash unless the agent needs CLI execution.** Bash triggers approval prompts for every unique command, causing workflow interruptions.

| Agent Type | Recommended Tools |
|------------|-----------------|
| File creators | `Read, Write, Edit, Glob, Grep` (NO Bash) |
| Script runners | `Read, Write, Edit, Glob, Grep, Bash` |
| Research | `Read, Grep, Glob, WebFetch, WebSearch` |
| Orchestrators | `Read, Grep, Glob, Task` |

Put critical instructions **FIRST** in the prompt (right after frontmatter) — instructions buried 300+ lines deep get ignored.

Use `/agents` command for interactive setup and management.
## Using Sub-Agents

### Automatic Delegation

Claude proactively delegates based on:
- Task description in your request
- `description` field in sub-agent config
- Current context and available tools

**Tip**: Include "use PROACTIVELY" or "MUST BE USED" in description for more automatic invocation.

### Explicit Invocation

```
> Use the test-runner subagent to fix failing tests
> Have the code-reviewer subagent look at my recent changes
> Ask the debugger subagent to investigate this error
```

### Resumable Sub-Agents

Sub-agents can be resumed to continue previous conversations:

```
# Initial invocation
> Use the code-analyzer agent to review the auth module
[Agent completes, returns agentId: "abc123"]

# Resume with full context
> Resume agent abc123 and now analyze the authorization logic
```

**Use cases**:
- Long-running research across multiple sessions
- Iterative refinement without losing context
- Multi-step workflows with maintained context

### Disabling Sub-Agents

Add to settings.json permissions:

```json
{
  "permissions": {
    "deny": ["Task(Explore)", "Task(Plan)"]
  }
}
```

Or via CLI:
```bash
claude --disallowedTools "Task(Explore)"
```

---

## Agent Orchestration

> **See `references/orchestration.md`** for full detail including the Orchestrator Pattern YAML and multi-specialist workflow examples.

**Enable orchestration**: Add `Task` to the agent's `tools` list.

**Nesting**: Max 2 levels deep (Claude → orchestrator → specialist). Beyond that, context gets thin.

**Use orchestration when**: Multi-phase workflows, parallel specialists needed, synthesis required.  
**Use direct delegation when**: Single task, one specialist, sequential is fine.

**Orchestrator pattern** — coordinator spawns specialists in parallel, synthesizes all reports into one output.
## Advanced Patterns

> **See `references/advanced-patterns.md`** for detailed coverage.

Topics covered:
- **Background agents** (Ctrl+B) — async delegation while main session continues
- **Model selection** — Default Sonnet; Haiku only for simple script execution; Opus for creative work
- **Context considerations** — 130k+ contexts work fine; limiting factor is task quality, not token count
- **Persona-based routing** — Prevent domain drift with explicit BOUNDARIES constraints
- **Hooks patterns** — PreToolUse/PostToolUse for quality gates and validation
- **Nested CLAUDE.md** — Directory-specific context, lazy-loaded per path
- **Master-Clone vs Custom** — Custom for repeated tasks, general-purpose for ad-hoc
## Delegation Patterns

### The Sweet Spot

**Best use case**: Tasks that are **repetitive but require judgment**.

```
✅ Good fit:
   - Audit 70 skills (repetitive) checking versions against docs (judgment)
   - Update 50 files (repetitive) deciding what needs changing (judgment)
   - Research 10 frameworks (repetitive) evaluating trade-offs (judgment)

❌ Poor fit:
   - Simple find-replace (no judgment needed, use sed/grep)
   - Single complex task (not repetitive, do it yourself)
   - Tasks with cross-item dependencies (agents work independently)
```

### Core Prompt Template

This 5-step structure works consistently:

```markdown
For each [item]:
1. Read [source file/data]
2. Verify with [external check - npm view, API, docs]
3. Check [authoritative source]
4. Evaluate/score
5. FIX issues found ← Critical: gives agent authority to act
```

**Key elements:**
- **"FIX issues found"** - Without this, agents only report. With it, they take action.
- **Exact file paths** - Prevents ambiguity and wrong-file edits
- **Output format template** - Ensures consistent, parseable reports
- **Item list** - Explicit list of what to process

### Batch Sizing

| Batch Size | Use When |
|------------|----------|
| 3-5 items | Complex tasks (deep research, multi-step fixes) |
| 5-8 items | Standard tasks (audits, updates, validations) |
| 8-12 items | Simple tasks (version checks, format fixes) |

**Why not more?**
- Agent context fills up
- One failure doesn't ruin entire batch
- Easier to review smaller changesets

**Parallel agents**: Launch 2-4 agents simultaneously, each with their own batch.

### Workflow Pattern

```
┌─────────────────────────────────────────────────────────────┐
│  1. PLAN: Identify items, divide into batches               │
│     └─ "58 skills ÷ 10 per batch = 6 agents"                │
├─────────────────────────────────────────────────────────────┤
│  2. LAUNCH: Parallel Task tool calls with identical prompts │
│     └─ Same template, different item lists                  │
├─────────────────────────────────────────────────────────────┤
│  3. WAIT: Agents work in parallel                           │
│     └─ Read → Verify → Check → Edit → Report                │
├─────────────────────────────────────────────────────────────┤
│  4. REVIEW: Check agent reports and file changes            │
│     └─ git status, spot-check diffs                         │
├─────────────────────────────────────────────────────────────┤
│  5. COMMIT: Batch changes with meaningful changelog         │
│     └─ One commit per tier/category, not per agent          │
└─────────────────────────────────────────────────────────────┘
```

---

## Prompt Templates

> **See `references/prompt-templates.md`** for copy-paste ready templates.

Three core patterns:
- **Audit/Validation**: Read → Verify → Check → Score → FIX
- **Bulk Update**: Read → Identify → Apply → Verify → Report  
- **Research/Comparison**: Docs → Version → Features → Gotchas → Rate

All use the 5-step structure with an explicit item list and output format template.
## Example Custom Sub-Agents

> **See `references/example-agents.md`** for full YAML configurations.

Includes ready-to-use configs for: **code-reviewer**, **debugger**, **data-scientist**.

Each includes correct tool sets, model selection, and system prompt structure.
## Commit Strategy

**Agents don't commit** - they only edit files. This is by design:

| Agent Does | Human Does |
|------------|------------|
| Research & verify | Review changes |
| Edit files | Spot-check diffs |
| Score & report | git add/commit |
| Create summaries | Write changelog |

**Why?**
- Review before commit catches agent errors
- Batch multiple agents into meaningful commits
- Clean commit history (not 50 tiny commits)
- Human decides commit message/grouping

**Commit pattern:**
```bash
git add [files] && git commit -m "$(cat <<'EOF'
[type]([scope]): [summary]

[Batch 1 changes]
[Batch 2 changes]
[Batch 3 changes]

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

---

## Error Handling

| Situation | Cause | Resolution |
|-----------|-------|------------|
| One agent fails mid-batch | Context overflow, tool error, or timeout | Check error message; retry that batch or skip and continue — don't let one failure block the whole operation |
| Agent makes wrong change | Prompt was ambiguous or instructions were buried too deep | `git diff [file]` to see what changed; `git checkout -- [file]` to revert; re-run with more specific instructions placed at the top of the prompt |
| Two agents conflict on the same file | Overlapping item lists or shared file edits | Check which agent's change is correct; manually resolve or re-run one agent with explicit file path scoping |
| Agent does nothing / only reports | Prompt lacked authority to act | Add "FIX issues found" to the prompt — without it, agents only report |
| Bash approval spam interrupts flow | Agent given Bash tool unnecessarily | Remove Bash from agent tools unless CLI execution is truly required |

---

## Best Practices

1. **Start with Claude-generated agents**: Use `/agents` to generate initial config, then customize
2. **Design focused sub-agents**: Single, clear responsibility per agent
3. **Write detailed prompts**: Specific instructions, examples, constraints
4. **Don't give Bash unless needed**: Prevents approval spam (see "Avoiding Bash Approval Spam")
5. **Put critical instructions FIRST**: Instructions at top of prompt get followed, buried ones get ignored
6. **Remove contradictory instructions**: If you want Write tool, remove all bash examples
7. **Default to Sonnet model**: Quality matters more than cost savings (see Model Selection)
8. **Version control**: Check `.claude/agents/` into git for team sharing
9. **Use inherit for model sparingly**: Better to explicitly set model for predictable behavior

---

## Performance Considerations

- **Context efficiency**: Agents preserve main context, enabling longer sessions
- **Latency**: Sub-agents start fresh, may add latency gathering context
- **Thoroughness**: Explore agent's thoroughness levels trade speed for completeness

## Quick Reference

```
Built-in agents:
  Explore  → Haiku, read-only, quick/medium/thorough
  Plan     → Sonnet, plan mode research
  General  → Sonnet, all tools, read/write

Custom agents:
  Project  → .claude/agents/*.md (highest priority)
  User     → ~/.claude/agents/*.md
  CLI      → --agents '{...}'

Config fields:
  name, description (required)
  tools, model, permissionMode, skills, hooks (optional)

Tool access principle:
  ⚠️ Don't give Bash unless agent needs CLI execution
  File creators: Read, Write, Edit, Glob, Grep (no Bash!)
  Script runners: Read, Write, Edit, Glob, Grep, Bash (only if needed)
  Research: Read, Grep, Glob, WebFetch, WebSearch

Model selection (quality-first):
  Default: sonnet (most agents - quality matters)
  Creative: opus (maximum quality)
  Scripts only: haiku (just running commands)
  ⚠️ Avoid Haiku for content generation - quality drops significantly

Instruction placement:
  ⛔ Critical instructions go FIRST (right after frontmatter)
  ⚠️ Instructions buried 300+ lines deep get ignored
  ✅ Remove contradictory instructions (pick one pattern)

Delegation:
  Batch size: 5-8 items per agent
  Parallel: 2-4 agents simultaneously
  Prompt: 5-step (read → verify → check → evaluate → FIX)

Orchestration:
  Enable: Add "Task" to agent's tools list
  Depth: Keep to 2 levels max
  Use: Multi-phase workflows, parallel specialists

Advanced:
  Background: Ctrl+B during agent execution
  Context: 130k+ and 90+ tool calls work fine for real work
  Hooks: PreToolUse, PostToolUse, Stop events

Resume agents:
  > Resume agent [agentId] and continue...
```

---

## References

- [Sub-Agents Docs](https://code.claude.com/docs/en/sub-agents)
- [Plugins Docs](https://code.claude.com/docs/en/plugins)
- [Tools Docs](https://code.claude.com/docs/en/tools)
- [Hooks Docs](https://code.claude.com/docs/en/hooks)
- [CLI Reference](https://code.claude.com/docs/en/cli-reference)
- [Awesome Claude Code Subagents](https://github.com/VoltAgent/awesome-claude-code-subagents)
