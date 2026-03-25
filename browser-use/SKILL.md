---
name: browser-use
description: |
  AI-powered browser automation CLI. Use when the user needs autonomous web task execution,
  cloud browser sessions, proxy geo-routing, or multi-step browser workflows.

  USE FOR:
  - "automate this web task", "browse the web and do X", "AI agent 浏览网页"
  - "use a cloud browser", "remote browser", "proxy country", "云端浏览器"
  - "fill forms on a website", "login and do X", "extract data from site"
  - "browser agent", "autonomous web browsing", "browser-use run", "自动完成网页任务"
  - "需要代理", "proxy routing", "geo-location browser", "用英国IP访问"

  REPLACES: Manual browser interaction; use over agent-browser when AI autonomy or cloud/proxy needed

  REQUIRES:
  - browser-use CLI installed (run `browser-use doctor` to verify)
  - For real Chrome: Chrome browser installed
  - For remote/cloud: browser-use account and API access
allowed-tools: Bash(browser-use:*)
---

# Browser Automation with browser-use CLI

**Pattern: Tool Wrapper** (Google ADK)

The `browser-use` command provides fast, persistent browser automation. It maintains browser sessions across commands, enabling complex multi-step workflows.

## When to Use
Use when the user wants **AI-autonomous web task execution** (`browser-use run "task"`), needs a **cloud/remote browser**, requires **geo-proxy routing**, or wants to reuse existing Chrome profile logins. For simple scripted automation without AI, prefer `agent-browser` (lighter weight).

**Don't use when:** The user only needs to read page text (use `web_fetch`). For iOS testing or video recording, use `agent-browser` instead.

## Prerequisites

Before using this skill, `browser-use` must be installed and configured. Run diagnostics to verify:

```bash
browser-use doctor
```

For more information, see https://github.com/browser-use/browser-use/blob/main/browser_use/skill_cli/README.md

## Core Workflow

1. **Navigate**: `browser-use open <url>` - Opens URL (starts browser if needed)
2. **Inspect**: `browser-use state` - Returns clickable elements with indices
3. **Interact**: Use indices from state to interact (`browser-use click 5`, `browser-use input 3 "text"`)
4. **Verify**: `browser-use state` or `browser-use screenshot` to confirm actions
5. **Repeat**: Browser stays open between commands

## Browser Modes

```bash
browser-use --browser chromium open <url>      # Default: headless Chromium
browser-use --browser chromium --headed open <url>  # Visible Chromium window
browser-use --browser real open <url>          # Real Chrome (no profile = fresh)
browser-use --browser real --profile "Default" open <url>  # Real Chrome with your login sessions
browser-use --browser remote open <url>        # Cloud browser
```

- **chromium**: Fast, isolated, headless by default
- **real**: Uses a real Chrome binary. Without `--profile`, uses a persistent but empty CLI profile at `~/.config/browseruse/profiles/cli/`. With `--profile "ProfileName"`, copies your actual Chrome profile (cookies, logins, extensions)
- **remote**: Cloud-hosted browser with proxy support

## Essential Commands

```bash
# Navigation
browser-use open <url>                    # Navigate to URL
browser-use back                          # Go back
browser-use scroll down                   # Scroll down (--amount N for pixels)

# Page State (always run state first to get element indices)
browser-use state                         # Get URL, title, clickable elements
browser-use screenshot                    # Take screenshot (base64)
browser-use screenshot path.png           # Save screenshot to file

# Interactions (use indices from state)
browser-use click <index>                 # Click element
browser-use type "text"                   # Type into focused element
browser-use input <index> "text"          # Click element, then type
browser-use keys "Enter"                  # Send keyboard keys
browser-use select <index> "option"       # Select dropdown option

# Data Extraction
browser-use eval "document.title"         # Execute JavaScript
browser-use get text <index>              # Get element text
browser-use get html --selector "h1"      # Get scoped HTML

# Wait
browser-use wait selector "h1"            # Wait for element
browser-use wait text "Success"           # Wait for text

# Session
browser-use sessions                      # List active sessions
browser-use close                         # Close current session
browser-use close --all                   # Close all sessions

# AI Agent
browser-use -b remote run "task"          # Run agent in cloud (async by default)
browser-use task status <id>              # Check cloud task progress
```

## Commands

> Full command reference: [references/commands.md](references/commands.md)

Key commands at a glance:
```bash
browser-use open <url>              # Navigate to URL
browser-use state                   # Get clickable elements with indices
browser-use click <index>           # Click element
browser-use input <index> "text"    # Click element then type
browser-use screenshot path.png     # Save screenshot to file
browser-use -b remote run "task"    # AI agent mode (cloud)
browser-use task status <id>        # Check agent task progress
browser-use session stop --all      # Stop all cloud sessions
browser-use close --all             # Close local sessions
```

## Examples

