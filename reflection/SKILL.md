---
name: reflection
description: |
  Unified self-reflection and self-improvement. Three-layer memory:
  Golden Rules (SOUL.md) → Active Lessons (self-review.md) → Raw Log (daily).
  Auto-captures corrections, reflects at session end, promotes patterns that work.

  USE FOR:
  - User corrects agent behavior → auto-log and learn
  - Session end → "land the plane" reflection
  - Heartbeat timer → periodic self-check
  - "what have you learned", "show your lessons", "memory stats"
  - "remember this rule", "promote this pattern", "demote this"
  - Agent notices own mistake → self-log

  REPLACES: self-improving, self-reflection (merged into this skill)
  COMPANION: soul-keeper (independent — pushes lessons to workspace files)

  REQUIRES: jq, date
metadata: {"openclaw":{"emoji":"🪞","requires":{"bins":["jq","date"]},"os":["linux","darwin"],"configPaths":["memory/"]}}
---

# Reflection

**Pattern: Pipeline** (Google ADK) — Capture → Organize → Apply (three-stage memory pipeline with promotion/demotion gates)

## When to Use

**Don't use when:** User is giving a one-off instruction that doesn't need to be remembered, or you're in the middle of executing a task (reflect after, not during).

This skill activates automatically in these situations:

1. **User corrects you** — phrases like "No, do X instead", "I told you before", "Stop doing X"
2. **Session ending** — before closing, review what you learned ("Land the Plane")
3. **Heartbeat ALERT** — `reflection check` returns ALERT after threshold elapsed
4. **User asks about lessons** — "what have you learned?", "show your patterns", "memory stats"
5. **You notice your own mistake** — self-initiated reflection after completing work

## Prerequisites

- `jq` installed (for state file management)
- `date` command available (standard on macOS/Linux)
- `memory/` directory in workspace (created automatically on first `reflection log`)
- `SOUL.md` in workspace root (Layer 1 — your golden rules)

## Quick Start

```bash
# Check if reflection is due (heartbeat integration)
reflection check

# Log a lesson after being corrected
reflection log "error-handling" "Forgot timeout on API call" "Always add timeout=30"

# Read recent lessons
reflection read              # last 5 daily log entries
reflection read --layer 2    # active lessons (self-review.md)
reflection read --all        # all 3 layers

# View memory statistics
reflection stats

# Promote a proven pattern up one layer
reflection promote "timeout"

# Demote an unused rule down one layer
reflection demote "old-pattern"
```

## Three-Layer Memory

| Layer | File | Max Size | Loaded When | Content |
|-------|------|----------|-------------|---------|
| 1 Golden Rules | SOUL.md | ≤50 rules | Always (session start) | Proven, high-confidence rules |
| 2 Active Lessons | memory/self-review.md | ≤100 lines | Always (session start) | Working patterns, grouped by topic |
| 3 Raw Log | memory/YYYY-MM-DD.md | Unlimited | On explicit query | Daily entries with miss/fix/weight |

**Promotion:** Layer 3 → 2 → 1 (pattern used 3x+ successfully, or user confirms as rule)
**Demotion:** Layer 1 → 2 → 3 (pattern unused 30+ days, or user says to remove)

## Pipeline: Capture → Organize → Apply

### Stage 1: Capture

When a trigger is detected (see Auto-Trigger Conditions below):

1. Identify what went wrong — the specific miss, not "I should be more careful"
2. Identify the fix — the specific action to take next time
3. Classify by tag (correction, preference, workflow, technical, format)
4. Run: `reflection log <tag> <miss> <fix>`

**Rule:** Every reflection must have a concrete miss and a concrete fix. "Be more careful" is not a valid fix. "Check workspace path before running commands" is.

For detailed trigger patterns, load `references/triggers.md`.

### Stage 2: Organize

After logging, check if the pattern should be promoted:

- Same lesson logged 3x → ask user: "Should I make this a permanent rule?"
- User says "yes" → `reflection promote <pattern>`
- Pattern applied successfully 3+ times → auto-promote candidate
- Pattern unused 30 days → `reflection demote <pattern>`

For size limit enforcement and compaction rules, load `references/operations.md`.

### Stage 3: Apply

**On session start:**
1. Read SOUL.md (Layer 1) — these rules guide all behavior
2. Read memory/self-review.md (Layer 2) — these lessons inform current work

**Before relevant tasks:**
- If about to do something related to a known lesson → cite it
- Format: "Applying: always add timeout=30 (from self-review.md:12)"

**On pattern match:**
- Increment the Applied counter in state file
- If Applied >= 3 and still in Layer 3 → suggest promotion

## Signal Detection

Replaces external Python scripts — agent detects signals inline using these rules.

### HIGH Signal (log immediately)
- User says "never", "always", "wrong", "stop", "the rule is"
- User says "不对", "错了", "应该是", "别这样"
- Explicit correction of previous output
- User reverses a decision with explanation

