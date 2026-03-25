---
name: grok-search
description: Search the web or X/Twitter using xAI Grok server-side tools (web_search, x_search) via the xAI Responses API. Use when you need tweets/threads/users from X, want Grok as an alternative to Brave, or you need structured JSON + citations.
homepage: https://docs.x.ai/docs/guides/tools/search-tools
triggers: ["grok", "xai", "search x", "search twitter", "find tweets", "x search", "twitter search", "web_search", "x_search"]
metadata: {"clawdbot":{"emoji":"🔎","requires":{"bins":["node"],"env":["XAI_API_KEY"]},"primaryEnv":"XAI_API_KEY"}}
---

## USE FOR
- "search twitter" / "find tweets about X" / "搜 X 推"
- "search X for..." / "x_search" / "xai search"
- "grok web search" / "search with grok" / "用 grok 搜"
- "find posts from @handle" / "搜推特" / "twitter search"
- Need structured JSON results with citations from web or X/Twitter
- Alternative to Brave Search with Grok as the model

## When to Use

Use when the user needs to search **X/Twitter** for tweets, threads, or user posts, or wants web search results via Grok with structured JSON + citations. Best for social listening, real-time X content, and cases where citation accuracy matters.

**Don't use when:** User just wants a general web search without needing X/Twitter content or Grok specifically — prefer Firecrawl or Brave for general browsing.

## Prerequisites

1. `XAI_API_KEY` set — check `~/.clawdbot/clawdbot.json` or env var
2. `node` installed: `node --version`
3. Skill scripts available at `{baseDir}/scripts/`

## Examples

### Example 1: Search X/Twitter for tweets

**User says:** "Find recent tweets about Claude 4"

```bash
node {baseDir}/scripts/grok_search.mjs "Claude 4 release" --x --days 7
```

**Output:**
```json
{
  "query": "Claude 4 release",
  "mode": "x",
  "results": [
    {
      "title": "@anthropic tweet",
      "url": "https://twitter.com/anthropic/status/...",
      "snippet": "Claude 4 is now available..."
    }
  ],
  "citations": ["https://twitter.com/anthropic/status/..."]
}
```

**Reply:** "Found 8 recent tweets about Claude 4. Top result: @anthropic announced..."

### Example 2: Grok web search with citations

**User says:** "Use Grok to search for the latest AI news"

```bash
node {baseDir}/scripts/grok_search.mjs "latest AI news 2025" --web --max 10
```

## Error Handling

| Error | Cause | Solution |
|-------|-------|----------|
| `XAI_API_KEY not found` | Key not configured | Add to `~/.clawdbot/clawdbot.json` → `env.XAI_API_KEY` |
| `401 Unauthorized` | Invalid API key | Verify key at console.x.ai |
| `node: command not found` | Node.js not installed | `brew install node` or `nvm install --lts` |
| `Cannot find module` | Script path wrong | Use `{baseDir}` placeholder, verify skill directory |
| Empty results | Query too narrow / X API limits | Broaden query or remove date filter |
| Rate limit / 429 | Too many requests | Wait and retry; reduce `--max` |

**Pattern: Tool Wrapper** (Google ADK) — Query → xAI Responses API → Server-side tool (web_search / x_search) → Structured JSON + citations

Run xAI Grok locally via bundled scripts (search + chat + model listing). Default output for search is *pretty JSON* (agent-friendly) with citations.

## API key

The script looks for an xAI API key in this order:
- `XAI_API_KEY` env var
- `~/.clawdbot/clawdbot.json` → `env.XAI_API_KEY`
- `~/.clawdbot/clawdbot.json` → `skills.entries["grok-search"].apiKey`
- fallback: `skills.entries["search-x"].apiKey` or `skills.entries.xai.apiKey`

## Run

Use `{baseDir}` so the command works regardless of workspace layout.

### Search

- Web search (JSON):
  - `node {baseDir}/scripts/grok_search.mjs "<query>" --web`

- X/Twitter search (JSON):
  - `node {baseDir}/scripts/grok_search.mjs "<query>" --x`

### Chat

- Chat (text):
  - `node {baseDir}/scripts/chat.mjs "<prompt>"`

- Chat (vision):
  - `node {baseDir}/scripts/chat.mjs --image /path/to/image.jpg "<prompt>"`

### Models

- List models:
  - `node {baseDir}/scripts/models.mjs`

## Useful flags

Output:
- `--links-only` print just citation URLs
- `--text` hide the citations section in pretty output
- `--raw` include the raw Responses API payload on stderr (debug)

Common:
- `--max <n>` limit results (default 8)
- `--model <id>` (default `grok-4-1-fast`)

X-only filters (server-side via x_search tool params):
- `--days <n>` (e.g. 7)
- `--from YYYY-MM-DD` / `--to YYYY-MM-DD`
- `--handles @a,@b` (limit to these handles)
- `--exclude @bots,@spam` (exclude handles)

## Output shape (JSON)

```json
{
  "query": "...",
  "mode": "web" | "x",
  "results": [
    {
      "title": "...",
      "url": "...",
      "snippet": "...",
      "author": "...",
      "posted_at": "..."
    }
  ],
  "citations": ["https://..."]
}
```

## Notes

- `citations` are merged/validated from xAI response annotations where possible (more reliable than trusting the model’s JSON blindly).
- Prefer `--x` for tweets/threads, `--web` for general research.
