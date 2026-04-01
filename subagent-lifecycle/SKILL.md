---
name: subagent-lifecycle
user-invocable: false
description: |
  Subagent lifecycle management protocol. Automatically triggers whenever you're about 
  to call sessions_spawn. This skill exists because subagents fail silently without 
  watchdogs, and forgotten watchdogs create noise — both are worse than not spawning.
  
  TRIGGERS ON:
  - About to call sessions_spawn
  - Planning to delegate work to a subagent
  - Considering whether a task needs a subagent
  
  This skill is NOT optional when spawning. It encodes lessons learned from production 
  failures: 5-minute timeouts that always fail, forgotten watchdogs, zombie subagents, 
  and tasks that disappear into the void. Follow the protocol or don't spawn.
---

# Spawn Protocol

**Pattern: Pipeline**

A strict protocol for subagent lifecycle management. The pipeline has gates — you cannot skip steps.

## Visibility Rule

**Every phase transition must be visible to the user.** When you enter a new phase, explicitly label it in your response:

> **[Phase 1: Pre-flight]** — 判断是否需要 subagent...
> **[Phase 3: Atomic Launch]** — spawn + watchdog 同一 block...
> **[Phase 5: Cleanup]** — 删 watchdog + 汇报结果...

If the user can't see which phase you're in, the pipeline doesn't exist. Silent compliance is the same as non-compliance.

## Why This Exists

Subagents are powerful but fragile. Without discipline:

1. **5-minute timeouts kill everything.** The default "set a 5-min watchdog" advice is wrong. Real tasks take 10-30 minutes. A 5-min timeout means the subagent dies before it can finish anything useful.

2. **No watchdog = task vanishes.** You spawn, forget to set a watchdog, the subagent stalls, and you never know. The user waits forever.

3. **Forgotten watchdog = noise.** Task completes, you forget to delete the watchdog, it fires anyway, and you waste time investigating nothing.

4. **Zombie subagents accumulate.** Failed spawns, stuck sessions, orphaned processes. They clutter the system and confuse future runs.

5. **Fire-and-forget doesn't work.** "I spawned it, my job is done" is a lie. You own the outcome until it's delivered.

This protocol exists to prevent all of the above.

---

