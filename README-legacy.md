# openclaw-skills

Ming's curated OpenClaw skills — production-tested, conflict-free.

## Architecture

All search/research requests go through `research-pro` as the single entry point.
Other tools (grok-search, tavily-search, firecrawl, etc.) are called internally — not triggered directly.

## Skills

| Skill | Description |
|-------|-------------|
| `research-pro` | Unified research entry point — auto-selects tools (Grok/Tavily/Reddit/YouTube/Firecrawl) |
| `skills-watchdog` | Daily version checker for all managed skills |
| `grok-search` | Web + X/Twitter search via xAI Grok API |
| `reddit-cli` | Reddit search and post reader |
| `youtube` | YouTube video search + transcript |
| `grokipedia` | Grokipedia encyclopedia search |
| `firecrawl` | Scrape specific URLs (JS rendering, bypass blocks) |
| `tavily-search` | Structured web search with relevance scores |
| `calculator` | Precise math calculations |
| `plan-mode` | Analysis-only mode, no execution |
| `soul-keeper` | Workspace file health monitor |
| `mermaid-architect` | Generate and render Mermaid diagrams |
| `show-my-ip` | Show public IP address |
| `self-improving` | Learn from corrections, permanent memory |
| `self-reflection` | Structured reflection and improvement |

## Design Principles

Based on [Google ADK 5 Skill Patterns](https://x.com/GoogleCloudTech/status/2033953579824758855):
- **Pipeline** — research-pro orchestrates multi-step research flows
- **Tool Wrapper** — tools loaded on-demand, not always-on
- **Reviewer** — skills-watchdog checks versions on schedule

## Maintenance

`skills-watchdog` runs daily at 9AM Sydney time. Updates are notified via Discord.

Last updated: 2026-03-22
