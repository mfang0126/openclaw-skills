# soul-keeper Setup Guide

## Step 1: Install

**Option A — Global (all agents share it):**
```bash
cp -r soul-keeper ~/.openclaw/skills/
```

**Option B — Specific agent only:**
```bash
# Replace <agent-id> with your agent name (e.g. main, researcher, king)
cp -r soul-keeper ~/.openclaw/agents/<agent-id>/skills/
```

soul-keeper will monitor the workspace files of whichever agent it's installed for.

---

## Step 2: Create Your Workspace Files

Create these files in your agent's workspace directory.

Find your workspace path:
```bash
cat ~/.openclaw/openclaw.json | grep workspace
```

Default: `~/.openclaw/workspace/`

soul-keeper monitors these files and tells you when they need updating.

---

## Required Files

### 1. SOUL.md
**What it is:** Your agent's personality and behavior rules.
**Where:** `{workspace}/SOUL.md`

```markdown
# SOUL.md

## Core Identity
[One sentence: who you are and who you serve]

## My Voice
- [Style rule 1, e.g. "No filler words like 'Great question!'"]
- [Style rule 2, e.g. "Use the user's language (Chinese → reply Chinese)"]
- [Style rule 3]

## What I Believe
- [Value 1]
- [Value 2]
- [Value 3]

## Hard Rules
- [Never do X]
- [Always confirm before Y]
- [Z requires user approval]
```

**Max size:** 800 bytes

---

### 2. USER.md
**What it is:** Who you're serving — their preferences, background, communication style.
**Where:** `{workspace}/USER.md`

```markdown
# USER.md

## Basics
- Name: [name]
- Timezone: [e.g. GMT+11]
- Language: [primary language]

## Work Style
- [Preference 1, e.g. "Direct answers, no preamble"]
- [Preference 2]
- [Preference 3]

## Don't Do This
- [Annoyance 1]
- [Annoyance 2]

## Can Assume
- [Background knowledge]
- [Tech stack / environment]
```

**Max size:** 800 bytes

---

### 3. IDENTITY.md
**What it is:** Your agent's name and one-line description.
**Where:** `{workspace}/IDENTITY.md`

```markdown
# IDENTITY.md

- **Name:** [Agent name]
- **Emoji:** [one emoji]
- **Role:** [one-line description]
```

**Max size:** 300 bytes

---

### 4. AGENTS.md
**What it is:** How your agent works — startup flow, core rules, index of detailed docs.
**Where:** `{workspace}/AGENTS.md`

```markdown
# AGENTS.md

## Every Session
1. Read MEMORY.md
2. Read pending-updates.md (if exists)
3. [Any other startup steps]

## Core Rules
- [Rule 1]
- [Rule 2]

## Reference Docs
- Detailed tool rules → `docs/TOOLS-REFERENCE.md`
- [Other docs as needed]
```

**Max size:** 1.5KB. Use index pointers — don't copy full rules here.

---

### 5. TOOLS.md
**What it is:** Fatal tool rules — things that break the system if violated.
**Where:** `{workspace}/TOOLS.md`

```markdown
# TOOLS.md

## [Tool Category]
- ❌ Never do X
- ✅ Always do Y instead
- ✅ For Z, follow this process: ...
```

**Max size:** 1KB. Only "violate = something breaks" rules. Usage tutorials go in `docs/`.

---

### 6. MEMORY.md
**What it is:** Current state of the world — active projects, key facts, quick references.
**Where:** `{workspace}/MEMORY.md`

```markdown
# MEMORY.md

## Current Focus
[Active task or project]

## Active Projects
| Project | Status | Next step |
|---------|--------|-----------|
| [name]  | 🟢     | [action]  |

## Quick Reference
- [Key fact or pointer]
- [Key fact or pointer]
```

**Max size:** 1.5KB. This is an index (L0), not a detailed log.

---

## Optional Files

### WORKING.md
Detailed project tracking. Loaded on demand (not every session).
**Where:** `{workspace}/WORKING.md`

### HEARTBEAT.md
Scheduled checks — what to do on a timer or at session start.
**Where:** `{workspace}/HEARTBEAT.md`

### memory/YYYY-MM-DD.md
Daily logs. Auto-created by agents, loaded at session start.
**Where:** `{workspace}/memory/YYYY-MM-DD.md`

### pending-updates.md
soul-keeper writes ignored suggestions here. Checked at session start.
**Where:** `{workspace}/pending-updates.md` (auto-created by soul-keeper)

---

## Minimum Setup

If you want to start fast, create just these 3:

1. `SOUL.md` — personality + hard rules
2. `MEMORY.md` — current focus + active projects
3. `AGENTS.md` — startup flow + core rules

soul-keeper will work with any subset of these files. It only suggests updates for files that exist.

---

## File Location Reference

```
~/.openclaw/workspace/         ← default workspace root
├── SOUL.md                    ← required
├── USER.md                    ← required
├── IDENTITY.md                ← required
├── AGENTS.md                  ← required
├── TOOLS.md                   ← required
├── MEMORY.md                  ← required
├── WORKING.md                 ← optional, on-demand
├── HEARTBEAT.md               ← optional, scheduled
├── pending-updates.md         ← auto-created by soul-keeper
├── memory/
│   └── YYYY-MM-DD.md          ← daily logs
└── docs/
    └── [detailed reference files]
```

Your workspace path may differ. Check your OpenClaw config:
```bash
cat ~/.openclaw/openclaw.json | grep workspace
```

---

*For file details and token budgets, see `references/workspace-files.md`*
