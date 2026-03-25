# OpenClaw Skills Collection

A curated collection of AI agent skills for [OpenClaw](https://github.com/openclaw/openclaw) — the open-source personal AI assistant.

## What are Skills?

Skills are plug-and-play knowledge modules that teach your AI agent **how** to do things. When you ask your agent to "take a screenshot of this website" or "set up Supabase auth", the right skill activates automatically based on your request.

Each skill contains:
- **SKILL.md** — Instructions, examples, and error handling
- **scripts/** — Executable scripts the agent can run
- **references/** — Deep-dive documentation loaded on demand
- **evals/** — Test cases to validate the skill works

## Quick Setup

### 1. Install OpenClaw

```bash
# macOS
brew install openclaw

# Or from source
git clone https://github.com/openclaw/openclaw.git
cd openclaw && npm install && npm link
```

### 2. Add Skills

**Option A: Clone this repo into your skills directory**
```bash
git clone https://github.com/mfang0126/openclaw-skills.git ~/.openclaw/skills
```

**Option B: Install individual skills from ClawHub marketplace**
```bash
openclaw skill install show-my-ip
openclaw skill install mermaid-architect
```

### 3. Verify

```bash
# List installed skills
ls ~/.openclaw/skills/

# Check a specific skill
cat ~/.openclaw/skills/agent-browser/SKILL.md | head -20
```

Skills are auto-detected by OpenClaw — no additional configuration needed. Just ask your agent something that matches a skill's trigger phrases.

## Skills Catalog

### 🌐 Web & Browser

| Skill | Description | Pattern |
|-------|-------------|---------|
| [agent-browser](agent-browser/) | Browser automation — navigate, click, fill forms, screenshot | Tool Wrapper |
| [browser-use](browser-use/) | AI-powered autonomous browser tasks | Tool Wrapper |
| [browser-routing](browser-routing/) | Smart routing between browser tools (zero-token vs full) | Inversion |
| [firecrawl](firecrawl/) | Web scraping with LLM-optimized markdown output | Tool Wrapper |
| [snap](snap/) | Instant website screenshots via API | Tool Wrapper |
| [html-screenshot](html-screenshot/) | Screenshot HTML files or URLs | Tool Wrapper |
| [html2img](html2img/) | Convert HTML/Markdown to PNG images | Pipeline |
| [show-my-ip](show-my-ip/) | Get your public IP address | Tool Wrapper |

### 🛠️ Development

| Skill | Description | Pattern |
|-------|-------------|---------|
| [development](development/) | Full-stack development workflow | Pipeline |
| [nextjs-best-practices](nextjs-best-practices/) | Next.js App Router patterns and conventions | Tool Wrapper |
| [nextjs-supabase-auth](nextjs-supabase-auth/) | Supabase auth setup in Next.js | Tool Wrapper |
| [typescript-advanced-types](typescript-advanced-types/) | Advanced TypeScript type patterns | Tool Wrapper |
| [turborepo](turborepo/) | Turborepo monorepo configuration | Tool Wrapper |
| [python-code-review](python-code-review/) | Python code quality review | Reviewer |
| [ai-sdk](ai-sdk/) | Vercel AI SDK integration guide | Tool Wrapper |
| [supabase-backend-platform](supabase-backend-platform/) | Supabase backend patterns (auth, RLS, queries) | Tool Wrapper |
| [supabase-postgres-best-practices](supabase-postgres-best-practices/) | PostgreSQL optimization for Supabase | Tool Wrapper |
| [mastra](mastra/) | Mastra AI framework integration | Tool Wrapper |

### 🚀 Deployment & DevOps

| Skill | Description | Pattern |
|-------|-------------|---------|
| [deploy-artifact](deploy-artifact/) | Deploy files to Vercel artifacts | Tool Wrapper |
| [wordpress-cli](wordpress-cli/) | Publish Markdown to WordPress | Tool Wrapper |
| [vercel](vercel/) | Vercel CLI operations | Tool Wrapper |
| [tailscale](tailscale/) | Tailscale VPN management | Tool Wrapper |

### 🤖 Agent Management

| Skill | Description | Pattern |
|-------|-------------|---------|
| [sub-agent-patterns](sub-agent-patterns/) | Multi-agent orchestration patterns | Tool Wrapper |
| [multi-agent](multi-agent/) | Parallel agent coordination | Pipeline |
| [plan-mode](plan-mode/) | Task planning before execution | Pipeline |
| [skill-creator](skill-creator/) | Create and improve skills | Pipeline |
| [soul-keeper](soul-keeper/) | Monitor and optimize workspace files | Reviewer |
| [memory-audit](memory-audit/) | Audit memory quality and consistency | Reviewer |
| [reflection](reflection/) | Self-reflection and improvement | Pipeline |
| [self-improving](self-improving/) | Continuous learning from corrections | Tool Wrapper |
| [skills-watchdog](skills-watchdog/) | Check skills for updates | Tool Wrapper |
| [openclaw-config](openclaw-config/) | Safe openclaw.json editing rules | Tool Wrapper |
| [platform-bridge](platform-bridge/) | Cross-platform message adaptation | Tool Wrapper |

### 📝 Content & Media

| Skill | Description | Pattern |
|-------|-------------|---------|
| [content-research-writer](content-research-writer/) | Research-backed content writing | Pipeline |
| [content-inbox](content-inbox/) | Unified content management (Douyin/WeChat/etc.) | Pipeline |
| [newsletter-assistant](newsletter-assistant/) | Newsletter email processing | Pipeline |
| [video-analyzer](video-analyzer/) | Video transcription and analysis | Pipeline |
| [douyin-dl](douyin-dl/) | Download Douyin videos without watermarks | Tool Wrapper |
| [demo-video](demo-video/) | Record demo videos | Tool Wrapper |
| [ffmpeg-cli](ffmpeg-cli/) | FFmpeg media operations | Tool Wrapper |
| [mermaid-architect](mermaid-architect/) | Generate Mermaid diagrams | Generator |

### 📊 API & Search

| Skill | Description | Pattern |
|-------|-------------|---------|
| [grok-search](grok-search/) | xAI Grok web search | Tool Wrapper |
| [moonshot-usage](moonshot-usage/) | Moonshot AI API usage tracking | Tool Wrapper |
| [claude-usage](claude-usage/) | Claude subscription quota checker | Tool Wrapper |
| [nano-banana-pro-2](nano-banana-pro-2/) | Google AI image generation | Tool Wrapper |

### 📄 Document Processing

| Skill | Description | Pattern |
|-------|-------------|---------|
| [docx](docx/) | Word document manipulation | Tool Wrapper |
| [pdf](pdf/) | PDF form filling and extraction | Tool Wrapper |
| [seo](seo/) | SEO analysis and optimization | Tool Wrapper |

### 🔊 Audio

| Skill | Description | Pattern |
|-------|-------------|---------|
| [audio-timestamp-verifier](audio-timestamp-verifier/) | Verify audio timestamp accuracy | Reviewer |

## Skill Architecture

Every skill follows the [SKILL_GUIDELINE](https://github.com/mfang0126/openclaw-skills/blob/main/SKILL_GUIDELINE.md) standard:

### Required Sections in SKILL.md

1. **USE FOR** — Trigger phrases (bilingual CN/EN)
2. **When to Use** — Positive + "Don't use when" negative
3. **Prerequisites** — Dependencies and setup
4. **Quick Start** — Most common usage
5. **Examples** — `User says → Steps → Output → Reply`
6. **Error Handling** — Table with Error | Cause | Solution
7. **Pattern** — One of 5 Google ADK patterns

### Five Patterns

| Pattern | Use For | Example |
|---------|---------|---------|
| **Tool Wrapper** | Wrapping a CLI/API tool | agent-browser, firecrawl |
| **Pipeline** | Multi-step workflows | development, content-research-writer |
| **Reviewer** | Quality checking | python-code-review, memory-audit |
| **Generator** | Creating artifacts | mermaid-architect |
| **Inversion** | Routing/decision logic | browser-routing |

### Progressive Disclosure

Skills use a layered loading strategy to save tokens:

```
SKILL.md (≤500 lines)     ← Always loaded. Decision logic + common commands
└── references/            ← Loaded on demand. Deep documentation
    ├── commands.md
    ├── authentication.md
    └── troubleshooting.md
```

## Creating Your Own Skills

```bash
# Use the skill-creator skill
# Ask your agent: "Create a new skill for [your tool]"

# Or manually:
mkdir -p ~/.openclaw/skills/my-skill/{scripts,references,evals}

# Required files:
# - SKILL.md (main instructions)
# - _meta.json (metadata)
# - README.md (human docs)
# - evals/evals.json (test cases)
```

See [skill-creator/SKILL.md](skill-creator/SKILL.md) for the full creation workflow.

## Additional Documentation

| Document | Description |
|----------|-------------|
| [SKILL_GUIDELINE.md](SKILL_GUIDELINE.md) | Formal standard — 7 required sections, 5 patterns, Progressive Disclosure |
| [HOW-TO-WRITE-SKILLS.md](HOW-TO-WRITE-SKILLS.md) | Practical playbook — Google ADK patterns, step-by-step writing guide |
| [AGENT-MAINTENANCE-SYSTEM.md](AGENT-MAINTENANCE-SYSTEM.md) | Four-skill self-maintenance system (self-improving, reflection, soul-keeper, skills-watchdog) |
| [README-legacy.md](README-legacy.md) | Original architecture notes — research-pro routing, design principles |

## Contributing

1. Fork this repo
2. Create your skill following the [SKILL_GUIDELINE](SKILL_GUIDELINE.md)
3. Run the eval: `cat your-skill/evals/evals.json`
4. Submit a PR

## License

Individual skills may have their own licenses (see each skill's README). The collection itself is MIT licensed.
