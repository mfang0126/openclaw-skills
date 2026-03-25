# browser-use

> AI-powered browser automation CLI. Wraps `browser-use` for autonomous agent tasks, cloud remote browsers, profile-based authenticated browsing, and parallel cloud session management.

**Pattern: Tool Wrapper** (Google ADK)

## How It Works

```
Task description
  → Choose browser mode (chromium / real / remote)
  → [real] List local Chrome profiles → user selects
  → [remote] Create or reuse cloud session
  → browser-use run "task" (async) OR manual open/state/click workflow
  → Poll task status (token-efficient by default)
  → Collect result → clean up sessions
```

## Browser Modes

| Mode | Command | Use When |
|------|---------|----------|
| Headless Chromium | `browser-use open <url>` | Default: no login state needed |
| Real Chrome (no profile) | `-b real open <url>` | Fresh Chrome binary, persistent CLI profile |
| Real Chrome (with profile) | `-b real --profile "Default" open <url>` | Reuse user's existing login sessions |
| Cloud remote | `-b remote run "task"` | AI autonomous, proxy, parallel agents |

## Core Workflows

### AI Autonomous Task (most common cloud use)
```bash
# Launch async (returns immediately)
browser-use -b remote run "Search for AI news and summarize top 3 results"
# → task_id: task-abc, session_id: sess-123

# Poll until done
browser-use task status task-abc        # minimal output (low token)
browser-use task status task-abc -c     # full reasoning (medium token)
browser-use task status task-abc -v     # all actions + URLs (high token)

# Clean up
browser-use session stop sess-123
```

### Authenticated Browsing with Real Chrome Profile
```bash
# 1. List available profiles
browser-use -b real profile list
# → Default: Person 1 (user@gmail.com)

# 2. Check what cookies it has (before syncing to cloud)
browser-use -b real profile cookies "Default"
# → github.com: 5, google.com: 18

# 3. Sync specific domain to cloud profile
browser-use profile sync --from "Default" --domain github.com

# 4. Use synced cloud profile
browser-use -b remote --profile <id> open https://github.com
```

### Parallel Cloud Agents
```bash
browser-use -b remote run "Research competitor A"   # → task-1, sess-a
browser-use -b remote run "Research competitor B"   # → task-2, sess-b
browser-use -b remote run "Research competitor C"   # → task-3, sess-c

# Monitor all
browser-use task list --status finished
browser-use session stop --all   # clean up when done
```

## Design Decisions

- **Async by default**: `browser-use -b remote run` returns immediately; poll `task status` to avoid blocking
- **Never full-profile sync without asking**: Full Chrome profile sync includes all tracking cookies and sensitive tokens — always ask which domain(s) to sync
- **`--keep-alive` for sequential tasks**: Reuse the same session for tasks that need shared state (login, cookies); otherwise each `run` gets a fresh session
- **`--last N` for long tasks**: `task status task-id --last 5` limits output to 5 steps — critical for 50+ step tasks to avoid token overflow
- **Stop tasks vs stop sessions**: `task stop` terminates work but session may linger (if `--keep-alive`); `session stop` terminates everything

## Session Lifecycle

```
session create → [run tasks] → session stop
                 ↑
         Cannot revive after stop — create new session
```

After `session stop`, the session ID is permanently dead. Do not attempt to reuse it.

## Limitations

- No video recording — use `agent-browser record` for that
- No iOS simulator support — use `agent-browser -p ios`
- No geo location spoofing in manual mode — available in remote mode via `--proxy-country`
- Cloud profile cookie sync can expire — re-sync if authentication fails on subsequent runs
- AI autonomous mode (`run "task"`) has per-task LLM cost; prefer scripted `open/state/click` for deterministic flows
- `--profile` flag works with `open`/`session create` but NOT with `run` — use `--session-id` for reusing sessions with `run`

## Related Skills

- `browser-routing` — Decide whether to use browser-use vs agent-browser vs web_fetch
- `agent-browser` — Zero-token scripted browser automation (preferred for deterministic flows)
- `browser-routing` — Always consult before starting any browser task
