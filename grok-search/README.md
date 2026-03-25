# grok-search

> Search the web or X/Twitter using xAI Grok's server-side tools via the xAI Responses API. Returns structured JSON with citations.

## Pattern: Tool Wrapper

This skill follows the **Tool Wrapper** pattern (Google ADK). Rather than embedding knowledge in the system prompt, it delegates search at runtime to xAI's server-side `web_search` and `x_search` tools — loading only what's needed, when it's needed.

## How It Works

```
User query + mode flag (--web | --x)
  → Load API key (env → clawdbot.json → fallback entries)
  → Build xAI Responses API request with server-side tool
  → Grok executes tool server-side (web or X search)
  → Parse response: extract results + annotations (citations)
  → Output: pretty JSON (default) | links-only | raw
```

The script never scrapes directly — it asks Grok to run `web_search` or `x_search` server-side, then parses Grok's response annotations to produce a reliable citation list. This avoids the classic problem of trusting the model's own JSON verbatim when it might hallucinate URLs.

## Design Decisions

### Why xAI Responses API instead of Chat Completions?
The Responses API supports structured tool output with annotations (citation metadata). The Chat Completions endpoint returns plain text — citations would require fragile regex parsing.

### Why parse annotations separately from the model JSON?
Grok may generate plausible-looking but incorrect URLs in its JSON summary. Annotations come from the actual tool execution and are structurally more reliable. The script merges both: model JSON for titles/snippets, annotation URLs to validate/supplement citations.

### Why Node.js (ESM) instead of shell/Python?
The xAI API uses a non-trivial streaming + annotation model. Node's `fetch` + native JSON handling makes this simpler than Python `requests` or curl, without pulling in heavy dependencies.

### Why `--web` and `--x` as explicit flags?
Search intent is fundamentally different: `--web` targets the open web; `--x` targets posts, threads, and users on X. Forcing explicit mode avoids silent mode selection that surprises users.

## Scripts

| Script | Purpose |
|--------|---------|
| `grok_search.mjs` | Core search (web + X/Twitter), JSON output |
| `chat.mjs` | General Grok chat, text/vision |
| `models.mjs` | List available xAI models |
| `selftest.mjs` | Quick self-test (fires a real search, checks output shape) |

## Supported Inputs

| Flag | Purpose | Example |
|------|---------|---------|
| `--web` | Web search | `--web "latest AI news"` |
| `--x` | X/Twitter search | `--x "OpenAI announcements"` |
| `--links-only` | Print only citation URLs | |
| `--text` | Hide citations in output | |
| `--raw` | Dump raw API payload to stderr | |
| `--max <n>` | Limit result count (default: 8) | `--max 5` |
| `--model <id>` | Override model (default: `grok-4-1-fast`) | `--model grok-3` |
| `--days <n>` | X only: last N days | `--days 7` |
| `--from YYYY-MM-DD` | X only: date range start | |
| `--to YYYY-MM-DD` | X only: date range end | |
| `--handles @a,@b` | X only: restrict to these handles | |
| `--exclude @x,@y` | X only: exclude these handles | |

## Output Format

Default output is pretty JSON (agent-friendly):

```json
{
  "query": "Claude 4 release",
  "mode": "web",
  "results": [
    {
      "title": "Anthropic Releases Claude 4",
      "url": "https://anthropic.com/...",
      "snippet": "...",
      "author": null,
      "posted_at": null
    }
  ],
  "citations": ["https://anthropic.com/..."]
}
```

For X searches, `author` and `posted_at` are populated from the tweet metadata when available.

## API Key Resolution

The script tries API key sources in this order:

1. `XAI_API_KEY` environment variable
2. `~/.clawdbot/clawdbot.json` → `env.XAI_API_KEY`
3. `~/.clawdbot/clawdbot.json` → `skills.entries["grok-search"].apiKey`
4. `~/.clawdbot/clawdbot.json` → `skills.entries["search-x"].apiKey` or `.xai.apiKey`

## Limitations

- **Requires `XAI_API_KEY`**: No key = immediate auth error. Free-tier keys have rate limits.
- **X search coverage**: Only public posts. Protected accounts, DMs, and deleted tweets are not accessible.
- **No streaming output**: The script waits for the full response before printing. Large result sets may take 3–8 seconds.
- **Model availability**: `grok-4-1-fast` is the default; heavier models cost more tokens and are slower.
- **Date filters are X-only**: `--from`, `--to`, `--days` are ignored for `--web` mode (xAI does not expose web date filters via this API).

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `brave-search` | When you want Brave's index without an xAI key |
| `html2img` | Rendering search results as an image |
| `agent-browser` | Interactive browsing / form filling (uses more tokens) |
| `snap` | Screenshot a specific URL (not search) |
