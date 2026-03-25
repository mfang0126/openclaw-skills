# Agent Self-Maintenance System

> A four-skill combination that keeps your AI agent healthy, consistent, and up-to-date — automatically.
> Based on Ming Fang's production setup. All skills are in this repo.

---

## The Problem

AI agents have a memory problem. Every new session starts fresh:
- Rules you taught it yesterday? Gone.
- Lessons from mistakes last week? Gone.
- Tasks you parked? Forgotten.
- Skills that silently went out of date? Nobody knows.

You end up repeating yourself, re-teaching the same rules, and discovering problems only when things break.

This system fixes that.

---

## The Four Skills

| Skill | Role | Trigger |
|-------|------|---------|
| **self-improving** | Learns from corrections permanently | You correct the agent |
| **self-reflection** | Logs lessons from each work session | Every ~60 minutes |
| **soul-keeper** | Maintains workspace files + cleanup audit | Every ~10 turns, or "done" |
| **skills-watchdog** | Checks all skill versions for updates | Daily at your chosen time |

---

## How They Work Together

```
Your daily work
    │
    ├── You correct the agent ("don't do that again")
    │   → self-improving writes it to permanent memory
    │   → Next session: rule is already loaded
    │
    ├── Every 60 minutes (heartbeat)
    │   → self-reflection reviews what happened
    │   → Logs lessons to memory/self-review.md
    │
    ├── Every ~10 conversation turns, or when you say "done"
    │   → soul-keeper checks if workspace files need updating
    │   → Flags orphan crons, stale DECISIONS entries, pending-updates
    │
    └── Every morning at 09:00
        → skills-watchdog scans all skill versions
        → Notifies you (Discord/Telegram) if any updates found
```

---

## Real Scenarios

### Scenario 1: You correct the agent

> **You say:** "Stop using that opening phrase"

→ self-improving logs this as a correction
→ Writes to `~/self-improving/corrections.md` and promotes to `~/self-improving/memory.md` (HOT tier)
→ **Next session: correction is already loaded. Same mistake won't happen again.**

Without this: Every session starts from zero. You repeat yourself forever.

---

### Scenario 2: 60-minute heartbeat fires

> **Background: agent has been working for an hour**

→ self-reflection reviews today's work
→ If there's a notable lesson (e.g. "hardcoded paths break for other users"), logs it
→ Format: what went wrong → what to do differently
→ Written to `workspace/memory/self-review.md`
→ **Next time a similar situation comes up, the lesson is surfaced**

Without this: Lessons only exist in the current context. New session = blank slate.

---

### Scenario 3: You say "done" after finishing a task

> **You say:** "Done, the investigation is complete"

→ soul-keeper triggers a cleanup audit
→ Checks: are there cron jobs to delete?
→ Checks: are there completed entries in DECISIONS.md to archive?
→ Checks: should WORKING.md be updated?
→ Checks: does MEMORY.md need a new entry?
→ Prompts you to handle each one
→ **Workspace stays clean. No accumulation.**

Without this: Cron list grows, DECISIONS.md bloats, workspace drifts from reality.

---

### Scenario 4: Daily watchdog runs

> **Every morning at 09:00 (your timezone)**

→ skills-watchdog scans all installed skills
→ Compares local versions against upstream (GitHub, clawhub)
→ If updates found: sends a notification with what changed
→ No updates: silent
→ **You know about updates before they become problems**

Without this: Skills silently go out of date. You discover it when something breaks.

---

## What You Get

| Problem | Before | After |
|---------|--------|-------|
| Agent repeats same mistakes | Every session restarts | self-improving remembers permanently |
| Lessons disappear after session | Context window clears | self-reflection logs to files |
| Tasks and reminders pile up | Manual cleanup | soul-keeper audits automatically |
| Skills go out of date silently | Discover when things break | Daily notification |

---

## Setup

### Step 1: Install all four skills

```bash
git clone https://github.com/mfang0126/openclaw-skills.git /tmp/oc-skills && \
cp -r /tmp/oc-skills/{soul-keeper,skills-watchdog} ~/.openclaw/skills/ && \
npx clawhub install self-improving self-reflection && \
rm -rf /tmp/oc-skills
```

### Step 2: Initialize self-improving

```bash
mkdir -p ~/self-improving/{projects,domains,archive}
touch ~/self-improving/memory.md
touch ~/self-improving/corrections.md
```

### Step 3: Initialize self-reflection

```bash
mkdir -p ~/.openclaw/workspace/memory

cat > ~/.openclaw/self-reflection.json << 'EOF'
{
  "threshold_minutes": 60,
  "memory_file": "~/.openclaw/workspace/memory/self-review.md",
  "state_file": "~/.openclaw/self-review-state.json",
  "max_entries_context": 5
}
EOF

touch ~/.openclaw/workspace/memory/self-review.md
```

### Step 4: Set up soul-keeper

See `soul-keeper/SETUP.md` — create your workspace files (SOUL.md, USER.md, MEMORY.md, etc.)

### Step 5: Set up skills-watchdog daily cron

```bash
# First run — builds baseline
bash ~/.openclaw/skills/skills-watchdog/scripts/check.sh

# Add daily cron (replace timezone)
openclaw cron add \
  --name "skills-watchdog" \
  --cron "0 9 * * *" \
  --tz "Your/Timezone" \
  --system-event "Run skills-watchdog: bash ~/.openclaw/skills/skills-watchdog/scripts/check.sh — if any UPDATE found, notify me." \
  --session main
```

### Step 6: Add to HEARTBEAT.md

Add these lines to your workspace `HEARTBEAT.md`:

```markdown
## Every Session Start
1. Read `pending-updates.md` — any outstanding items?
2. Read `~/self-improving/memory.md` — load HOT corrections
3. Check `workspace/memory/self-review.md` — recent lessons

## Every 60 Minutes
- Run self-reflection check — log any new lessons
```

---

## Maintenance

| Action | When |
|--------|------|
| Add correction to self-improving | When you correct the agent |
| Archive completed DECISIONS entries | When soul-keeper prompts after "done" |
| Delete completed cron jobs | When soul-keeper prompts after "done" |
| Update skill baselines | After you update a skill |

---

## Design Notes

- **self-improving** and **self-reflection** are prompt-based skills — the agent reads their SKILL.md and executes the logic itself. No CLI binary required.
- **skills-watchdog** is a real script — runs independently via cron.
- **soul-keeper** is prompt-based — triggers on conversation signals and heartbeat.
- All four are **passive by default** — they only activate when their trigger conditions are met. No interruptions during normal work.

---

## Files Created by This System

```
~/self-improving/
  ├── memory.md          # HOT: always-loaded corrections
  ├── corrections.md     # Last 50 corrections log
  ├── projects/          # Per-project patterns
  ├── domains/           # Domain-specific patterns (code, writing)
  └── archive/           # Cold storage

~/.openclaw/workspace/
  ├── memory/
  │   └── self-review.md # Self-reflection log
  └── pending-updates.md # soul-keeper pending items

~/.openclaw/
  ├── self-reflection.json     # self-reflection config
  └── self-review-state.json   # last reflection timestamp

~/.openclaw/skills/skills-watchdog/
  └── baseline.json      # skill version baseline (auto-generated)
```

---

*Part of the [openclaw-skills](https://github.com/mfang0126/openclaw-skills) collection.*
*Design based on production usage by [@mfang0126](https://x.com/mfang0126).*