### Example 1: AI autonomous task (cloud)
**User says:** "Go to GitHub and find the trending Python repos today"
**Steps:**
```bash
browser-use -b remote run "Go to github.com/trending?l=python and list the top 5 trending repositories with their star counts" --wait
```
**Output:** Task result with repository names and star counts
**Reply:** "Here are today's top 5 trending Python repos on GitHub: ..."

### Example 2: Scripted form fill with real Chrome profile
**User says:** "Login to my company portal and download the monthly report"
**Steps:**
```bash
browser-use -b real profile list
browser-use --browser real --profile "Default" open https://portal.company.com
browser-use state
browser-use click 3  # Click "Download Report"
browser-use wait selector ".download-complete"
```
**Output:** File downloaded to local machine
**Reply:** "Done! The monthly report has been downloaded."

## Error Handling

| Error | Cause | Solution |
|-------|-------|----------|
| `browser-use: command not found` | CLI not installed | Run `browser-use doctor` to diagnose; install per README |
| `Task stuck at "created"` | Session reuse after stop failed | Create new session: `browser-use session create --keep-alive` |
| `Element not found` | Element off-screen or dynamic | `browser-use scroll down` then re-run `browser-use state` |
| Cloud auth failure on site | Profile cookies expired | Re-sync: `browser-use profile sync --from "Default" --domain example.com` |
| `cloudflared not found` | Tunnel deps missing | Install cloudflared: `brew install cloudflare/cloudflare/cloudflared` |
| Task cost not increasing | Agent is stuck | Run `browser-use session get <id>` for live URL, then `browser-use task stop <id>` |

## Common Workflows

### Exposing Local Dev Servers

Use when you have a local dev server and need a cloud browser to reach it.

**Core workflow:** Start dev server → create tunnel → browse the tunnel URL remotely.

```bash
# 1. Start your dev server
npm run dev &  # localhost:3000

# 2. Expose it via Cloudflare tunnel
browser-use tunnel 3000
# → url: https://abc.trycloudflare.com

# 3. Now the cloud browser can reach your local server
browser-use --browser remote open https://abc.trycloudflare.com
browser-use state
browser-use screenshot
```

**Note:** Tunnels are independent of browser sessions. They persist across `browser-use close` and can be managed separately. Cloudflared must be installed — run `browser-use doctor` to check.

### Authenticated Browsing with Profiles

Use when a task requires browsing a site the user is already logged into (e.g. Gmail, GitHub, internal tools).

**Core workflow:** Check existing profiles → ask user which profile and browser mode → browse with that profile. Only sync cookies if no suitable profile exists.

**Before browsing an authenticated site, the agent MUST:**
1. Ask the user whether to use **real** (local Chrome) or **remote** (cloud) browser
2. List available profiles for that mode
3. Ask which profile to use
4. If no profile has the right cookies, offer to sync (see below)

#### Step 1: Check existing profiles

```bash
# Option A: Local Chrome profiles (--browser real)
browser-use -b real profile list
# → Default: Person 1 (user@gmail.com)
# → Profile 1: Work (work@company.com)

# Option B: Cloud profiles (--browser remote)
browser-use -b remote profile list
# → abc-123: "Chrome - Default (github.com)"
# → def-456: "Work profile"
```

#### Step 2: Browse with the chosen profile

```bash
# Real browser — uses local Chrome with existing login sessions
browser-use --browser real --profile "Default" open https://github.com

# Cloud browser — uses cloud profile with synced cookies
browser-use --browser remote --profile abc-123 open https://github.com
```

The user is already authenticated — no login needed.

**Note:** Cloud profile cookies can expire over time. If authentication fails, re-sync cookies from the local Chrome profile.

#### Step 3: Syncing cookies (only if needed)

If the user wants to use a cloud browser but no cloud profile has the right cookies, sync them from a local Chrome profile.

**Before syncing, the agent MUST:**
1. Ask which local Chrome profile to use
2. Ask which domain(s) to sync — do NOT default to syncing the full profile
3. Confirm before proceeding

**Check what cookies a local profile has:**
```bash
browser-use -b real profile cookies "Default"
# → youtube.com: 23
# → google.com: 18
# → github.com: 2
```

**Domain-specific sync (recommended):**
```bash
browser-use profile sync --from "Default" --domain github.com
# Creates new cloud profile: "Chrome - Default (github.com)"
# Only syncs github.com cookies
```

**Full profile sync (use with caution):**
```bash
browser-use profile sync --from "Default"
# Syncs ALL cookies — includes sensitive data, tracking cookies, every session token
```
Only use when the user explicitly needs their entire browser state.

**Fine-grained control (advanced):**
```bash
# Export cookies to file, manually edit, then import
browser-use --browser real --profile "Default" cookies export /tmp/cookies.json
browser-use --browser remote --profile <id> cookies import /tmp/cookies.json
```

