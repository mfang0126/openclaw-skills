# skill-creator

> Create, iterate, and optimize skills through an eval-driven Pipeline loop.

## How It Works

**Pattern: Pipeline** (Google ADK)

```
Intent capture
  → Interview & research
  → Write SKILL.md draft
  → Create test cases (evals/evals.json)
  → Spawn with-skill + baseline runs in parallel
  → Grade outputs, aggregate benchmark
  → Launch eval viewer for human review
  → Read feedback → Improve skill
  → Repeat until satisfied
  → Description optimization (run_loop.py)
  → Package (.skill file)
```

## Directory Structure

```
skill-creator/
├── SKILL.md               # Main instructions (Pipeline overview)
├── references/
│   ├── eval-loop.md       # Full detail: running, grading, benchmarking, viewer
│   ├── description-optimization.md  # Full detail: trigger evals, run_loop.py
│   └── schemas.md         # JSON schemas for evals.json, grading.json, benchmark.json
├── scripts/               # Executable Python modules
│   ├── run_loop.py        # Description optimization loop
│   ├── aggregate_benchmark.py
│   └── package_skill.py
├── agents/                # Subagent prompt files
│   ├── grader.md
│   ├── comparator.md
│   └── analyzer.md
├── assets/
│   └── eval_review.html   # HTML template for trigger eval review
└── eval-viewer/
    └── generate_review.py # Launch the results viewer
```

## Design Decisions

- **Viewer before self-evaluation**: Human sees outputs BEFORE agent evaluates — avoids anchoring bias
- **Subagents for parallel runs**: With-skill and baseline spawn simultaneously so both complete around the same time
- **Workspace sibling dir**: `<skill-name>-workspace/` keeps eval artifacts separate from skill source
- **Description optimization last**: Run after skill content is stable — optimizes triggering without changing behavior

## Supported Environments

| Environment | Subagents | Browser Viewer | Description Optimization |
|-------------|-----------|----------------|--------------------------|
| Claude Code | ✅ | ✅ | ✅ (`claude -p`) |
| Claude.ai | ❌ | ❌ | ❌ |
| Cowork | ✅ | `--static` flag | ✅ |

## Limitations

- Description optimization requires `claude` CLI (`claude -p`)
- Blind comparison requires subagents (not available in Claude.ai)
- Eval viewer requires Python 3 and a writable filesystem
