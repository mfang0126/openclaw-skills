# research-pro Setup Guide

## Install

```bash
# Clone and copy research-pro (contains everything)
git clone https://github.com/mfang0126/openclaw-skills.git /tmp/oc-skills && \
cp -r /tmp/oc-skills/research-pro ~/.openclaw/skills/ && \
rm -rf /tmp/oc-skills
```

**Agent-specific install:**
```bash
cp -r research-pro ~/.openclaw/agents/<agent-id>/skills/
```

---

## Required API Keys

Add these to your OpenClaw config (`~/.openclaw/openclaw.json` → `env` section):

| Key | Used for | Required? | Get it at |
|-----|---------|-----------|-----------|
| `XAI_API_KEY` | Web search + X/Twitter (Grok) | ✅ Strongly recommended | https://console.x.ai |
| `TAVILY_API_KEY` | Tavily search/extract/crawl/research | Optional (enables Tavily tools) | https://tavily.com |
| `YOUTUBE_API_KEY` | YouTube search + metadata | Optional (yt-dlp fallback available) | https://console.cloud.google.com |
| `FIRECRAWL_API_KEY` | Firecrawl scrape/crawl/map | Optional (web_fetch fallback) | https://firecrawl.dev |
| `REDDIT_SESSION` | Reddit community search | Optional (cookie-based) | Browser DevTools → Cookies |

**Minimum setup:** Just `XAI_API_KEY` — enables web search and X/Twitter.

```json
{
  "env": {
    "XAI_API_KEY": "your-key-here",
    "TAVILY_API_KEY": "tvly-your-key-here",
    "YOUTUBE_API_KEY": "your-key-here",
    "FIRECRAWL_API_KEY": "your-key-here"
  }
}
```

---

## CLI Tool Dependencies

| Tool | Install | What it adds |
|------|---------|-------------|
| `tvly` | `curl -fsSL https://cli.tavily.com/install.sh \| bash` | Tavily search/extract/crawl/map/research |
| `firecrawl` | `npm install -g firecrawl-cli` | Web scraping with JS rendering |
| `yt-dlp` | `brew install yt-dlp` | YouTube search fallback (no API key needed) |
| `youtube-transcript-api` | `pip install youtube-transcript-api` | YouTube transcript extraction |

research-pro works with whatever tools you have installed. More tools = better results. Missing tools are skipped automatically.

---

## Verify Setup

Ask your agent:
```
"帮我查一下 Next.js 15 有什么新功能"
```

You should see it use Quick Mode and return results within 30 seconds.

---

## How It Works

research-pro is the single entry point for all search/research requests. It automatically:
1. Classifies your request (Quick / Standard / Deep / Crawl)
2. Selects the right tools
3. Returns a structured report with citations

You don't need to specify which tool to use — just ask your question.

*For detailed usage, see `SKILL.md`.*
