# sub-agent-patterns

> Reference guide for configuring and delegating to sub-agents in Claude Code.

## How It Works

**Pattern: Tool Wrapper** (Google ADK)

This skill loads structured reference knowledge on demand so Claude can correctly configure and delegate to sub-agents. No pipeline steps — pure knowledge injection.

## Skill Organization

```
sub-agent-patterns/
├── SKILL.md                           # Overview, decision trees, key principles
└── references/
    ├── custom-agent-config.md         # Full config fields, tool table, Bash spam prevention
    ├── orchestration.md               # Orchestrator pattern, nesting depth, parallel workflows
    ├── advanced-patterns.md           # Background agents, model selection, hooks, persona routing
    ├── prompt-templates.md            # Copy-paste delegation prompt templates
    └── example-agents.md             # Ready-to-use YAML configs (code-reviewer, debugger, etc.)
```

## When to Read Which Reference

| You need... | Read |
|-------------|------|
| Config fields, tool lists, Bash spam fix | `references/custom-agent-config.md` |
| Setting up orchestration / parallel specialists | `references/orchestration.md` |
| Background agents, model selection, hooks | `references/advanced-patterns.md` |
| Ready-to-paste delegation prompts | `references/prompt-templates.md` |
| Full agent YAML configs to copy | `references/example-agents.md` |

## Key Principles

1. **Context hygiene** — Sub-agents isolate verbose outputs, keeping main context clean
2. **No Bash unless needed** — Bash triggers approval prompts; use Write tool for file creation
3. **Instructions first** — Critical rules go immediately after frontmatter
4. **Default Sonnet** — Quality matters more than speed/cost for most agents
5. **Max 2 nesting levels** — orchestrator → specialist is fine; deeper breaks context

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/validate_agent.sh` | Check agent .md file has required frontmatter fields |

## Limitations

- Session restart required after creating new agent files
- Sub-agents cannot spawn sub-agents beyond depth 2 reliably
- Agents don't inherit parent skills — pass via `skills:` field in frontmatter
- `--agents` CLI config doesn't persist across sessions
