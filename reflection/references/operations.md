# Memory Operations

## Session Start (auto-load)

1. Read SOUL.md (Layer 1) — always loaded, ≤50 rules
2. Read memory/self-review.md (Layer 2) — always loaded, ≤100 lines
3. Layer 3 (daily logs) — NOT loaded at start, only on explicit query

## On Correction Received

1. Detect correction using trigger phrases (see triggers.md)
2. Classify: type (format/technical/workflow) + scope (global/domain/project)
3. Run: `reflection log <tag> <miss> <fix>`
4. Check if duplicate in Layer 2/1 — if so, bump weight instead
5. If same correction 3x → ask user: "Make this a permanent rule?"
   - Yes → `reflection promote <pattern>`
   - No → keep in Layer 3

## On Pattern Applied

When using a learned pattern:
1. Cite source: "Using X (from self-review.md:12)" or "(from SOUL.md:5)"
2. Increment Applied counter in state file (key: pattern hash)
3. If Applied >= 3 and still in Layer 3 → auto-promote to Layer 2

## Session End ("Land the Plane")

1. Review session: any corrections logged?
2. Patterns used successfully this session → bump weight
3. Patterns that failed → consider demotion
4. Run `reflection stats` to report state
5. If session_corrections > 0: summarize lessons learned

## Compaction Rules

### Layer 1 (SOUL.md) — max 50 rules
- If > 50: demote least-applied rules to Layer 2
- Merge similar rules into one
- Keep wording short: one line per rule

### Layer 2 (self-review.md) — max 100 lines
- Group by topic (## headings)
- Merge similar entries
- Archive entries unused 30+ days to daily log with "archived" tag

### Layer 3 (daily logs) — unlimited
- One file per day, no compaction needed
- Old files (90+ days) can be deleted if Layer 2 has the distilled lessons

## Weight Tracking

Weights stored in `~/.openclaw/reflection-state.json` under `weights` key:

    {
      "weights": {
        "<pattern-hash>": {"weight": 3, "applied": 5, "last_used": 1711234567}
      }
    }

- New entry: weight=1, applied=0
- Each successful application: applied += 1
- User confirms rule: weight += 2
- Pattern unused 30 days: weight -= 1
- Weight reaches 0: demote to next layer down
- Weight reaches 5+: candidate for Layer 1 promotion
