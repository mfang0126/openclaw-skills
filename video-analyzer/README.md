# video-analyzer

> Deep video analysis pipeline: download → transcribe (Whisper) → validate (research-hub) → materialize to Markdown. Called by `content-inbox` as a subagent.

## Pattern: Pipeline

Sequential fixed stages: download → extract audio (ffmpeg) → transcribe (Whisper) → validate facts (research-hub) → generate output Markdown. Processing level (B/C/D) controls which stages run.

## ⚠️ Critical: scripts/ Directory is Empty

**The `scripts/` directory exists but contains no scripts.**

The pipeline cannot execute without the following scripts:
- `scripts/download.sh` — download from YouTube/抖音/B站 via yt-dlp
- `scripts/transcribe.sh` — extract audio with ffmpeg, transcribe with Whisper
- `scripts/validate.sh` — fact-check via research-hub
- `scripts/materialize.sh` — generate output Markdown from template
- `scripts/pipeline.sh` — orchestrate B/C/D processing levels

**Also missing:**
- `references/levels.md` — referenced in SKILL.md but does not exist
- `references/scenarios.md` — referenced in SKILL.md but does not exist

**Until scripts are created**, this skill can only transcribe manually (user runs ffmpeg + whisper themselves) and use the `templates/blog-material.md` template for output formatting.

## Install

```bash
# Required binaries
brew install ffmpeg yt-dlp
pip install openai-whisper

# Verify
ffmpeg -version
yt-dlp --version
whisper --help
```

## Pipeline Levels

| Level | Stages | Approx Time |
|-------|--------|-------------|
| **B** | Download + Whisper transcription | ~5 min |
| **C** | B + research-hub fact validation + materialization | ~20 min |
| **D** | C + blog draft generation | ~30 min |

## Invocation (via content-inbox)

```javascript
sessions_spawn({
  runtime: "subagent",
  task: "用 video-analyzer 处理：https://youtube.com/watch?v=xxx，操作：C"
})
```

## Output Location

```
content-inbox/{platform}/media/YYYY-MM-DD/
├── 标题.mp4
└── 标题.md        ← generated from templates/blog-material.md
```

## Design Decisions

- **Local Whisper only**: No cloud transcription API — keeps content private and free.
- **Level system (B/C/D)**: Allows cost/time trade-offs. Quick notes use B, verified content uses C/D.
- **research-hub validation**: Facts checked against authoritative sources per scenario type (PubMed for health, psychology research for mental health, multi-source for general science).
- **Subagent pattern**: Long-running pipeline (5–30 min) runs as subagent so main session stays responsive.

## Limitations

- **Scripts are missing** — pipeline does not currently execute (see ⚠️ above).
- Level A (real-time streaming) is not implemented.
- Geo-blocked videos may fail yt-dlp download; no VPN integration.
- Very long videos (>1 hour) may cause Whisper OOM with large models; use `--model tiny` or split audio.
- `research-hub` validation requires that skill to be installed and functional.

## Templates

| File | Purpose |
|------|---------|
| `templates/blog-material.md` | Output template for materialized blog content |

## Related Skills

- `content-inbox` — Orchestrates video-analyzer as subagent
- `research-hub` — Provides fact validation (Level C/D)