## The Pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│  1. PRE-FLIGHT    →    2. PLAN    →    3. ATOMIC LAUNCH         │
│        ↓                                       ↓                │
│  Do I need a               ← ← ← ← ← ← ← ← ← ←                  │
│  subagent at all?                              ↓                │
│                            4. MONITOR    ←    cron fires        │
│                                 ↓                               │
│                            5. CLEANUP    →    done              │
│                                 ↓                               │
│                            6. RECOVERY   →    if stuck/failed   │
└─────────────────────────────────────────────────────────────────┘
```

---

## Phase 1: Pre-flight Check

**Gate: Do not spawn unless all conditions are met.**

Ask yourself:

| Question | If NO → |
|----------|---------|
| Is this task too complex for me to do inline? | Do it yourself. |
| Will it take more than 2-3 tool calls? | Do it yourself. |
| Does it need a fresh context (no stale state)? | Maybe spawn. |
| Does it benefit from parallelism? | Maybe spawn. |
| Am I the coordinator, not the executor? | Spawn. |

**Examples of tasks that DON'T need subagents:**
- Quick file reads/writes
- Simple searches
- Single API calls
- Straightforward code edits

**Examples of tasks that DO need subagents:**
- Multi-file refactoring
- Research + synthesis + execution
- Creating new agents/skills (fresh context helps)
- Parallel independent tasks (spawn multiple)

**If in doubt, do it yourself.** Subagent overhead (spawn time, watchdog management, potential failure recovery) only pays off for substantial tasks.

---

## Phase 2: Plan

Before writing any code, decide:

### 2.1 Model Selection

| Task Type | Model | Why |
|-----------|-------|-----|
| Deep analysis, code review, architectural decisions | `opus` | Needs sophisticated reasoning |
| Code execution, testing, file operations | `sonnet` | Fast, capable, reliable |
| Document synthesis, reorganization | `mimo-v2-pro` | Good at structure (but review output — it can over-compress) |
| Quick simple tasks | `sonnet` | Speed matters |

### 2.2 Timeout Selection

**These are minimums. Err on the side of longer.**

| Task Complexity | Timeout | Examples |
|-----------------|---------|----------|
| Simple query, small edit | 600s (10 min) | "Check if file X exists", "Add one line to config" |
| Standard code work | 1800s (30 min) | Bug fix, feature implementation, test writing |
| Research + plan + execute | 1800s (30 min) | "Research X, propose solution, implement it" |
| Large document work | 1800s (30 min) | Documentation overhaul, multi-file reorganization |
| Complex multi-step | 3600s (60 min) | Major refactoring, new system design |

**Never use 300s (5 min).** It's not enough time for anything real. The subagent will die mid-task and you'll have to redo everything.

### 2.3 Task Description

Write a clear, complete task description. Include:
- What to do (specific, not vague)
- What files/context to read first
- What the deliverable is
- Any constraints or gotchas

**Bad:** "Fix the bug in the auth module"

**Good:** "Fix the login timeout bug in src/auth/session.ts. The issue is that sessions expire after 5 minutes instead of 30. Read the session config in src/config/auth.json first. Deliverable: working code + brief explanation of what you changed."

---

## Phase 3: Atomic Launch

**Critical: Spawn and watchdog MUST be in the same function_calls block.**

Why atomic? If you spawn first and set the watchdog in a separate turn:
- Network issues could prevent the watchdog from being set
- You might get distracted and forget
- The subagent could fail before you set up monitoring

### The Pattern

Both calls go in one block:

1. `sessions_spawn` — starts the subagent
2. `cron add` — sets the watchdog (schedule: 10-30 min out, depending on task)

The watchdog payload should include:
- What task was assigned
- What to check for (expected files, state changes)
- What to do if not done (check session, retry, or do it yourself)

### Watchdog Timing

Set the watchdog at **1.5x your expected completion time**, minimum 10 minutes.

| Expected Duration | Watchdog At |
|-------------------|-------------|
| 5-10 min | 15 min |
| 15-20 min | 30 min |
| 30+ min | 45-60 min |

---

## Phase 4: Monitor (When Watchdog Fires)

When the watchdog cron fires, follow this decision tree:

```
Watchdog fires
    │
    ├── Expected output exists?
    │   ├── YES → Task completed, proceed to Cleanup
    │   └── NO → Check subagent status
    │
    └── Check subagent status (sessions_history)
        │
        ├── Still running, making progress?
        │   └── Extend watchdog (+15 min), let it continue
        │
        ├── Still running, but stuck/looping?
        │   └── Kill it, proceed to Recovery
        │
        ├── Completed but output missing/wrong?
        │   └── Proceed to Recovery
        │
        └── Dead/crashed?
            └── Proceed to Recovery
