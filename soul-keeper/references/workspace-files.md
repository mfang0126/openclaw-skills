# OpenClaw Workspace Files — Reference Guide

> For soul-keeper: what each file is, when to update it, and token budgets.
> Standalone — no local files required. Works out of the box after installing soul-keeper.

---

## What Each File Does

| File | Answers | Analogy | Loaded |
|------|---------|---------|--------|
| **SOUL.md** | Who am I? How do I talk? | Personality | Every session |
| **USER.md** | Who do I serve? Their preferences? | Client profile | Every session |
| **IDENTITY.md** | What's my name? | Business card | Every session |
| **AGENTS.md** | How do I work? | Employee handbook | Every session |
| **TOOLS.md** | What tool rules must I never break? | Safety rules | Every session |
| **MEMORY.md** | What's the current state of the world? | Dashboard | Every session |
| **WORKING.md** | What projects are in progress? | Kanban board | On demand |
| **HEARTBEAT.md** | What do I check on a schedule? | Inspection checklist | On heartbeat |
| **memory/YYYY-MM-DD.md** | What happened today? | Daily log | Session start |
| **docs/*** | Detailed rules and references | Encyclopedia | On trigger |

## Separation Principle

```
SOUL.md    → WHO I am        (personality layer)
USER.md    → WHO I serve     (user layer)
AGENTS.md  → WHAT I do       (behavior layer)
TOOLS.md   → HOW I use tools (tool layer)
MEMORY.md  → WHAT I know     (knowledge layer)
```

**Golden rule:** If unsure which file, ask which question above it answers.

---

## When to Update Each File

| File | Update when... | Signal |
|------|---------------|--------|
| **SOUL.md** | Agent behavior needs adjustment | Same correction 2+ times; communication style changed; new boundary |
| **USER.md** | User's situation changed | New preference; new habit; new device/environment |
| **AGENTS.md** | Workflow changed | New docs/ rule file; new trigger rule; startup flow changed |
| **TOOLS.md** | Tool chain changed | New tool installed; old tool broke; fatal usage discovered |
| **MEMORY.md** | World state changed | New project; project finished; new environment config |
| **WORKING.md** | Project progress changed | Real progress; new project; project paused/finished |
| **IDENTITY.md** | Almost never | Rename; repositioning |
| **HEARTBEAT.md** | Checklist changed | New scheduled task; old task removed |

---

## Token Budgets

| File | Max Size | ~Tokens |
|------|---------|---------|
| SOUL.md | 800B | 200 |
| USER.md | 800B | 200 |
| IDENTITY.md | 300B | 75 |
| AGENTS.md | 1.5KB | 375 |
| TOOLS.md | 1KB | 250 |
| MEMORY.md | 1.5KB | 375 |
| memory × 2 | 4KB | 1,000 |
| **Total** | **~10KB** | **~2,600** |

Rule of thumb: Bootstrap total should not exceed 5% of context window.

---

## Common Mistakes

| Mistake | Consequence | Fix |
|---------|-------------|-----|
| Everything in SOUL.md | Personality and rules mixed up | SOUL = personality, AGENTS = rules |
| User preferences in MEMORY.md | User info scattered | Move to USER.md |
| WORKING.md loaded every session | Wastes ~375 tokens | Load on demand only |
| Detailed rules in AGENTS.md | AGENTS.md bloats | Use index pointers → docs/ |
| Completed projects in WORKING.md | File too large | Archive to memory/ |

---

## Information Flow

```
Auto-loaded every session:
  SOUL + USER + IDENTITY + AGENTS + TOOLS + MEMORY + today's log

On demand:
  WORKING.md    → when user asks about project status
  docs/*        → when a specific scenario triggers it
  research/*    → when historical research is needed
```

---

*This file is part of soul-keeper skill. No local dependencies required.*
*Source: github.com/mfang0126/openclaw-skills/soul-keeper*

---

## Cleanup Cadence

Regular cleanup prevents workspace drift. soul-keeper will remind you automatically.

| What | When to clean | How |
|------|--------------|-----|
| **Cron jobs** | When the task is done | `openclaw cron rm <id>` |
| **DECISIONS.md entries** | When the decision is acted on | Move to `memory/YYYY-MM-DD.md`, delete from DECISIONS |
| **pending-updates.md** | When handled or no longer relevant | Delete the line |
| **WORKING.md projects** | When finished or paused | Archive to memory/, update status |

**Rule:** When you say "done" or "complete" on a task — that's the signal to clean up the associated cron + decision entry. Don't leave orphans.
