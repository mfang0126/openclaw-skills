# Changelog

All notable changes to the openclaw-skills repository.

## [2026-04-02] — af4d4b0

### Added
- **xhs-publisher** — 小红书安全发帖 skill（anti-bot pipeline, human warmup, rate limiting, 人审门控）
- **knowledge-capture** — 视频下载→转录→整理→归档 Pipeline（douyin-dl → ASR → LLM summarize → .md archive）
- **reddit** — Reddit 搜索/读帖 CLI（read-only, cookie auth）
- **safe-delete** — 用 trash 替代 rm，防止误删
- **whisper-transcribe** — Groq API / whisper.cpp 转录（Groq 优先，本地 fallback）
- **bundled-baseline.sha256** — bundled skills 的 SHA256 基线
- **verify-bundled.sh** — 验证 bundled skills 是否被修改的脚本

### Changed
- **plan-mode** → **plan**（重命名）
- **skills-watchdog/baseline.json** — 版本号从 unknown 更新，baseline 日期 03-22 → 03-30
- 43 个 skills 添加 `user-invocable: false`（batch routing control）

## [2026-03-27] — 49e7dbd ~ 21b6bf3

### Added
- **SEO** skill — AI-driven site audit + content writer + competitor analysis
- **Prerequisites** section to 13 skills
- **SKILLS_INDEX.md** — searchable skills catalog
- **References** sections to multiple skills

### Changed
- README switched to English (default), added README_CN.md
- SKILLS_INDEX_CN.md added for Chinese users
- 5 skills description switched to English
- .gitignore simplified

## [2026-03-26] — a235d06 ~ 8a1162a

### Added
- **AGENTS.md** — AI-readable entry point for the repo
- **nano-banana-2** — AI image generation (NB2 + Pro, style transfer, cost tracking)
- **reflection** — upgraded from self-reflection（quality gates, conflict detection, signal detection）
- **soul-keeper** — workspace file update monitoring
- Comprehensive README with catalog, setup guide, architecture docs
- 37 custom skills fully quality-assured

### Removed
- **content-inbox**, **newsletter-assistant**, **audio-timestamp-verifier**, **memory-audit** — moved to private
- **wordpress-cli** — cleaned personal references
- **load** — internal debug tool

### Fixed
- **supabase-backend-platform** — replaced symlink with actual files
- **research-pro** — replaced symlink with actual files
