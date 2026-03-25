# How to Write OpenClaw Skills

> Ming's playbook for building production-quality OpenClaw skills.
> Based on Google ADK 5 patterns + lessons learned in production.
> Last updated: 2026-03-22

---

## The Core Principle

**A skill is not a prompt. It's a structured knowledge injection system.**

The goal isn't to write clever instructions — it's to define:
1. When to load this knowledge (trigger conditions)
2. What knowledge to load (content)
3. How to use it (execution flow)
4. How to maintain it (versioning)

---

## Step 1: Pick a Pattern First

Before writing a single line, identify which Google ADK pattern fits your skill.

```
What does this skill need to do?
    │
    ├── Load domain knowledge on demand?
    │   → Tool Wrapper
    │
    ├── Produce consistent structured output?
    │   → Generator
    │
    ├── Evaluate existing work against criteria?
    │   → Reviewer
    │
    ├── Gather information before starting?
    │   → Inversion
    │
    └── Execute a strict multi-step process?
        → Pipeline
```

**Patterns can combine.** research-pro = Pipeline (4 modes) + Tool Wrapper (loads tools on demand).

### Pattern Quick Reference

| Pattern | Problem it solves | Key mechanism |
|---------|------------------|---------------|
| **Tool Wrapper** | Context bloat from always-loaded knowledge | Load only when the task matches the domain |
| **Generator** | Inconsistent output structure | Fixed template + style guide |
| **Reviewer** | Mixing "what to check" with "how to check" | Separate checklist from execution flow |
| **Inversion** | Agent guesses instead of asking | Gate: no output until info is complete |
| **Pipeline** | Steps get skipped in complex tasks | Explicit stages with gates between them |

---

## Step 2: Design the Trigger

The `description:` field in SKILL.md is the most important line you'll write. It determines when the skill gets loaded.

**Rules:**
- Be specific about what DOES trigger it
- Be equally specific about what DOES NOT trigger it
- If another skill handles overlapping cases, call it out explicitly

**Bad:**
```yaml
description: Helps with research and finding information online.
```

**Good:**
```yaml
description: |
  Unified research entry point. Handles ALL research/investigation requests.
  
  Triggers: "帮我研究", "查一下", "search for", "look up", competitive analysis,
  market research, X/Twitter discussions, Reddit community opinions.
  
  Does NOT trigger:
  - User gave a specific URL to scrape (use firecrawl)
  - Simple facts you already know with confidence
  
  Usually called internally by research-pro. Can be @mentioned directly.
```

**Conflict check:** Before finalizing, run `openclaw skills list` and compare trigger words with existing skills.

---

## Step 3: Separate Knowledge from Execution

Never put reference documentation inline in SKILL.md. Use `references/`.

```
my-skill/
  SKILL.md          ← execution logic + trigger (keep lean)
  references/
    api-guide.md    ← loaded on demand
    examples.md     ← loaded on demand
  scripts/
    run.sh          ← actual execution
```

In SKILL.md, reference them explicitly:
```markdown
## When you need API syntax
Read `{skillDir}/references/api-guide.md` before calling the API.
```

This keeps the base context window clean. Knowledge is injected only when needed — the Tool Wrapper pattern.

---

## Step 4: Write the Execution Flow

For Pipeline skills, make stages explicit with gates.

```markdown
## Phase 1: Classify (5 seconds)
[decision tree]

## Phase 2: Execute
### Quick Mode
[steps]
### Deep Mode  
[steps]

## Phase 3: Output
[standard format]
```

**Gates** = checkpoints where the skill must verify something before proceeding.

Example gate:
```markdown
⛔ Do not proceed to Phase 2 until you have:
- [ ] Confirmed the user's core question
- [ ] Identified which mode applies
```

---

## Step 5: Set `user-invocable` Correctly

```yaml
user-invocable: true   # User can trigger directly ("run research-pro on X")
# omit or false        # Only called internally by other skills/agents
```

**Architecture rule:**
- Entry point skills (like research-pro) → `user-invocable: true`
- Execution layer tools (like grok-search, firecrawl) → omit (default false)

This prevents trigger conflicts without modifying the tool skills themselves.

---

