---
name: development
description: |
  Full-stack development workflow skill. Guides the complete cycle from understanding
  requirements to shipping code via PR with Preview validation.

  USE FOR:
  - Bug fixes, feature development, UI changes
  - "修复这个 bug", "帮我实现这个功能", "改一下这个页面"
  - "fix this", "implement", "build", "add feature", "change the UI"
  - Any code modification that needs Dev Server → PR → Preview → Merge flow

  REQUIRES: git, gh (GitHub CLI), pnpm/npm, agent-browser
metadata:
  openclaw:
    emoji: "🛠️"
    requires:
      bins: ["git", "gh", "pnpm", "agent-browser"]
---

# Development Workflow Skill

**Pattern: Pipeline** (Google ADK) — 理解问题 → 设计方案 → 实施 → Dev Server 验证 → PR → Preview → 用户验收 → Merge

## When to Use

Use when the user needs to **write, fix, or ship code** through a full dev workflow — from understanding the requirement to a merged PR. Typical triggers: bug reports, feature requests, UI changes, refactors, or any "帮我改一下" / "fix this" / "implement X" request.

**Don't use when:** The change is a one-liner config edit with no test needed, or the user just wants a code snippet without a PR. For quick edits, just write the code inline.

## Prerequisites

1. `git` installed and repo initialized
2. `gh` (GitHub CLI) installed and authenticated (`gh auth login`)
3. `pnpm` or `npm` available in the project
4. `agent-browser` available for E2E testing
5. Vercel or similar hosting for Preview deployments

## Quick Start

```bash
# 1. Start dev server
pnpm dev

# 2. Create a branch and make changes
git checkout -b fix/my-bug

# 3. Verify locally
pnpm tsc --noEmit && pnpm build

# 4. Create PR
git add . && git commit -m "fix: description"
git push -u origin fix/my-bug
gh pr create --title "fix: description" --body "What and why"
```

## Examples

### Example 1: Fix a UI bug

**User says:** "按钮点击后没有反应，帮我修一下"

**Steps:**
1. Reproduce the bug in Dev Server
2. Find the button handler code
3. Fix the logic
4. Test with `agent-browser`: click button → verify response
5. Commit and push branch
6. Create PR → share Preview URL

**Output:**
```
Branch: fix/button-click-handler
PR: https://github.com/user/repo/pull/42
Preview: https://my-app-fix-button.vercel.app
```

**Reply:** "Bug fixed ✅ PR #42 created. Preview link above — test it and say 'merge' when ready."

### Example 2: Add a new feature

**User says:** "帮我在首页加一个搜索框"

**Steps:**
1. Clarify: search scope, design, placeholder text
2. Create branch `feat/homepage-search`
3. Implement component
4. `pnpm dev` → `agent-browser` E2E test
5. `pnpm build` (no errors)
6. PR + Preview for user acceptance

## 核心方法论

### Dev Server vs Preview vs Production

```
┌─────────────────────────────────────────────────────────────┐
│ 环境              │ 用途           │ 谁用      │ 何时用     │
├─────────────────────────────────────────────────────────────┤
│ Dev Server        │ 快速迭代测试    │ Agent     │ 改代码后   │
│ (localhost:3000)  │ 模拟服务器行为  │           │ 立即测试   │
├─────────────────────────────────────────────────────────────┤
│ Preview           │ 真实环境验收    │ 用户      │ PR 创建后  │
│ (Vercel Preview)  │ 等同 Production │           │ 用户确认   │
├─────────────────────────────────────────────────────────────┤
│ Production        │ 线上环境       │ 最终用户   │ Merge 后   │
│ (ccl.lighttune)   │ 不可随意测试   │           │           │
└─────────────────────────────────────────────────────────────┘
```

### 正确的开发流程

```
1. 理解问题
   └─ 复现 bug / 明确需求

2. 设计方案
   └─ 考虑风险、性能、安全

3. 实施修改
   └─ 改代码

4. 本地验证 (Dev Server)
   ├─ TypeScript 编译
   ├─ pnpm build
   ├─ pnpm dev + 手动测试
   └─ agent-browser E2E 测试

5. 创建 PR
   └─ 推送分支 + gh pr create

6. 等待 Preview
   └─ Vercel 自动部署

7. 用户验收
   └─ 用户在 Preview 测试确认

8. Merge
   └─ 用户说 "merge" 后执行
```

### 关键原则

1. **不等 Preview，用 Dev Server**
   - Dev Server 我能立即控制
   - Preview 是给用户看的

2. **改代码后立即本地测试**
   - 不要只做编译检查
   - 要模拟真实使用

3. **我测 Dev，用户测 Preview**
   - 分工明确
   - Preview 通过 = 可以 merge

## 常见错误

| 错误 | 正确做法 |
|------|----------|
| 等 Preview 部署才测试 | 用 Dev Server 立即测试 |
| 只做编译检查 | 模拟真实用户操作 |
| Preview 失败就卡住 | Dev Server 验证逻辑正确 |
| 问用户"要不要测试" | 自己先测完再问 |

## 命令速查

```bash
# 启动 Dev Server
pnpm dev

# 编译检查
pnpm tsc --noEmit

# 构建测试
pnpm build

# E2E 测试 (agent-browser)
agent-browser open "http://localhost:3000"
agent-browser snapshot -i
agent-browser fill @e1 "value"
agent-browser click @e2

# 创建 PR
git checkout -b fix/xxx
git add . && git commit -m "fix: xxx"
git push -u origin fix/xxx
gh pr create --title "fix: xxx" --body "..."
```

## Error Handling

| Error | Cause | Solution |
|-------|-------|----------|
| `pnpm: command not found` | pnpm not installed | `npm install -g pnpm` |
| `gh: command not found` | GitHub CLI missing | `brew install gh && gh auth login` |
| TypeScript compile error | Type mismatch in code change | Fix types before pushing; run `pnpm tsc --noEmit` |
| Preview deployment fails | Build error on Vercel | Check Vercel dashboard logs; fix and repush |
| `agent-browser` test hangs | Dev server not running | Start `pnpm dev` first; ensure port 3000 is free |
| Merge conflict on PR | Branch out of date | `git fetch origin main && git rebase origin/main` |