**Use the synced profile:**
```bash
browser-use --browser remote --profile <id> open https://github.com
```

### Running Subagents

Use cloud sessions to run autonomous browser agents in parallel.

**Core workflow:** Launch task(s) with `run` → poll with `task status` → collect results → clean up sessions.

- **Session = Agent**: Each cloud session is a browser agent with its own state
- **Task = Work**: Jobs given to an agent; an agent can run multiple tasks sequentially
- **Session lifecycle**: Once stopped, a session cannot be revived — start a new one

#### Launching Tasks

```bash
# Single task (async by default — returns immediately)
browser-use -b remote run "Search for AI news and summarize top 3 articles"
# → task_id: task-abc, session_id: sess-123

# Parallel tasks — each gets its own session
browser-use -b remote run "Research competitor A pricing"
# → task_id: task-1, session_id: sess-a
browser-use -b remote run "Research competitor B pricing"
# → task_id: task-2, session_id: sess-b
browser-use -b remote run "Research competitor C pricing"
# → task_id: task-3, session_id: sess-c

# Sequential tasks in same session (reuses cookies, login state, etc.)
browser-use -b remote run "Log into example.com" --keep-alive
# → task_id: task-1, session_id: sess-123
browser-use task status task-1  # Wait for completion
browser-use -b remote run "Export settings" --session-id sess-123
# → task_id: task-2, session_id: sess-123 (same session)
```

#### Managing & Stopping

```bash
browser-use task list --status finished      # See completed tasks
browser-use task stop task-abc               # Stop a task (session may continue if --keep-alive)
browser-use session stop sess-123            # Stop an entire session (terminates its tasks)
browser-use session stop --all               # Stop all sessions
```

#### Monitoring

**Task status is designed for token efficiency.** Default output is minimal — only expand when needed:

| Mode | Flag | Tokens | Use When |
|------|------|--------|----------|
| Default | (none) | Low | Polling progress |
| Compact | `-c` | Medium | Need full reasoning |
| Verbose | `-v` | High | Debugging actions |

```bash
# For long tasks (50+ steps)
browser-use task status <id> -c --last 5   # Last 5 steps only
browser-use task status <id> -v --step 10  # Inspect specific step
```

**Live view**: `browser-use session get <session-id>` returns a live URL to watch the agent.

**Detect stuck tasks**: If cost/duration in `task status` stops increasing, the task is stuck — stop it and start a new agent.

**Logs**: `browser-use task logs <task-id>` — only available after task completes.

## Global Options

| Option | Description |
|--------|-------------|
| `--session NAME` | Use named session (default: "default") |
| `--browser MODE` | Browser mode: chromium, real, remote |
| `--headed` | Show browser window (chromium mode) |
| `--profile NAME` | Browser profile (local name or cloud ID). Works with `open`, `session create`, etc. — does NOT work with `run` (use `--session-id` instead) |
| `--json` | Output as JSON |
| `--mcp` | Run as MCP server via stdin/stdout |

**Session behavior**: All commands without `--session` use the same "default" session. The browser stays open and is reused across commands. Use `--session NAME` to run multiple browsers in parallel.

## Tips

1. **Always run `browser-use state` first** to see available elements and their indices
2. **Use `--headed` for debugging** to see what the browser is doing
3. **Sessions persist** — the browser stays open between commands
4. **Use `--json`** for programmatic parsing
5. **Python variables persist** across `browser-use python` commands within a session
6. **CLI aliases**: `bu`, `browser`, and `browseruse` all work identically to `browser-use`

## Troubleshooting

**Run diagnostics first:**
```bash
browser-use doctor
```

**Browser won't start?**
```bash
browser-use close --all               # Close all sessions
browser-use --headed open <url>       # Try with visible window
```

**Element not found?**
```bash
browser-use state                     # Check current elements
browser-use scroll down               # Element might be below fold
browser-use state                     # Check again
```

**Session issues?**
```bash
browser-use sessions                  # Check active sessions
browser-use close --all               # Clean slate
browser-use open <url>                # Fresh start
```

**Session reuse fails after `task stop`**:
If you stop a task and try to reuse its session, the new task may get stuck at "created" status. Create a new session instead:
```bash
browser-use session create --profile <profile-id> --keep-alive
browser-use -b remote run "new task" --session-id <new-session-id>
```

**Task stuck at "started"**: Check cost with `task status` — if not increasing, the task is stuck. View live URL with `session get`, then stop and start a new agent.

**Sessions persist after tasks complete**: Tasks finishing doesn't auto-stop sessions. Run `browser-use session stop --all` to clean up.

## Cleanup

**Always close the browser when done:**

```bash
browser-use close                     # Close browser session
browser-use session stop --all        # Stop cloud sessions (if any)
browser-use tunnel stop --all         # Stop tunnels (if any)
```