## Step 6: Quality Checklist

Before shipping any skill:

**Design**
- [ ] Google ADK pattern identified and noted in SKILL.md
- [ ] Trigger conditions are unique (checked against existing skills)
- [ ] `user-invocable` set correctly

**Knowledge management**
- [ ] External reference docs in `references/`, not inline
- [ ] API/CLI versions recorded at bottom of SKILL.md
- [ ] Workspace file references point to `docs/WORKSPACE_FILES_GUIDE.md`

**Maintenance**
- [ ] Placed in `~/.openclaw/skills/` (openclaw-managed), not `~/.agents/skills/`
- [ ] Has git remote if GitHub-sourced (`git init` + `git remote add origin`)
- [ ] Pushed to `github.com/mfang0126/openclaw-skills`

**Testing**
- [ ] At least 3 trigger test prompts written
- [ ] At least 1 "should NOT trigger" test case

---

## Real Examples

### research-pro — Pipeline + Tool Wrapper

Entry point for all research. Orchestrates grok-search, reddit-cli, youtube, tavily, firecrawl.

Key decisions:
- `user-invocable: true` → user says "研究一下X" and this fires
- Other search tools have `user-invocable` omitted → no trigger conflicts
- 4-mode pipeline (Quick/Standard/Deep/Crawl) → no steps get skipped
- Tool selection reference table → Tool Wrapper pattern

### soul-keeper — Reviewer

Monitors workspace files and suggests updates.

Key decisions:
- N-turn heartbeat (every ~10 turns) → proactive, not just reactive
- Session-end hook → batch suggestions, less interruption
- `pending-updates.md` → nothing falls through the cracks
- References `docs/WORKSPACE_FILES_GUIDE.md` on demand → lean base context

### skills-watchdog — Reviewer

Daily version checker for all managed skills.

Key decisions:
- Checklist (versions table) is separate from execution script
- `scripts/check.sh` does the actual work
- Cron at 9AM Sydney → automated, not manual
- Discord notification only on UPDATE → no noise when all is well

---

## Maintenance Flow

```
1. Make changes locally (~/.openclaw/skills/<skill>/)
2. Test manually
3. Copy to /tmp/openclaw-skills-sync/<skill>/
4. git commit -m "descriptive message"
5. git push origin main
6. skills-watchdog will detect upstream changes automatically
```

**Version tracking:** Note dependencies in SKILL.md, but derive versions dynamically at runtime — never hardcode them.

---

## Step 7: Generic Skill Test

> **A skill should be a pattern, not a snapshot.**
> The moment you write a specific name, version, path, or username — you've turned a pattern into a snapshot. Snapshots break. Patterns compose.

**The final test:** Can someone with a fresh OpenClaw install use this skill without editing a single line? If no — it's not generic.

Answer NO to all of these before publishing:

**References**
- [ ] Does it reference any file outside `{skillDir}` or standard workspace paths?
- [ ] Does it assume local docs/guides/configs that aren't bundled in `{skillDir}/references/`?

**Names & Versions**
- [ ] Are any specific skill names hardcoded? (e.g. research-pro, grok-search)
- [ ] Are any version numbers hardcoded?
- [ ] Are any usernames, handles, or personal names hardcoded? (e.g. @Ming)
- [ ] Does the description mention a specific user's setup?

**Environment**
- [ ] Does it assume specific tools without checking first?
- [ ] Does it use absolute paths instead of `$HOME` or `{skillDir}`?
- [ ] Does it fail on first run (missing dirs/files)?

**Logic**
- [ ] Does it enumerate specific items instead of discovering them dynamically?
- [ ] Does it assume a directory structure it didn't create itself?
- [ ] Does it hardcode cron times in a specific timezone without noting it?

---

## References

- [Google ADK 5 Skill Patterns](https://x.com/GoogleCloudTech/status/2033953579824758855) — original research, full notes in `workspace/research/google-adk-skill-patterns.md`
- [Generic Skills Guide](workspace/research/2026-03-22-generic-skills-guide.md) — deep research on portability patterns
- `soul-keeper/references/workspace-files.md` — workspace context file reference (bundled)
- `skill-creator/` — tooling for building, testing, and optimizing skills
