# UPGRADE_PLAN — video-analyzer

> Generated: 2026-03-25 | SOP Version: 1.0

---

## Pattern Classification

**Pattern: Pipeline**

Rationale: This skill processes video through strict sequential steps: download → extract audio (ffmpeg) → transcribe (Whisper) → validate (research-hub) → materialize (output markdown). The processing levels B/C/D define exactly which steps run. No deviation from the sequence. → Pipeline.

---

## Current State Audit

### Files Present
| File | Present | Notes |
|------|---------|-------|
| SKILL.md | ✅ | Exists — minimal (Chinese, short) |
| templates/blog-material.md | ✅ | Output template exists |
| scripts/ | ⚠️ | Directory exists but **empty** |
| README.md | ❌ | Missing |
| _meta.json | ❌ | Missing |
| evals/evals.json | ❌ | Missing |
| references/levels.md | ❌ | Referenced in SKILL.md but doesn't exist |
| references/scenarios.md | ❌ | Referenced in SKILL.md but doesn't exist |

**Missing files: 5 (README.md, _meta.json, evals/evals.json, references/levels.md, references/scenarios.md)**
**Critical: scripts/ is empty — no actual processing scripts**

---

## SKILL.md Gaps

| SOP Requirement | Status | Detail |
|----------------|--------|--------|
| `name` + `description` in frontmatter | ✅ | Present |
| Description is **pushy** with trigger keywords | ❌ | Description says "不直接触发" — has no trigger keywords, passive framing |
| `USE FOR:` section with example phrases | ❌ | Missing |
| `REPLACES:` section | ➖ | N/A |
| `REQUIRES:` dependencies | ⚠️ | Listed in body but not in `REQUIRES:` format |
| Pattern label | ❌ | No `**Pattern: Pipeline**` label |
| `When to Use` section | ❌ | Only has invocation syntax, no "when to use" |
| `Prerequisites` section | ❌ | Missing |
| `Quick Start` section | ❌ | Missing |
| `Instructions` / `Pipeline` | ⚠️ | Processing levels table exists but steps not detailed |
| At least 1 complete `Example` | ❌ | No example input/output shown |
| `Error Handling` table | ❌ | Missing |
| < 500 lines total | ✅ | Currently very short (~40 lines) |

---

## Critical Issues

1. **scripts/ is empty** — The skill references ffmpeg for audio extraction and Whisper for transcription, but there are no actual scripts. The pipeline cannot execute.
2. **references/ files don't exist** — SKILL.md points to `references/levels.md` and `references/scenarios.md` which are missing.
3. **No trigger keywords** — Description says "不直接触发" (not directly triggered) but provides no caller guidance beyond `content-inbox`.
4. **No examples** — Can't verify correct behavior without example inputs/outputs.

---

## Upgrade Tasks

### Priority 1 — Critical: Create Missing Scripts
- [ ] Create `scripts/download.sh` — download video from YouTube/抖音/B站 (yt-dlp)
- [ ] Create `scripts/transcribe.sh` — extract audio with ffmpeg, transcribe with Whisper
- [ ] Create `scripts/validate.sh` — fact-check via research-hub
- [ ] Create `scripts/materialize.sh` — generate output markdown from template
- [ ] Create `scripts/pipeline.sh` — orchestrate B/C/D levels
- [ ] Make all scripts executable: `chmod +x`
- [ ] Test each script standalone

### Priority 2 — Create Missing Reference Files
- [ ] Create `references/levels.md` — document A/B/C/D processing levels in detail
- [ ] Create `references/scenarios.md` — document scenario-to-validation mapping

### Priority 3 — SKILL.md Overhaul
- [ ] Add `**Pattern: Pipeline**` label
- [ ] Rewrite description to include trigger keywords (even if called by content-inbox)
- [ ] Add `USE FOR:` section describing when content-inbox would invoke this
- [ ] Add `REQUIRES:` formal section: ffmpeg, whisper, yt-dlp, python3
- [ ] Add `Prerequisites` section with install commands
- [ ] Add `Quick Start` — example invocation via sessions_spawn
- [ ] Expand `Pipeline` section with step-by-step detail for each level
- [ ] Add at least 1 complete `Example` (input video → output markdown)
- [ ] Add `Error Handling` table: ffmpeg missing, Whisper OOM, network failure, etc.

### Priority 4 — Create Standard Files
- [ ] Create `_meta.json` with pattern, tags, requires
- [ ] Create `evals/evals.json` with ≥ 3 test cases
- [ ] Create `README.md` with architecture, design decisions, limitations

---

## _meta.json Template

```json
{
  "name": "video-analyzer",
  "version": "1.0.0",
  "author": "King",
  "pattern": "Pipeline",
  "emoji": "🎬",
  "created": "2026-03-25",
  "requires": {
    "bins": ["ffmpeg", "whisper", "yt-dlp", "python3"],
    "modules": []
  },
  "tags": ["video", "transcription", "content", "whisper", "pipeline", "subagent"]
}
```

---

## Error Handling Table (to add to SKILL.md)

| Error | Cause | Fix |
|-------|-------|-----|
| `ffmpeg: command not found` | ffmpeg not installed | `brew install ffmpeg` |
| `whisper: command not found` | Whisper not installed | `pip install openai-whisper` |
| `yt-dlp: command not found` | yt-dlp not installed | `pip install yt-dlp` |
| Download fails | Platform restriction / geo-block | Try alternate URL or VPN |
| Transcription OOM | Video too long for Whisper | Use `--model tiny` or split audio |
| Validation timeout | research-hub unreachable | Retry or skip validation step |

---

## evals/evals.json Template

```json
{
  "skill_name": "video-analyzer",
  "pattern": "Pipeline",
  "evals": [
    {
      "id": 1,
      "prompt": "处理视频 fitness.mp4，级别 B",
      "input": "fitness.mp4",
      "expected": "Whisper 转写完成，输出 fitness.md 到 content-inbox"
    },
    {
      "id": 2,
      "prompt": "处理 YouTube 视频，级别 C",
      "input": "https://youtube.com/watch?v=xxx，操作：C",
      "expected": "转写 + PubMed 验证 + 素材化 markdown"
    },
    {
      "id": 3,
      "prompt": "处理 B 站视频，级别 D，生成博客草稿",
      "input": "https://bilibili.com/video/BVxxx，操作：D",
      "expected": "完整 blog-material.md，含博客草稿段落"
    }
  ]
}
```

---

## Summary

| Item | Count |
|------|-------|
| Missing files | 5 (README.md, _meta.json, evals/evals.json, references/levels.md, references/scenarios.md) |
| Empty directories | 1 (scripts/ — no scripts inside) |
| SKILL.md gaps | 9 sections missing or inadequate |
| Critical issues | 2 (no scripts, broken references/) |
| Estimated effort | ~3–4 hours (scripts are the main work) |
