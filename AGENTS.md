# AGENTS.md

40 original AI agent skills for [OpenClaw](https://github.com/openclaw/openclaw).

This repo contains only skills we created or significantly modified. For external/third-party skills, see [EXTERNAL.md](EXTERNAL.md).

## Structure

```
skills/
├── AGENTS.md              ← You are here (agent entry point)
├── README.md              ← Human-readable docs
├── EXTERNAL.md            ← External dependencies list
├── setup.sh               ← New environment bootstrap
├── SKILL_GUIDELINE.md     ← How to write a skill
├── <skill-name>/
│   ├── SKILL.md           ← Main instructions (read this first)
│   ├── scripts/           ← Executable scripts (if any)
│   ├── references/        ← Deep docs (load on demand)
│   └── evals/             ← Test cases
```

## How to Find a Skill

1. Read the table below
2. Open `<skill-name>/SKILL.md` for full instructions
3. Load `references/` only when you need deeper context

## All Skills

| Skill | Description |
|-------|-------------|
| agent-browser | Browser automation CLI (Playwright) |
| ai-sdk | Vercel AI SDK reference |
| audio-timestamp-verifier | Verify audio timestamp accuracy (NAATI CCL) |
| browser-routing | Browser tool routing decision maker |
| browser-use | AI-powered browser automation CLI |
| calculator | Math calculations (Anthropic fork + Examples/evals) |
| claude-usage | Claude API usage tracking (fully rewritten) |
| content-inbox | Content intake → multi-platform draft |
| content-research-writer | Content research + writing assistant |
| deploy-artifact | Deploy files to Vercel artifacts |
| development | Full-stack development workflow |
| douyin-dl | Douyin video downloader |
| douyin-transcript | Douyin → transcription pipeline |
| email-classifier | Email classification + learning |
| firecrawl | Web scraping and search (Firecrawl API) |
| html-screenshot | HTML → screenshot |
| html2img | HTML/Markdown → PNG |
| knowledge-capture | Video → transcribe → summarize → archive |
| load | Agent bootstrap status check |
| memory-audit | Memory file audit |
| moonshot-usage | Moonshot API usage tracking |
| multi-agent | Multi-agent coordination |
| openclaw-config | OpenClaw config management |
| plan-mode | Structured planning workflow |
| platform-bridge | Cross-platform message routing |
| python-code-review | Python code review |
| reddit | Reddit search/read CLI |
| reflection | Agent self-reflection system |
| research-pro | Unified research (Tavily + Grok + Reddit + Firecrawl) |
| safe-delete | trash instead of rm |
| skills-watchdog | Monitor skill updates |
| soul-keeper | Agent identity preservation |
| sub-agent-patterns | Sub-agent design patterns |
| subagent-lifecycle | Sub-agent lifecycle management |
| supabase-backend-platform | Supabase backend patterns |
| turborepo | Turborepo monorepo guide |
| typescript-advanced-types | TypeScript advanced patterns |
| video-analyzer | Video content analysis |
| whisper-transcribe | Speech-to-text (Groq API / whisper.cpp) |
| xhs-publisher | 小红书 safe publishing pipeline |
