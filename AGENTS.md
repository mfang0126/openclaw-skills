# AGENTS.md

A curated collection of 45 AI agent skills for [OpenClaw](https://github.com/openclaw/openclaw).

## Structure

```
skills/
├── AGENTS.md              ← You are here (agent entry point)
├── README.md              ← Human-readable docs
├── SKILL_GUIDELINE.md     ← How to write a skill (7 sections, 5 patterns)
├── HOW-TO-WRITE-SKILLS.md ← Practical writing guide
├── <skill-name>/
│   ├── SKILL.md           ← Main instructions (always read this first)
│   ├── scripts/           ← Executable scripts
│   ├── references/        ← Deep docs (load on demand, not upfront)
│   └── evals/             ← Test cases
```

## How to Find a Skill

Each folder = one skill. Read `<skill-name>/SKILL.md` for instructions.

### By Category

**Web & Browser**
agent-browser, browser-use, browser-routing, firecrawl, snap, html-screenshot, html2img, show-my-ip

**Development**
development, nextjs-best-practices, nextjs-supabase-auth, typescript-advanced-types, turborepo, python-code-review, ai-sdk, supabase-backend-platform, supabase-postgres-best-practices, mastra

**Deployment & DevOps**
deploy-artifact, vercel, tailscale

**Agent Orchestration**
sub-agent-patterns, multi-agent, plan-mode, skill-creator, soul-keeper, reflection, self-improving, skills-watchdog, openclaw-config, platform-bridge

**Content & Media**
content-research-writer, video-analyzer, douyin-dl, ffmpeg-cli, mermaid-architect, nano-banana-2

**Image Generation**
nano-banana-2 → Gemini 3.1 Flash + Pro, 512-4K, transparency, style transfer

**Search & APIs**
grok-search, moonshot-usage, claude-usage, calculator

**Documents**
docx, pdf, seo

**Design**
ui-ux-pro-max-2 → 50 styles, 21 palettes, 9 framework stacks

### By Trigger Keyword

| User says... | Use skill |
|---|---|
| screenshot, capture page | snap, html-screenshot |
| browse, click, fill form | agent-browser, browser-use |
| scrape, crawl, extract web | firecrawl |
| calculate, math, percentage | calculator |
| generate image, create art, sprite | nano-banana-2 |
| diagram, flowchart, visualize | mermaid-architect |
| video, transcode, convert, ffmpeg | ffmpeg-cli |
| download douyin, 抖音 | douyin-dl |
| word doc, .docx, report | docx |
| PDF, fill form, merge PDF | pdf |
| deploy, vercel | deploy-artifact, vercel |
| tailscale, VPN, devices | tailscale |
| next.js, app router | nextjs-best-practices |
| supabase auth, login | nextjs-supabase-auth |
| postgres, query optimize | supabase-postgres-best-practices |
| typescript types, generics | typescript-advanced-types |
| monorepo, turborepo | turborepo |
| mastra, agent framework | mastra |
| search web, search X/Twitter | grok-search |
| moonshot balance, kimi | moonshot-usage |
| claude usage, quota | claude-usage |
| UI design, landing page | ui-ux-pro-max-2 |
| SEO, meta tags | seo |
| plan, 先别做, analyze | plan-mode |
| create skill, new skill | skill-creator |
| multi-agent, parallel | multi-agent, sub-agent-patterns |
| my IP, public IP | show-my-ip |
| code review python | python-code-review |
| AI SDK, vercel ai | ai-sdk |

## How to Create a New Skill

1. Read `SKILL_GUIDELINE.md` for the standard (7 required sections, 5 patterns)
2. Or ask the `skill-creator` skill to scaffold one for you
3. Every SKILL.md must have: USE FOR, When to Use, Prerequisites, Quick Start, Examples, Error Handling, Pattern

## Five Skill Patterns

| Pattern | Use For | Example |
|---|---|---|
| Tool Wrapper | Wrapping a CLI/API | agent-browser, calculator |
| Pipeline | Multi-step workflow | development, content-research-writer |
| Reviewer | Quality checking | python-code-review |
| Generator | Creating artifacts | mermaid-architect |
| Inversion | Routing/decision | browser-routing |

## Install

```bash
git clone https://github.com/mfang0126/openclaw-skills.git ~/.openclaw/skills
```

Skills are auto-detected by OpenClaw. No additional config needed.

## Conventions

- Skill folder names: kebab-case
- SKILL.md: max 500 lines, load references/ on demand
- Scripts: must be executable, use shebangs
- Language: SKILL.md in English, trigger phrases bilingual (EN/CN) where relevant
- Dependencies: declared in SKILL.md Prerequisites section