**Action:** Log immediately. No confirmation needed. Mark `confidence: HIGH`.

### MEDIUM Signal (log, mark as pending verification)
- User says "perfect", "exactly", accepts output enthusiastically
- User says "对", "可以", "就这样"
- A proposed approach is adopted without changes
- User builds on agent's suggestion

**Action:** Log as positive lesson. Mark `confidence: MEDIUM`.

### LOW Signal (observe, do not log yet)
- Implicit pattern (user didn't say good or bad)
- Needs 3x repetition to upgrade to MEDIUM

**Action:** Mental note only. No file write.

---

## Quality Gates

Every lesson MUST pass all 5 checks before being stored. **Fail any → discard.**

| Check | Standard | Fail Example |
|-------|----------|-------------|
| **Reusable** | Will encounter this again | "今天网络慢" (one-time) |
| **Non-trivial** | Required discovery, not common sense | "先读文档再操作" (obvious) |
| **Specific** | Can describe trigger condition | "要小心" (too vague) |
| **Verified** | Solution actually worked | Guess without verification |
| **No duplication** | Not already in self-review or SOUL | Redundant entry |

---

## Conflict Detection

Before storing a new lesson, search `self-review.md` and `SOUL.md` for contradictions:

- **No conflict** → store normally
- **Conflict found** → report to user, let them decide

**Conflict report format:**
```
⚠️ Conflict Detected

New lesson: [X]
Existing rule: [Y] (from SOUL.md:12 or self-review.md:5)

Conflict: [explain the contradiction]

Choose:
- Keep new (replace old)
- Keep old (discard new)
- Keep both (different scenarios — specify when each applies)
```

---

## Structured Lesson Format

All lessons use this YAML format in `memory/YYYY-MM-DD.md`:

```yaml
- id: lesson-YYYY-MM-DD-NNN
  domain: coordination | tech | research | product | qa
  agent: king | tech-lead | researcher | product-owner | verifier
  type: negative | positive | decision
  confidence: HIGH | MEDIUM | LOW
  pattern: "description of when this happens"
  trigger: "when to recall this lesson"
  good: "correct approach"
  bad: "incorrect approach"
  source_quote: "user's original words (optional)"
  evidence: 1
  applied: 0
  source: "YYYY-MM-DD"
  target_file: "self-review.md | SOUL.md"
  status: active | confirmed | deprecated
```

**Promotion/demotion rules:**
- evidence >= 3 → candidate for self-review.md (Layer 2)
- applied >= 3 → candidate for SOUL.md (Layer 1, requires user confirmation)
- 30 days with no trigger → status: deprecated
- User explicitly rejects → delete immediately

---

## Auto-Trigger Conditions

### 1. User Correction Detected

Trigger phrases (non-exhaustive):
- "No, that's not right..." / "Actually, it should be..."
- "I told you before..." / "Why do you keep..."
- "Stop doing X" / "Never do Y"
- "Always do X for me" / "I prefer X, not Y"

**Action:** HIGH signal → run quality gates → log if passes. No confirmation needed for logging. Only ask for confirmation when promoting to Layer 1.

### 2. Session End ("Land the Plane")

Before ending any session:
1. Were there any corrections this session? Review them.
2. Did any learned patterns help this session? Bump their weight.
3. Any patterns that failed? Consider demotion.
4. Run `reflection stats` — report current memory state.
5. If session_corrections > 0, summarize: "This session I learned: ..."

### 3. Heartbeat Timer

Run `reflection check` at each heartbeat interval.
- If OK → continue working
- If ALERT → pause and reflect:
  1. Run `reflection read` — review recent lessons
  2. Ask yourself: anything I should have logged but didn't?
  3. If yes → `reflection log`
  4. If no → continue

Configure heartbeat in `~/.openclaw/openclaw.json`:
```json
{
  "agents": {
    "defaults": {
      "heartbeat": { "every": "60m" }
    }
  }
}
```

Add to workspace HEARTBEAT.md:
```
## References

### Original Sources
- **reflect-learn by stevengonsalvez** — https://github.com/openclaw/skills/tree/main/skills/stevengonsalvez/reflect-learn
  - Original concept: Signal detection + quality gates + conflict detection
  - Merged and enhanced with three-layer memory architecture

### Inspirations
- **Google ADK Five Patterns** — https://google.github.io/adk-docs/skills/
- **agentskills.io Standard** — https://agentskills.io/specification

---

## Self-Reflection Check (required)
Run `reflection check` at each heartbeat.
If ALERT: read past lessons, reflect, then log insights.
```

## Commands

| Command | Description | Example |
|---------|-------------|---------|
| `reflection check [--quiet]` | Check if reflection due | `reflection check --quiet` → OK or ALERT |
| `reflection log <tag> <miss> <fix>` | Log new reflection | `reflection log "path" "Used relative path" "Use absolute paths"` |
| `reflection read [n]` | Read last n daily logs | `reflection read 3` |
| `reflection read --layer <1\|2\|3>` | Read specific layer | `reflection read --layer 2` |
| `reflection read --tag <tag>` | Filter by tag | `reflection read --tag workflow` |
| `reflection read --all` | Read all 3 layers | `reflection read --all` |
| `reflection stats` | Show memory statistics | `reflection stats` |
| `reflection promote <pattern>` | Move pattern up one layer | `reflection promote "timeout"` |
| `reflection demote <pattern>` | Move pattern down one layer | `reflection demote "old rule"` |

## Integration with soul-keeper

Reflection and soul-keeper are **companion skills** with distinct responsibilities:

| | Reflection | Soul-keeper |
|---|---|---|
| **Does** | Learns lessons, stores in memory/ | Updates workspace files (SOUL.md, AGENTS.md, etc.) |
| **Reads** | Its own memory layers | memory/self-review.md, SOUL.md |
| **Writes** | memory/*.md, state file | Workspace files (with user confirmation) |

**Flow:** Reflection produces lessons → soul-keeper decides when workspace files need updating. They do NOT overlap. Install both for full lifecycle.

## Reflection Report Format

Every `/reflect` or session-end reflection outputs this structured report:

```markdown
# Reflection Report

**Date**: [YYYY-MM-DD HH:MM]
**Session duration**: [X minutes]
**Focus**: [main task this session]

## Detected Signals

| # | Signal | Level | Original words | Domain |
|---|--------|-------|---------------|--------|
| 1 | [lesson] | HIGH | "[user quote]" | coordination |

## Proposed Writes

### Lesson 1: [title]

**Target layer**: Layer 3 (daily) → pending upgrade to Layer 2
**Quality gates**:
- [x] Reusable
- [x] Non-trivial
- [x] Specific
- [x] Verified
- [x] No duplication

**Conflict detection**: ✅ No conflict

**Format**:
```yaml
- id: lesson-2026-03-26-001
  domain: coordination
  ...
```

## Confirm

Write the above lessons?
- `Y` — write all
- `N` — discard
- `1` — write only lesson #1
```

---

## Examples

### Example 1: Correction → Log → Promote

```
User: "No, don't use console.log — use the logger module"

Agent detects correction trigger → runs:
  reflection log "technical" "Used console.log for debugging" "Always use logger module"
  ✓ Logged to memory/2026-03-24.md [technical] weight=1

... (same correction happens 2 more times over several sessions) ...

Agent: "I've been corrected about console.log 3 times.
        Should I make 'always use logger module' a permanent rule?"
User: "Yes"

Agent runs:
  reflection promote "logger module"
  ✓ Promoted to Layer 2 (self-review.md)

... (pattern applied successfully 5+ times) ...

Agent runs:
  reflection promote "logger module"
  ✓ Promoted to Layer 1 (SOUL.md)
```

### Example 2: Heartbeat Reflection

```
Heartbeat fires → agent runs: reflection check
  ALERT: 65m since last reflection
  Session corrections: 2

Agent runs: reflection read 3
  --- 2026-03-24 ---
  [14:30] technical: Used wrong API endpoint → Check docs before calling
  [15:10] workflow: Forgot to run tests → Run tests after every change

Agent reflects: "Both lessons are about checking before acting.
  Pattern: verify before executing."

Agent runs:
  reflection log "meta" "Multiple skip-verification errors" "Always verify (docs/tests) before executing"
```

### Example 3: Session End

```
Session ending. Agent runs: reflection stats
  Layer 1: 12 rules
  Layer 2: 8 entries, 3 topics
  Layer 3: 1 file today, 3 entries
  Session corrections: 1

Agent: "This session I learned: always set timeout on external API calls.
  1 correction logged, 0 promotions. Memory healthy."
```

## Error Handling

| Error | Cause | Fix |
|-------|-------|-----|
| `jq: command not found` | jq not installed | Install: `brew install jq` (macOS) or `apt install jq` (Linux) |
| `reflection: command not found` | Script not in PATH | Add skill scripts dir to PATH or use full path |
| `No SOUL.md found` | Layer 1 file missing | Create: `echo "# Golden Rules" > SOUL.md` |
| `No memory directory` | First run in workspace | Will be created automatically on first `reflection log` |
| `State file corrupt` | jq write interrupted | Delete `~/.openclaw/reflection-state.json` — will be recreated |
| Layer 1 over 50 rules | Too many promotions | Run `reflection stats`, demote least-used rules |
| Layer 2 over 100 lines | Needs compaction | Merge similar entries, archive old ones |

## Scope

This skill ONLY:
- Learns from user corrections and self-reflection
- Stores lessons in local markdown files (memory/)
- Reads its own memory layers
- Manages pattern weights in local state file

This skill NEVER:
- Accesses calendar, email, or external services
- Makes network requests
- Reads files outside memory/ and SOUL.md
- Infers preferences from silence or observation
- Modifies its own SKILL.md
- Stores credentials, health data, or third-party info (see references/boundaries.md)
