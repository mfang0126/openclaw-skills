# browser-routing

> Unified decision layer for browser tool selection. Run this before any web task to pick the lowest-cost, highest-reliability tool.

**Pattern: Inversion** (Google ADK)

## How It Works

Three browser tools overlap significantly. Without a routing layer, agents default to the wrong tool — wasting tokens on screenshots, launching heavy browsers for simple reads, or missing exclusive capabilities.

```
Any web task request
  → Collect: task type + login needed? + token budget?
  → Apply decision tree (9 branches, 5 seconds)
  → Route to: web_fetch / agent-browser / browser-use / browser (built-in)
```

The pattern is **Inversion**: ask first, act second. Never start a browser task without knowing which tool to use and why.

## The Decision Tree

```
1. Text-only read?           → web_fetch (zero tokens, zero browser)
2. User's existing logins?   → browser profile="user"  (GSC, Gmail, etc.)
3. OpenClaw cookies?         → browser built-in
4. localhost?                → agent-browser
5. AI autonomous task?       → browser-use run "task"
6. Proxy/country spoofing?   → browser-use -b remote --proxy-country
7. Video recording?          → agent-browser record
8. iOS testing?              → agent-browser -p ios
9. Everything else           → agent-browser (default)
```

## Token Cost Ranking (ascending)

| Rank | Tool | Token Cost |
|------|------|-----------|
| 1 | `web_fetch` | Zero |
| 2 | `web_search` | Zero |
| 3 | `agent-browser snapshot -i` | Zero (text DOM) |
| 4 | `agent-browser` interactions | Zero |
| 5 | `agent-browser screenshot` → file | Zero (not in context) |
| 6 | `browser snapshot` | Zero |
| 7 | `browser act` | Zero |
| 8 | `snap` API | Zero |
| 9 | `firecrawl` | Near-zero |
| 10 | `browser screenshot` | **HIGH** (image in context) |

## Design Decisions

- **web_fetch first**: Most "look at this page" requests only need markdown text. No browser needed.
- **screenshot is last resort**: `browser screenshot` injects an image into context, consuming significant tokens. Use only when visual layout is the actual question.
- **Exclusive capabilities drive hard choices**: If you need video recording, iOS, or geo spoofing — only `agent-browser` works. If you need AI autonomous mode or remote cloud — only `browser-use`.
- **Don't screenshot to check login**: Check the URL for `/login` redirect, or use `snapshot -i` to read the DOM.

## Common Anti-Patterns

| ❌ Wrong | ✅ Right |
|---------|---------|
| Screenshot to read pricing text | `web_fetch` → markdown |
| Screenshot to check if logged in | Check URL or `snapshot -i` |
| `browser screenshot` → send to user | `agent-browser screenshot out.png` → `message send media=out.png` |
| `browser-use` for simple form fill | `agent-browser` (zero-token, more reliable for scripted flows) |

## Limitations

- Routing heuristics cannot replace judgment for ambiguous tasks — when unsure, ask the user
- `browser` built-in is the **only** tool with access to OpenClaw's persisted cookie store
- `browser-use` AI autonomous mode has higher per-task cost (external LLM call) — prefer scripted `agent-browser` for deterministic flows
- `web_fetch` fails on JS-rendered pages; detect by checking if returned markdown is empty/minimal

## Related Skills

- `agent-browser` — Default choice for zero-token browser automation
- `browser-use` — AI autonomous agent + cloud remote browser
- `html2img` — Convert static HTML/Markdown to image (no live browser needed)
