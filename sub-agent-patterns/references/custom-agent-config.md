# Custom Sub-Agent Configuration Reference

> File locations, frontmatter format, all config fields, tool reference table, tool access patterns, Bash approval spam prevention.

## Creating Custom Sub-Agents

### File Locations

| Type | Location | Scope | Priority |
|------|----------|-------|----------|
| Project | `.claude/agents/` | Current project only | Highest |
| User | `~/.claude/agents/` | All projects | Lower |
| CLI | `--agents '{...}'` | Current session | Middle |

When names conflict, project-level takes precedence.

**⚠️ CRITICAL: Session Restart Required**

Agents are loaded at session startup only. If you create new agent files during a session:
1. They won't appear in `/agents`
2. Claude won't be able to invoke them
3. **Solution**: Restart Claude Code session to discover new agents

This is the most common reason custom agents "don't work" - they were created after the session started.

### File Format

Markdown files with YAML frontmatter:

```yaml
---
name: code-reviewer
description: Expert code reviewer. Use proactively after code changes.
tools: Read, Grep, Glob, Bash
model: inherit
permissionMode: default
skills: project-workflow
hooks:
  PostToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "./scripts/run-linter.sh"
---

Your sub-agent's system prompt goes here.

Include specific instructions, best practices, and constraints.
```

### Configuration Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Unique identifier (lowercase, hyphens) |
| `description` | Yes | When Claude should use this agent |
| `tools` | No | Comma-separated list. Omit = inherit all tools |
| `model` | No | `sonnet`, `opus`, `haiku`, or `inherit`. Default: sonnet |
| `permissionMode` | No | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan`, `ignore` |
| `skills` | No | Comma-separated skills to auto-load (sub-agents don't inherit parent skills) |
| `hooks` | No | `PreToolUse`, `PostToolUse`, `Stop` event handlers |

### Available Tools Reference

Complete list of tools that can be assigned to sub-agents:

| Tool | Purpose | Type |
|------|---------|------|
| **Read** | Read files (text, images, PDFs, notebooks) | Read-only |
| **Write** | Create or overwrite files | Write |
| **Edit** | Exact string replacements in files | Write |
| **MultiEdit** | Batch edits to single file | Write |
| **Glob** | File pattern matching (`**/*.ts`) | Read-only |
| **Grep** | Content search with regex (ripgrep) | Read-only |
| **LS** | List directory contents | Read-only |
| **Bash** | Execute shell commands | Execute |
| **BashOutput** | Get output from background shells | Execute |
| **KillShell** | Terminate background shell | Execute |
| **Task** | Spawn sub-agents | Orchestration |
| **WebFetch** | Fetch and analyze web content | Web |
| **WebSearch** | Search the web | Web |
| **TodoWrite** | Create/manage task lists | Organization |
| **TodoRead** | Read current task list | Organization |
| **NotebookRead** | Read Jupyter notebooks | Notebook |
| **NotebookEdit** | Edit Jupyter notebook cells | Notebook |
| **AskUserQuestion** | Interactive user questions | UI |
| **EnterPlanMode** | Enter planning mode | Planning |
| **ExitPlanMode** | Exit planning mode with plan | Planning |
| **Skill** | Execute skills in conversation | Skills |
| **LSP** | Language Server Protocol integration | Advanced |
| **MCPSearch** | MCP tool discovery | Advanced |

**Tool Access Patterns by Agent Type:**

| Agent Type | Recommended Tools | Notes |
|------------|-------------------|-------|
| Read-only reviewers | `Read, Grep, Glob, LS` | No write capability |
| File creators | `Read, Write, Edit, Glob, Grep` | ⚠️ **No Bash** - avoids approval spam |
| Script runners | `Read, Write, Edit, Glob, Grep, Bash` | Use when CLI execution needed |
| Research agents | `Read, Grep, Glob, WebFetch, WebSearch` | Read-only external access |
| Documentation | `Read, Write, Edit, Glob, Grep, WebFetch` | No Bash for cleaner workflow |
| Orchestrators | `Read, Grep, Glob, Task` | Minimal tools, delegates to specialists |
| Full access | Omit `tools` field (inherits all) | Use sparingly |

**⚠️ Tool Access Principle**: If an agent doesn't need Bash, don't give it Bash. Each bash command requires approval, causing workflow interruptions. See "Avoiding Bash Approval Spam" below.

### Avoiding Bash Approval Spam (CRITICAL)

When sub-agents have Bash in their tools list, they often default to using `cat > file << 'EOF'` heredocs for file creation instead of the Write tool. Each unique bash command requires user approval, causing:

- Dozens of approval prompts per agent run
- Slow, frustrating workflow
- Hard to review (heredocs are walls of minified content)

**Root Causes**:
1. **Models default to bash for file ops** - Training data bias toward shell commands
2. **Bash in tools list = Bash gets used** - Even if Write tool is available
3. **Instructions get buried** - A "don't use bash" rule at line 300 of a 450-line prompt gets ignored

**Solutions** (in order of preference):

1. **Remove Bash from tools list** (if not needed):
   ```yaml
   # Before - causes approval spam
   tools: Read, Write, Edit, Glob, Grep, Bash

   # After - clean file operations
   tools: Read, Write, Edit, Glob, Grep
   ```
   If the agent only creates files, it doesn't need Bash. The orchestrator can run necessary scripts after.

2. **Put critical instructions FIRST** (immediately after frontmatter):
   ```markdown
   ---
   name: site-builder
   tools: Read, Write, Edit, Glob, Grep
   model: sonnet
   ---

   ## ⛔ CRITICAL: USE WRITE TOOL FOR ALL FILES

   **You do NOT have Bash access.** Create ALL files using the **Write tool**.

   ---

   [rest of prompt...]
   ```
   Instructions at the top get followed. Instructions buried 300 lines deep get ignored.

3. **Remove contradictory instructions**:
   ```markdown
   # BAD - contradictory
   Line 75: "Copy images with `cp -r intake/images/* build/images/`"
   Line 300: "NEVER use cp, mkdir, cat, or echo"

   # GOOD - consistent
   Only mention the pattern you want used. Remove all bash examples if you want Write tool.
   ```

**When to keep Bash:**
- Agent needs to run external CLIs (wrangler, npm, git)
- Agent needs to execute scripts
- Agent needs to check command outputs

**Testing**: Before vs after removing Bash:
- **Before** (with Bash): 11+ heredoc approval prompts, wrong patterns applied
- **After** (no Bash): Mostly Write tool usage, correct patterns, minimal prompts

### Using /agents Command (Recommended)

```
/agents
```

Interactive menu to:
- View all sub-agents (built-in, user, project)
- Create new sub-agents with guided setup
- Edit existing sub-agents and tool access
- Delete custom sub-agents
- See which sub-agents are active

### CLI Configuration

```bash
claude --agents '{
  "code-reviewer": {
    "description": "Expert code reviewer. Use proactively after code changes.",
    "prompt": "You are a senior code reviewer. Focus on code quality, security, and best practices.",
    "tools": ["Read", "Grep", "Glob", "Bash"],
    "model": "sonnet"
  }
}'
```

---
