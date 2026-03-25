# Upgrade Plan: moonshot-usage

> Generated: 2026-03-25 | SOP Version: 1.0

## Pattern Classification

**Pattern: Tool Wrapper**
> "Load knowledge/data on demand" — wraps the Moonshot API balance endpoint and surfaces results to the user on request.

## Current State

| File | Status |
|------|--------|
| SKILL.md | ✅ Exists (incomplete) |
| README.md | ❌ Missing |
| _meta.json | ❌ Missing |
| evals/evals.json | ✅ Exists |
| scripts/balance.sh | ✅ Exists |

**Missing files: 2** (README.md, _meta.json)

## SKILL.md Issues

SKILL.md exists but is missing multiple required sections:

| Check | Status |
|-------|--------|
| `name` + `description` frontmatter | ✅ |
| Description is pushy with trigger keywords | ✅ |
| `USE FOR:` section | ❌ Missing |
| `REPLACES:` | ❌ Missing (or explicitly N/A) |
| `REQUIRES:` dependencies | ❌ Missing |
| Pattern label (`**Pattern: Tool Wrapper**`) | ❌ Missing |
| `When to Use` section | ❌ Missing |
| `Prerequisites` section | ❌ Missing |
| `Quick Start` | ✅ Exists |
| `Instructions` / logic | ⚠️ Partial (just "Calls API" + script name) |
| At least 1 complete `Example` | ⚠️ Partial (output shown, not full example) |
| `Error Handling` table | ❌ Missing |
| < 500 lines | ✅ |

## Action Items

### Priority 1 — Fix SKILL.md

**Add pattern label** (after the h1 heading):
```markdown
**Pattern: Tool Wrapper**
```

**Add USE FOR: section:**
```markdown
## USE FOR
- "check my moonshot balance"
- "how much moonshot credit do I have left?"
- "moonshot usage"
- "kimi balance"
- "查 moonshot 余额"
- "moonshot 还有多少钱"
```

**Add REQUIRES: section:**
```markdown
## REQUIRES
- `MOONSHOT_API_KEY` environment variable (set in `~/.openclaw/openclaw.json`)
- `curl` or `scripts/balance.sh`
```

**Add Prerequisites section:**
```markdown
## Prerequisites
- Moonshot API key configured in openclaw.json
- Internet access to `api.moonshot.ai`
```

**Add When to Use section:**
```markdown
## When to Use
Use when user asks about Moonshot AI API credit, balance, spending, or usage.
Trigger keywords: moonshot balance, moonshot usage, kimi balance, 余额, credit left.
```

**Add Error Handling table:**
```markdown
## Error Handling

| Error | Cause | Fix |
|-------|-------|-----|
| `401 Unauthorized` | Invalid or missing API key | Check `MOONSHOT_API_KEY` in openclaw.json |
| `curl: command not found` | curl not installed | `brew install curl` or `apt install curl` |
| Empty response | Network issue | Check internet connection, retry |
| `code != 0` in response | API error | Check Moonshot status page |
```

**Expand Instructions section** with actual script logic:
```markdown
## Instructions
1. Load `MOONSHOT_API_KEY` from environment
2. Call `GET https://api.moonshot.ai/v1/users/me/balance`
3. Parse JSON: `data.available_balance`, `data.cash_balance`, `data.voucher_balance`
4. Format and display to user
```

### Priority 2 — Verify scripts/balance.sh

Check that:
- [ ] Script is executable (`chmod +x`)
- [ ] Works headless (no GUI)
- [ ] Reads `MOONSHOT_API_KEY` from env correctly
- [ ] Formats output cleanly

### Priority 3 — Create _meta.json

```json
{
  "name": "moonshot-usage",
  "version": "1.0.0",
  "author": "King",
  "pattern": "Tool Wrapper",
  "emoji": "🌙",
  "created": "2026-03-25",
  "requires": {
    "bins": ["curl"],
    "modules": [],
    "env": ["MOONSHOT_API_KEY"]
  },
  "tags": ["moonshot", "kimi", "balance", "usage", "api"]
}
```

### Priority 4 — Create README.md

Cover:
- How the Moonshot balance API works
- Why this is a Tool Wrapper (on-demand query, not a pipeline)
- Authentication approach (env var via openclaw.json)
- Limitations (read-only, no usage history, just current balance)
- Related skills: any other API key / credit check skills

## Final Checklist

- [ ] SKILL.md updated: pattern label, USE FOR, REQUIRES, Prerequisites, When to Use, Instructions expanded, Error Handling
- [ ] Pattern labeled as **Tool Wrapper**
- [ ] scripts/balance.sh verified executable and headless
- [ ] evals/evals.json already exists — verify ≥ 3 test cases
- [ ] _meta.json created
- [ ] README.md created
- [ ] `openclaw config validate` passes