```

### What "Progress" Looks Like
- Recent tool calls in session history
- Files being created/modified
- Meaningful work happening (not just reading the same file over and over)

### What "Stuck" Looks Like
- No tool calls in last 5+ minutes
- Repeating the same action
- Error loops
- Waiting for something that won't happen

---

## Phase 5: Cleanup

**When the subagent completes successfully, do BOTH of these in the same response:**

1. **Delete the watchdog** — so it doesn't fire unnecessarily
2. **Report the result** — summarize what was done, link to outputs

Why same response? If you report first and delete later:
- You might forget to delete
- The watchdog fires, creating confusion
- You waste time investigating a completed task

### How to Delete Watchdog (Step-by-Step)

**Step 1: Get the UUID**
```
cron list
```
Find your watchdog in the list, copy the `id` field (e.g., `85bc113f-2585-490e-84ea-e73b6b8d3dc4`).

**Step 2: Delete by UUID**
```
cron remove --jobId <UUID>
```
⚠️ **Important**: Do NOT use the watchdog `name` (e.g., "watchdog-wave1"). Use the full UUID.

**Step 3: Verify deletion**
Wait 5-10 minutes. If no watchdog trigger arrives → success.

**Step 4: If still triggering (deletion failed)**
Some cron jobs persist in cache even after `cron remove` reports success. Use the nuclear option:
```
gateway restart
```
This clears all cron jobs from memory. All legitimate cron jobs will reload from config; the stuck watchdog will be gone.

### Cleanup Checklist

- [ ] Watchdog cron deleted (and verified 5 min later, or gateway restarted if stuck)
- [ ] Result summarized to requester
- [ ] Any temporary files cleaned up (if applicable)
- [ ] Session can be closed (if one-shot task)

---

## Phase 6: Recovery

When a subagent fails, stalls, or produces wrong output:

### Recovery Decision Tree

```
Subagent failed
    │
    ├── Was it a transient error (network, timeout)?
    │   └── Retry once with same params
    │
    ├── Was it a task clarity issue?
    │   └── Rewrite task description, retry
    │
    ├── Was it a model capability issue?
    │   └── Upgrade model (sonnet → opus), retry
    │
    ├── Already retried once?
    │   └── DO IT YOURSELF
    │
    └── Time-critical task?
        └── DO IT YOURSELF (no more retries)
```

### The Golden Rule

**Never report failure as your final answer.**

Wrong: "The subagent failed, so I couldn't complete the task."

Right: "The subagent failed, so I did it myself. Here's the result: ..."

You own the outcome. The subagent is a tool, not an excuse. If the tool breaks, you pick up a different tool or use your hands.

---

## Quick Reference Card

### Timeout Cheatsheet
| Task | Minimum Timeout |
|------|-----------------|
| Anything | 600s (10 min) |
| Standard work | 1800s (30 min) |
| Complex work | 3600s (60 min) |

### Model Cheatsheet
| Need | Model |
|------|-------|
| Smart | opus |
| Fast | sonnet |
| Docs | mimo-v2-pro |

### The 5 Rules

1. **Pre-flight:** Don't spawn what you can do yourself
2. **Atomic:** Spawn + watchdog in one block
3. **Monitor:** Check progress, not just completion
4. **Cleanup:** Delete watchdog when done
5. **Own it:** Never blame the subagent

---

## Anti-Patterns

These are mistakes that have caused real production failures:

| Anti-Pattern | What Happens | Instead |
|--------------|--------------|---------|
| 5-minute watchdog | Subagent dies mid-task | Use 10-30 min minimum |
| Spawn without watchdog | Task vanishes, user waits forever | Always set watchdog atomically |
| Forget to delete watchdog | Noise, wasted investigation | Delete in same response as result |
| "Subagent failed" as final answer | User's task not done | Do it yourself |
| Vague task description | Subagent does wrong thing | Be specific, include context |
| Fire and forget | No accountability | Monitor and own the outcome |
| Spawning for simple tasks | Overhead exceeds benefit | Do simple things yourself |

---

## Example: Complete Lifecycle

Here's what a well-managed subagent lifecycle looks like:

**1. Pre-flight:** "This is a multi-file refactoring task. Too complex for inline. Spawn approved."

**2. Plan:** 
- Model: sonnet (code execution)
- Timeout: 1800s (30 min standard work)
- Task: Clear description with files to read, expected output

**3. Atomic Launch:** (in one function_calls block)
- sessions_spawn with task
- cron add with 30-min watchdog

**4. Monitor:** (watchdog fires at 30 min)
- Check: files created? ✓
- Result looks good
- Proceed to cleanup

**5. Cleanup:** (in one response)
- Delete watchdog cron
- Report: "Refactoring complete. Changed X, Y, Z. See commit abc123."

**6. Recovery:** (not needed this time — but if it were)
- Subagent failed → do it myself → report result anyway

---

## Dependencies

- `sessions_spawn` tool
- `cron` tool (for watchdog scheduling)
- `sessions_history` tool (for monitoring)

No external scripts or APIs required. This is a protocol, not a tool.
