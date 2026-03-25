# soul-keeper

> Monitors workspace files and prompts updates at the right moment. Keeps your agent's memory and preferences aligned with reality.

## How It Works

**Pattern: Reviewer** (Google ADK)

```
Conversation signal detected
  → Identify which workspace file needs updating
  → Read current file content
  → Diff against observed reality
  → Propose targeted update (suggest, don't auto-edit)
```

## The 8 Workspace Files

| File | Updates When |
|------|-------------|
| `SOUL.md` | User corrects same behavior 2+ times |
| `USER.md` | User expresses new preference or habit |
| `MEMORY.md` | New project starts or direction changes |
| `WORKING.md` | Task status changes, project pauses/completes |
| `AGENTS.md` | New rule files appear or agents are added |
| `TOOLS.md` | New tools installed or tools break |
| `BOOTSTRAP.md` | Onboarding flow changes |
| `HEARTBEAT.md` | N-turn heartbeat triggers |

## Design Decisions

- **Suggest, don't auto-edit**: Workspace files are the agent's "soul" — user should confirm changes
- **Signal-based**: Monitors conversation for patterns, not file timestamps
- **Batch at session end**: Avoids interrupting flow; presents all suggestions when user says goodbye

## Session End Hook

When the user ends a session (e.g., "done for today", "bye", "talk tomorrow"), soul-keeper:
1. Collects all pending update suggestions from the session
2. Presents a batch summary: which files to update and what to change
3. Waits for confirmation before writing

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/check_workspace.sh` | List all workspace files with modification dates and line counts |

## Limitations

- Operates on conversation signals, not file watchers (no real-time monitoring)
- Requires the agent to have read access to workspace files
- Does not auto-apply changes — all edits require user confirmation
