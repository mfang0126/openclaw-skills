# development

> Full-stack development workflow: from bug report or feature request to merged PR, with proper testing at every step.

## Install

Already installed at `~/.openclaw/skills/development/`. Requires `git`, `gh`, `pnpm`, and `agent-browser`.

## Usage

Just describe the task:

```
登录按钮点击无响应
帮我实现 CSV 导出功能
修复一下这个 layout bug
```

## How It Works

**Pattern: Pipeline** (Google ADK)

```
1. Understand Problem
   └─ Reproduce bug / Clarify requirements

2. Design Solution
   └─ Identify files → consider risks, performance, security

3. Implement
   └─ Write / modify code

4. Local Validation (Dev Server)
   ├─ pnpm tsc --noEmit (type check)
   ├─ pnpm build (build check)
   ├─ pnpm dev (start server)
   └─ agent-browser E2E test (simulate real usage)

5. Create PR
   └─ git checkout -b fix/xxx → commit → gh pr create

6. Wait for Preview
   └─ Vercel auto-deploys the PR branch

7. User Acceptance
   └─ User tests on Preview URL

8. Merge
   └─ User says "merge" → execute
```

## Three-Environment Model

| Environment | Purpose | Who Uses It | When |
|-------------|---------|-------------|------|
| **Dev Server** (`localhost:3000`) | Fast iteration, immediate feedback | Agent | After every code change |
| **Preview** (Vercel PR preview) | Real-environment validation | User | After PR is created |
| **Production** (`ccl.lighttune` etc.) | Live users | End users | After merge |

**Key principle**: The Agent tests on Dev Server. The User validates on Preview. Never skip steps.

## Why Dev Server First?

- **Immediate feedback**: No waiting for Vercel to deploy (30s–2min)
- **Agent-controlled**: Can simulate clicks, form fills, navigation
- **Cheap to iterate**: Fix → test → fix → test in seconds
- **Preview is for users**: It's their validation environment, not yours

## agent-browser E2E Testing

```bash
# Start dev server first
pnpm dev &

# Then test with agent-browser
agent-browser open "http://localhost:3000"
agent-browser snapshot -i                    # Take a snapshot
agent-browser fill @e1 "test@example.com"   # Fill a form field
agent-browser click @e2                      # Click a button
agent-browser snapshot -i                    # Verify result
```

## PR Conventions

```bash
# Branch naming
fix/login-button-unresponsive
feature/csv-export
chore/update-dependencies

# Commit message
git commit -m "fix: login button now responds to click events"
git commit -m "feat: add CSV export for dashboard data"

# PR creation
gh pr create \
  --title "fix: login button unresponsive" \
  --body "## Problem\n...\n## Solution\n...\n## Testing\n- Tested on Dev Server\n- E2E: login flow passes"
```

## Common Pitfalls

| Wrong | Right |
|-------|-------|
| Waiting for Preview to test | Use Dev Server immediately |
| Only running `pnpm tsc` | Simulate real user operations |
| Merging without user confirmation | Always wait for user to say "merge" |
| "Preview failed" → start reverting | Verify on Dev Server first; Preview failure ≠ code bug |
| Asking "do you want me to test?" | Test first, then report results |

## Limitations

- Requires project to use pnpm (or adapt commands for npm/yarn)
- E2E testing via agent-browser requires the browser tool to be available
- Does not handle database migrations automatically — flag these explicitly
- Production deploys only happen after explicit user approval

## Related Skills

- `agent-browser` — Interactive browser automation for E2E tests
- `deploy-artifact` — Deploy static files for review without a full PR
- `html-screenshot` — Visual preview of UI changes
