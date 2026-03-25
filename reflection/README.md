# reflection

> Unified self-reflection and self-improvement. Three-layer memory: Golden Rules → Active Lessons → Raw Log.

**Pattern: Pipeline** (Google ADK)

## How It Works

Reflection uses a **three-layer memory architecture** with automatic promotion and demotion:

```
触发条件（用户纠正 / 会话结束 / Heartbeat）
    │
    Stage 1: Capture
    ├── 识别 miss（具体错误，不是"更小心"）
    ├── 识别 fix（具体行动）
    ├── 分类 tag
    └── reflection log <tag> <miss> <fix>
    │
    Stage 2: Organize
    ├── 同一 lesson 3次? → 询问是否晋升为永久规则
    ├── reflection promote <pattern> → 上移一层
    ├── 30天未用? → reflection demote <pattern>
    └── 超出 size 限制? → 压缩/归档
    │
    Stage 3: Apply
    ├── 会话开始: 读取 SOUL.md + self-review.md
    ├── 执行前: 引用相关 lesson
    └── 模式匹配: 增加 Applied 计数
```

## Three-Layer Memory

| Layer | File | Max Size | Volatility |
|-------|------|----------|-----------|
| 1 Golden Rules | `SOUL.md` | ≤50 rules | Permanent — proven, high-confidence |
| 2 Active Lessons | `memory/self-review.md` | ≤100 lines | Working — grouped by topic |
| 3 Raw Log | `memory/YYYY-MM-DD.md` | Unlimited | Ephemeral — daily entries |

**Promotion path:** Layer 3 → 2 → 1 (used 3x+ successfully, or user confirms)  
**Demotion path:** Layer 1 → 2 → 3 (unused 30+ days, or user removes)

## Design Decisions

**Why markdown files, not a database?**
Human-readable and version-controllable. You can `cat`, `grep`, and `git diff` your own memory. No database dependency, no migration pain.

**Why three layers?**
Different volatility. Golden Rules (SOUL.md) are permanent — you don't want noisy daily logs polluting them. The three-layer system lets high-signal patterns rise to the top over time, while low-signal entries stay in raw logs.

**Why `jq` for state?**
Structured state (counters, timestamps, weights) needs a query tool. `jq` is the standard Unix JSON processor — no extra dependencies beyond what's expected on a developer machine.

## Supported Inputs

| Trigger | When | Action |
|---------|------|--------|
| User correction | User says "No, actually..." | Auto-log immediately |
| Session end | Before closing | Run "Land the Plane" routine |
| Heartbeat ALERT | `reflection check` returns ALERT | Pause and reflect |
| Manual command | `reflection log` / `reflection read` | Execute directly |

## Limitations

- Lessons are **workspace-scoped** — won't transfer between workspaces automatically
- Requires `jq` — not available everywhere by default (`brew install jq` / `apt install jq`)
- No encryption — do not store credentials, health data, or third-party PII in lessons (see `references/boundaries.md`)
- Layer 1 cap is 50 rules — promote selectively, don't bloat golden rules

## Companion: soul-keeper

| | Reflection | Soul-keeper |
|---|---|---|
| **Does** | Learns lessons, stores in `memory/` | Updates workspace files (`SOUL.md`, `AGENTS.md`) |
| **Reads** | Its own memory layers | `memory/self-review.md`, `SOUL.md` |
| **Writes** | `memory/*.md`, state file | Workspace files (with user confirmation) |

Install both for full lifecycle. They don't overlap.

## Related Skills

- `soul-keeper` — Companion for workspace file updates
- `heartbeat` — Triggers periodic `reflection check`
