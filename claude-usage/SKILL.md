---
user-invocable: false
name: claude-quota-checker
source: adapted from openclaw-claude-usage (ClawHub) — rewritten with tmux approach
description: |
  Check how much Claude Max / Claude Pro subscription quota you have LEFT — not how much you spent.
  Shows remaining % for session and weekly windows, plan type, and exact reset times.
  Works by automating Claude Code CLI's /usage command via tmux — no API keys needed.

  USE FOR:
  - "how much Claude do I have left", "check my usage", "am I rate limited"
  - "when does my quota reset", "claude limits", "查用量", "还剩多少"
  - "还能用吗", "why is Claude slow", "am I about to hit my limit"
  - User hits rate limits or Claude feels sluggish — use as first diagnostic
  - "check subscription", "how much quota", "usage status"

  REQUIRES: tmux, claude CLI in PATH, active Claude Pro/Max subscription, git
---

# Claude Quota Checker

**Pattern: Tool Wrapper** (Google ADK)

**How much Claude do you have LEFT?**

Most tools tell you how much you *spent*. This one tells you how much you have *remaining* — the question that actually matters when you're working and worried about hitting limits.

Checks your Claude Max/Pro subscription quota by automating the `/usage` command via tmux. No API keys needed, no Admin keys, no complex setup.

## When to Use

Use when the user wants to know their **remaining Claude subscription quota** — not API billing. Typical triggers: "how much Claude do I have left?", "am I about to hit my limit?", "why is Claude slow?", or any quota/rate-limit question.

**Don't use when:** User is asking about API token costs or billing (this only works for Claude Pro/Max subscriptions, not API usage).

## Prerequisites

- macOS or Linux
- `tmux` installed (`brew install tmux`)
- `claude` CLI in PATH (Claude Code CLI)
- Active Claude Code authentication (Pro or Max subscription)
- `git` installed (`brew install git`)

## Quick Start

```bash
# Check quota from the skill directory
bash ~/.openclaw/skills/claude-usage/scripts/check-usage.sh
```

## How It Works

1. Creates a temporary tmux session with a scratch git repo
2. Launches Claude Code CLI
3. Handles the "trust this folder" prompt automatically
4. Sends `/usage` command
5. Captures and parses the output
6. Cleans up tmux session

## Output

- **Plan type**: Pro or Max (e.g., "Opus 4.6 — Claude Max")
- **Session usage**: current session % used
- **Weekly usage**: all models % and Sonnet-only %
- **Reset time**: when the weekly quota resets

## Examples

### Example 1: Check remaining quota

**User says:** "how much Claude do I have left?"

**Steps:**
```bash
bash ~/.openclaw/skills/claude-usage/scripts/check-usage.sh
```

**Output:**
```
Plan: Claude Max (Opus 4.6)
Session usage: 23% used
Weekly (all models): 41% used
Weekly (Sonnet only): 15% used
Resets: Friday 09:00 UTC
```

**Reply:** "You've used 41% of your weekly quota. Resets Friday at 9am UTC — you're fine for now."

### Example 2: Rate-limit diagnostic

**User says:** "Claude feels really slow today, am I rate limited?"

**Steps:** Run the quota checker first to see if usage is high (>80%).

**Reply:** "You're at 87% weekly usage — that's why responses are slower. Quota resets tomorrow at 9am UTC."

## Error Handling

| Error | Cause | Solution |
|-------|-------|----------|
| `command not found: tmux` | tmux not installed | `brew install tmux` |
| Session hangs > 15 seconds | Claude CLI not found or not in PATH | Install Claude Code CLI; ensure `claude` is in PATH |
| "Please log in" in output | Auth expired | Run `claude` manually and re-authenticate |
| Script fails at `git init` | git not installed | `brew install git` |
| Empty output / parse failure | Claude CLI `/usage` format changed | Update parsing logic in check-usage.sh |

If the script hangs: `tmux kill-session -t cu-*`

## Performance

~8-10 seconds (bottleneck: Claude Code CLI startup time).

## Limitations

- Only checks **subscription** usage (Pro/Max), not API billing
- Requires a running terminal environment (won't work in sandboxed containers)
- Output parsing depends on Claude Code CLI's `/usage` format — may break if Anthropic changes the output layout

---

## References

### Official Documentation
- **Claude API Documentation** — https://docs.anthropic.com
- **Claude Usage API** — https://docs.anthropic.com/en/api/usage
