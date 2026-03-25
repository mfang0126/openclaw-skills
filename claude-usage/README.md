# claude-usage

> Check your Claude Max/Pro subscription quota remaining — not what you spent, but what you have left. Answers "am I about to hit my limit?" in ~8 seconds.

**Pattern: Tool Wrapper** (Google ADK)

## How It Works

```
User asks about quota / rate limits / usage
  → Create temp tmux session
  → git init scratch repo (Claude CLI requires a git context)
  → Launch claude CLI
  → Auto-accept "trust this folder" prompt
  → Send /usage command
  → Capture output (plan type, session %, weekly %, reset time)
  → Kill tmux session
  → Return parsed result
```

```bash
bash ./scripts/check-usage.sh
```

## Output

```
Plan: Claude Max (Opus 4.6)
Session usage: 12% used
Weekly (all models): 34% used
Weekly (Sonnet only): 21% used
Resets: Sunday 00:00 UTC
```

## This vs API Billing Tools

| Tool | Answers | Who needs it |
|------|---------|-------------|
| **claude-usage** (this) | How much subscription quota is left | Max/Pro subscribers working locally |
| API billing dashboards | How many tokens/dollars spent via API | API key users, teams |

If you use Claude via API key, this tool is not for you. If you have a Claude Max or Pro subscription and use Claude Code CLI, this is exactly what you need.

## Trigger Scenarios

Use this skill whenever the user asks:
- "How much Claude do I have left?"
- "Am I rate limited?"
- "When does my quota reset?"
- "Claude is being slow — is it throttling me?"
- "还剩多少用量？" / "查一下用量" / "还能用吗"

Also invoke proactively when Claude responses feel sluggish — quota exhaustion is the most common cause.

## Design Decisions

- **tmux automation**: Avoids needing any special API access; works with standard Claude Code CLI subscription
- **Scratch git repo**: Claude CLI checks for a git repo at startup; the script creates a temp one and cleans it up
- **No stored credentials**: The script reuses the existing `claude` CLI auth session — no keys, no tokens needed
- **~8-10s cold start**: Bottleneck is Claude Code CLI startup; this is unavoidable without a dedicated API

## Dependencies & Verification

```bash
# Verify all deps are present
which tmux && echo "tmux ok"
which claude && echo "claude ok"
which git && echo "git ok"
claude --version  # confirms auth is valid
```

## Limitations

- Only works with **Claude Max/Pro subscription** (not API billing)
- Requires `tmux`, `claude`, and `git` in PATH
- ~8-10 second startup time (Claude CLI cold start)
- Output format depends on Claude Code CLI's `/usage` layout — may break if Anthropic changes it
- Does not work in sandboxed/containerized environments without a terminal

## Related Skills

- `ai-sdk` — For API token usage in code (different problem: SDK costs vs subscription quota)
