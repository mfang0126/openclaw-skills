# Firecrawl Skill

> **Pattern: Tool Wrapper** — Injects Firecrawl CLI knowledge on demand for any web/search task.

Firecrawl is a purpose-built web intelligence layer for AI agents. It replaces all built-in web tools (WebFetch, WebSearch, browser automation) with a single, consistent CLI that returns LLM-optimized markdown output.

---

## How It Works

This skill follows the **Tool Wrapper** pattern (Google ADK). Instead of hardcoding web-fetching knowledge into the system prompt, this skill is loaded on demand whenever a web/search task is detected.

```
User asks for web info
  → Skill triggers (Tool Wrapper)
  → SKILL.md loaded into context
  → Agent uses firecrawl CLI for all web ops
  → Results saved to .firecrawl/ (never flood context)
  → Agent reads output selectively (grep/jq/head)
```

No scripts to run — Firecrawl is a first-class CLI tool. The skill teaches the agent **when and how** to use it correctly.

---

## Why Firecrawl Over Built-in Tools?

| Feature | WebFetch / WebSearch | Firecrawl |
|---------|---------------------|-----------|
| JavaScript rendering | ❌ | ✅ |
| Anti-bot bypass | ❌ | ✅ |
| LLM-optimized output | ❌ | ✅ |
| Parallel scraping | ❌ | ✅ |
| Image/news/web search | Partial | ✅ All sources |
| File output (no context flood) | ❌ | ✅ `-o` flag |
| Site mapping | ❌ | ✅ |
| Category filtering (GitHub, research, PDFs) | ❌ | ✅ |

---

## Supported Operations

### Search
Web, news, and image search with optional inline scraping. Supports time filters, geo-targeting, category filtering (GitHub repos, research papers, PDFs).

```bash
firecrawl search "your query" --json -o .firecrawl/search-query.json
firecrawl search "AI news" --sources news --tbs qdr:d --json -o .firecrawl/search-news.json
firecrawl search "pytorch docs" --categories research --scrape -o .firecrawl/search-pytorch.json
```

### Scrape
Single-page extraction with full JavaScript support. Returns clean markdown, HTML, links, or screenshots.

```bash
firecrawl scrape 'https://example.com' -o .firecrawl/example.md
firecrawl scrape 'https://spa-app.com' --wait-for 3000 --only-main-content -o .firecrawl/spa.md
firecrawl scrape 'https://example.com' --format markdown,links -o .firecrawl/example.json
```

### Map
Discover all URLs on a site. Useful for bulk scraping or understanding site structure.

```bash
firecrawl map 'https://docs.example.com' -o .firecrawl/urls.txt
firecrawl map 'https://example.com' --search "pricing" -o .firecrawl/pricing-urls.txt
```

---

## File Organization

All output goes to `.firecrawl/` in the working directory. This keeps large pages out of the LLM context window.

```
.firecrawl/
├── search-react-hooks.json          # Search results
├── search-ai-news-scraped.json      # Search + scrape
├── docs.github.com-actions.md       # Scraped page
├── openai.com-blog-urls.txt         # Site map
└── scratchpad/                      # Temp scripts for bulk ops
    └── bulk-scrape.sh
```

**Naming convention:**
- Search: `search-{query-slug}.json`
- Scrape: `{domain}-{path-slug}.md`
- Map: `{domain}-urls.txt`

---

## Parallelization

Always scrape multiple URLs in parallel. Check `firecrawl --status` for the current concurrency limit first.

```bash
firecrawl --status   # Check concurrency limit and credits

# Parallel scrape (fast)
firecrawl scrape 'https://site1.com' -o .firecrawl/1.md &
firecrawl scrape 'https://site2.com' -o .firecrawl/2.md &
firecrawl scrape 'https://site3.com' -o .firecrawl/3.md &
wait
```

For large batches, use `xargs -P`:
```bash
cat urls.txt | xargs -P 10 -I {} sh -c 'firecrawl scrape "{}" -o ".firecrawl/$(echo {} | md5).md"'
```

---

## Reading Output Efficiently

Firecrawl output files can be 1000+ lines. Never read them wholesale.

```bash
# Check size and preview
wc -l .firecrawl/file.md && head -50 .firecrawl/file.md

# Find specific content
grep -n "pricing" .firecrawl/file.md
grep -A 10 "## Installation" .firecrawl/file.md

# Parse JSON results
jq -r '.data.web[] | "\(.title): \(.url)"' .firecrawl/search-query.json
jq -r '.data.news[].title' .firecrawl/search-news.json
```

---

## Design Decisions

### Why Tool Wrapper (not Pipeline)?
Firecrawl covers a wide surface area — search, scrape, map, crawl. A Pipeline pattern would constrain this into rigid steps. Tool Wrapper is the right fit: load the knowledge when needed, let the agent decide which command to run based on context.

### Why write to files with `-o`?
Scraped web pages routinely exceed 5,000 tokens. Printing to stdout floods the context window and wastes tokens. Writing to `.firecrawl/` and reading selectively (grep, jq, head) is far more efficient.

### Why replace WebFetch and WebSearch entirely?
Firecrawl handles JS rendering, anti-bot measures, and returns markdown instead of raw HTML. Built-in tools fail silently on dynamic sites and return noisy HTML that wastes context. Firecrawl is strictly superior for agent use.

### Why always quote URLs?
Shell interprets `?` and `&` in URLs as special characters. Unquoted URLs silently break — quoting prevents this.

---

## Authentication

Firecrawl requires an API key. Check status:

```bash
firecrawl --status
```

If not authenticated:
```bash
firecrawl login --browser
```

See [`rules/install.md`](rules/install.md) for full installation and auth setup.

---

## Limitations

- **Credits-based**: Each scrape/crawl consumes API credits. Check `firecrawl --status` before bulk operations.
- **Not for real-time interaction**: Firecrawl is a fetch tool, not a browser automation tool. For interactive browsing (clicking, form submission), use `agent-browser`.
- **Rate limits**: Parallel concurrency is capped. Check `--status` Concurrency field.
- **No cookie/session support**: Firecrawl scrapes public content. Authenticated pages (behind login) may not be accessible without additional configuration.

---

## Related Skills

| Skill | When to Use Instead |
|-------|-------------------|
| `agent-browser` | Interactive browsing: clicking, login, form submission |
| `snap` | Cloud screenshot from a public URL (needs API key) |
| `html2img` | Render local HTML/Markdown to PNG (no network) |
