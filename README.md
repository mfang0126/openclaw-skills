# OpenClaw Skills — Our Collection

40 production-ready AI agent skills, all original or meaningfully modified.

## What's In This Repo

This repo contains **only skills we created or significantly rewrote**. External/third-party skills are managed separately via ClawHub or manual install — see [EXTERNAL.md](EXTERNAL.md).

### By Category

**🌐 Web & Browser**
| Skill | Description |
|-------|-------------|
| agent-browser | Browser automation (Playwright) |
| browser-use | AI-powered browser automation CLI |
| browser-routing | Browser tool routing decision maker |
| firecrawl | Web scraping and search (Firecrawl API) |

**🧠 Research & Analysis**
| Skill | Description |
|-------|-------------|
| research-pro | Unified research (Tavily + Grok + Reddit + Firecrawl) |
| reddit | Reddit search/read CLI |
| content-research-writer | Content research + writing assistant |

**🎬 Media & Audio**
| Skill | Description |
|-------|-------------|
| douyin-dl | Douyin video downloader |
| douyin-transcript | Douyin → transcription pipeline |
| knowledge-capture | Video → transcribe → summarize → archive |
| whisper-transcribe | Speech-to-text (Groq API / whisper.cpp) |
| video-analyzer | Video content analysis |
| audio-timestamp-verifier | Verify audio timestamp accuracy (NAATI CCL) |

**💻 Development**
| Skill | Description |
|-------|-------------|
| development | Full-stack development workflow |
| python-code-review | Python code review |
| typescript-advanced-types | TypeScript advanced patterns |
| ai-sdk | Vercel AI SDK reference |
| deploy-artifact | Deploy to Vercel artifacts |
| turborepo | Turborepo monorepo guide |
| supabase-backend-platform | Supabase backend patterns |
| html-screenshot | HTML → screenshot |
| html2img | HTML → image |

**🤖 Agent Architecture**
| Skill | Description |
|-------|-------------|
| multi-agent | Multi-agent coordination |
| sub-agent-patterns | Sub-agent design patterns |
| subagent-lifecycle | Sub-agent lifecycle management |
| reflection | Agent self-reflection system |
| soul-keeper | Agent identity preservation |
| plan-mode | Structured planning workflow |

**🔧 Tools & Utilities**
| Skill | Description |
|-------|-------------|
| openclaw-config | OpenClaw config management |
| skills-watchdog | Monitor skill updates |
| safe-delete | trash instead of rm |
| calculator | Math calculations (Anthropic fork + our Examples/evals) |
| claude-usage | Claude API usage tracking (ClawHub fork, fully rewritten) |
| moonshot-usage | Moonshot API usage tracking |
| load | Agent bootstrap status check |

**📱 Content & Platform**
| Skill | Description |
|-------|-------------|
| xhs-publisher | 小红书 safe publishing pipeline |
| content-inbox | Content intake → multi-platform draft |
| email-classifier | Email classification + learning |
| platform-bridge | Cross-platform message routing |

**📋 Memory & Process**
| Skill | Description |
|-------|-------------|
| memory-audit | Memory file audit |
| reminder-cron | Cron-based reminders |

## Setup

**Existing environment:** Skills sync to `~/.openclaw/skills/` via post-commit hook automatically.

**New environment:**
```bash
git clone git@github.com:mfang0126/openclaw-skills.git
cd openclaw-skills
bash setup.sh
```

## Architecture

```
~/Code/openclaw-skills/     ← This repo (source of truth, our work only)
        │
        ├── extraDirs (live dev, lowest priority)
        │
        ├── post-commit hook → sync to managed on commit
        │
~/.openclaw/skills/          ← Runtime (mixed: ours + ClawHub + third-party)
        │
OpenClaw loads from managed (high priority) > bundled > extraDirs (low)
```

- **Our skills**: Edit in repo → commit → hook syncs to managed
- **External skills**: `openclaw skills install <slug>` → goes to managed directly
- **Bundled skills**: Ship with OpenClaw, auto-updated

## External Skills

See [EXTERNAL.md](EXTERNAL.md) for the full list of third-party skills we use but don't maintain.

## Writing Skills

See [SKILL_GUIDELINE.md](SKILL_GUIDELINE.md) and [HOW-TO-WRITE-SKILLS.md](HOW-TO-WRITE-SKILLS.md).
