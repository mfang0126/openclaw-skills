# Changelog

All notable changes to the openclaw-skills repository.

## Skill Source Index

Every skill in this repo is annotated with its origin:

| Source | Label | Count | Description |
|--------|-------|-------|-------------|
| **Original** | 🟢 | 22 | Created by us (King/Ming/Freedom/hopyky) |
| **ClawHub** | 🔵 | 8 | Installed from [clawhub.ai](https://clawhub.ai), possibly modified locally |
| **Adapted** | 🟡 | 1 | Based on third-party, rewritten for our use case |
| **Third-party (in repo)** | 🟠 | 5 | From specific third-party sources with licenses |
| **Third-party (external)** | ⚪ | 1 | Installed outside this repo |
| **Anthropic** | 🔴 | 4 | © Anthropic, from Claude Code built-in skills |

### 🟢 Original Skills
douyin-dl, content-research-writer, platform-bridge, video-analyzer, openclaw-config, soul-keeper, reflection, skills-watchdog, multi-agent, sub-agent-patterns, subagent-lifecycle, plan, development, python-code-review, deploy-artifact, html-screenshot, html2img, moonshot-usage, supabase-backend-platform, turborepo, typescript-advanced-types, xhs-publisher, knowledge-capture, reddit, safe-delete, whisper-transcribe

### 🔵 ClawHub Skills
| Skill | Slug | Version | Author |
|-------|------|---------|--------|
| grok-search | grok-search | 0.2.1 | ClawHub |
| seo | seo | 1.0.3 | ClawHub (clawic.com) |
| ffmpeg-cli | ffmpeg-cli | 1.0.0 | ascendswang (ClawHub) |
| mermaid-architect | mermaid-architect | 1.0.0 | ClawHub |
| snap | snap | 1.0.2 | Kav-K (ClawHub) |
| show-my-ip | show-my-ip | 1.0.0 | ClawHub |
| tailscale | tailscale | 1.0.0 | ClawHub |
| ui-ux-pro-max-2 | ui-ux-pro-max-2 | 0.1.0 | ClawHub |

### 🟡 Adapted Skills
| Skill | Based On | Changes |
|-------|----------|---------|
| claude-usage | openclaw-claude-usage (ClawHub) | Rewritten with tmux-based approach |

### 🟠 Third-party (in repo)
| Skill | Source | License |
|-------|--------|---------|
| nextjs-supabase-auth | vibeship-spawner-skills | Apache 2.0 |
| nextjs-best-practices | Community | — |
| supabase-postgres-best-practices | Supabase official docs | MIT |
| mastra | Mastra official docs | Apache 2.0 |
| nano-banana-2 | kingbootoshi | MIT |

### ⚪ Third-party (external, not in repo)
| Skill | Source | License |
|-------|--------|---------|
| humanizer | [blader/humanizer](https://github.com/blader/humanizer) | MIT (© Siqi Chen) |

### 🔴 Anthropic (Claude Code built-in)
| Skill | License |
|-------|---------|
| docx | Proprietary © 2025 Anthropic |
| pdf | Proprietary © 2025 Anthropic |
| calculator | MIT © 2025 Anthropic |
| skill-creator | Apache 2.0 © Anthropic |

---

## [2026-04-02] — af4d4b0

### Added
- 🟢 **xhs-publisher** — 小红书安全发帖（anti-bot pipeline, human warmup, rate limiting, 人审门控）
- 🟢 **knowledge-capture** — 视频下载→转录→整理→归档 Pipeline
- 🟢 **reddit** — Reddit 搜索/读帖 CLI（read-only）
- 🟢 **safe-delete** — trash 替代 rm
- 🟢 **whisper-transcribe** — Groq API / whisper.cpp 转录
- **bundled-baseline.sha256** — bundled skills SHA256 基线
- **verify-bundled.sh** — bundled skills 验证脚本

### Changed
- **plan-mode** → **plan**（重命名）
- **skills-watchdog/baseline.json** — 版本号更新，baseline 日期 03-22 → 03-30
- 43 个 skills 添加 `user-invocable: false`（batch routing control）

## [2026-03-27] — 49e7dbd ~ 21b6bf3

### Added
- 🟢 **seo** skill — AI-driven site audit + content writer + competitor analysis
  - ⚠️ Later verified as 🔵 ClawHub install (seo v1.0.3)
- **Prerequisites** section to 13 skills
- **SKILLS_INDEX.md** — searchable skills catalog
- **References** sections to multiple skills

### Changed
- README switched to English (default), added README_CN.md
- SKILLS_INDEX_CN.md added for Chinese users
- .gitignore simplified

## [2026-03-26] — a235d06 ~ 8a1162a

### Added
- 🟢 **AGENTS.md** — AI-readable entry point for the repo
- 🟢 **nano-banana-2** — AI image generation (🟠 kingbootoshi, MIT)
- 🟢 **reflection** — upgraded from self-reflection（quality gates, conflict detection）
- 🟢 **soul-keeper** — workspace file update monitoring
- Comprehensive README with catalog, setup guide, architecture docs
- 37 custom skills fully quality-assured

### Removed
- content-inbox, newsletter-assistant, audio-timestamp-verifier, memory-audit — moved to private
- wordpress-cli — cleaned personal references
- load — internal debug tool

### Fixed
- supabase-backend-platform — replaced symlink with actual files
- research-pro — replaced symlink with actual files
