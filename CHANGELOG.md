# Changelog

All notable changes to the openclaw-skills repository.

## Skill Source Index

Every skill in this repo is annotated with its origin:

| Source | Label | Count | Description |
|--------|-------|-------|-------------|
| **Original** | 🟢 | 26 | Created by us (King/Ming/Freedom/hopyky) |
| **ClawHub (in repo, modified)** | 🔵 | 3 | From ClawHub, we added content or rewrote |
| **Anthropic (in repo, modified)** | 🔴 | 2 | © Anthropic, with our additions |
| **Anthropic (external)** | 🔴 | 2 | © Anthropic, Claude Code built-in, no modifications |
| **ClawHub (external)** | ⚪ | 6 | From ClawHub, no modifications |
| **Third-party (external)** | ⚪ | 5 | No modifications, installed separately |
| **Third-party (external)** | ⚪ | 1 | Not in repo, MIT license |

### 🟢 Original Skills (in this repo)
douyin-dl, content-research-writer, platform-bridge, video-analyzer, openclaw-config, soul-keeper, reflection, skills-watchdog, multi-agent, sub-agent-patterns, subagent-lifecycle, plan, development, python-code-review, deploy-artifact, html-screenshot, html2img, moonshot-usage, supabase-backend-platform, turborepo, typescript-advanced-types, xhs-publisher, knowledge-capture, reddit, safe-delete, whisper-transcribe

### 🔵 ClawHub Skills (in this repo, with modifications)
| Skill | Slug | Version | Our Changes |
|-------|------|---------|-------------|
| grok-search | grok-search | 0.2.1 | Added References section |
| seo | seo | 1.0.3 | Added Prerequisites section |
| claude-usage | openclaw-claude-usage | — | Fully rewritten with tmux approach |

### 🔴 Anthropic (in repo, with modifications)
| Skill | License | Our Changes |
|-------|---------|-------------|
| calculator | MIT © 2025 Anthropic | Added Examples + Error Handling + evals |
| skill-creator | Apache 2.0 © Anthropic | Generalized push target template |

### ⚪ External Skills (not in this repo, installed separately)
| Skill | Source | License |
|-------|--------|---------|
| ffmpeg-cli | ClawHub (ascendswang) | — |
| mermaid-architect | ClawHub | — |
| snap | ClawHub (Kav-K) | — |
| show-my-ip | ClawHub | — |
| tailscale | ClawHub | — |
| ui-ux-pro-max-2 | ClawHub | — |
| docx | Claude Code built-in | Proprietary © Anthropic |
| pdf | Claude Code built-in | Proprietary © Anthropic |
| nextjs-supabase-auth | vibeship-spawner-skills | Apache 2.0 |
| nextjs-best-practices | Community | — |
| supabase-postgres-best-practices | Supabase official docs | MIT |
| mastra | Mastra official docs | Apache 2.0 |
| nano-banana-2 | kingbootoshi | MIT |
| humanizer | [blader/humanizer](https://github.com/blader/humanizer) | MIT (© Siqi Chen) |

---

## [2026-04-02] — (latest)

### Removed (no modifications, moved to external)
- nextjs-supabase-auth, nextjs-best-practices, supabase-postgres-best-practices, mastra, nano-banana-2 — third-party, no workflow changes
- These are now listed in README as "External Skills We Use"

## [2026-04-02] — bc54060

### Removed (no modifications, moved to external)
- clawdcursor — symlink, added to .gitignore

## [2026-04-02] — 3dc58f2

### Removed (internal use only, preserved locally)
- bundled-baseline.sha256, verify-bundled.sh — added to .gitignore
- .DS_Store — removed from tracking, added to .gitignore

## [2026-04-02] — c4e9767

### Removed (no modifications, moved to external)
- ffmpeg-cli, mermaid-architect, snap, show-my-ip, tailscale, ui-ux-pro-max-2 — ClawHub, unmodified
- docx, pdf — Claude Code built-in, unmodified

## [2026-04-02] — af4d4b0

### Added
- 🟢 **xhs-publisher** — 小红书安全发帖（anti-bot pipeline, human warmup, rate limiting, 人审门控）
- 🟢 **knowledge-capture** — 视频下载→转录→整理→归档 Pipeline
- 🟢 **reddit** — Reddit 搜索/读帖 CLI（read-only）
- 🟢 **safe-delete** — trash 替代 rm
- 🟢 **whisper-transcribe** — Groq API / whisper.cpp 转录

### Changed
- **plan-mode** → **plan**（重命名）
- 43 个 skills 添加 `user-invocable: false`（batch routing control）

## [2026-03-27] — 49e7dbd ~ 21b6bf3

### Added
- **SKILLS_INDEX.md** — searchable skills catalog
- **References** sections to multiple skills
- **Prerequisites** section to 13 skills

### Changed
- README switched to English (default), added README_CN.md

## [2026-03-26] — a235d06 ~ 8a1162a

### Added
- 🟢 **reflection** — upgraded from self-reflection（quality gates, conflict detection）
- 🟢 **soul-keeper** — workspace file update monitoring
- 37 custom skills fully quality-assured

### Removed
- content-inbox, newsletter-assistant, audio-timestamp-verifier, memory-audit — moved to private
- wordpress-cli, load — cleaned up
