---
name: soul-keeper
description: |
  监测 workspace files 的更新时机，在正确的时候提示优化。基于 WORKSPACE_FILES_GUIDE.md 执行。

  USE FOR:
  - "更新 workspace files" / "改配置" / "优化文件" / "update workspace"
  - "帮我更新 SOUL.md" / "USER.md 要改" / "MEMORY.md 需要更新"
  - "记住这个偏好" / "把这个存下来" / "save this preference"
  - 用户纠正同类行为 2+ 次（自动触发）
  - 对话结束时（"好了"/"bye"/"今天就这样"）检查 workspace files
  - "workspace 文件整理" / "清理配置" / "audit workspace"

  **自动触发**：
  - 用户纠正同类行为 2+ 次 → SOUL.md 该更新了
  - 用户表达新偏好/新习惯 → USER.md 该更新了
  - 新项目启动或方向变化 → MEMORY.md / WORKING.md 该更新了
  - 新工具上线或旧工具出事 → TOOLS.md 该更新了
  - 新规则文件（docs/）出现 → AGENTS.md 索引该更新了
  - 项目完成或暂停 → WORKING.md 该归档了
  - 用户说"改 workspace files"、"更新配置"、"优化文件"
  - 对话中发现 workspace files 内容和现实不符

  **不触发**：
  - 一次性指令
  - 已在编辑 workspace files 中
---

# Workspace Optimizer

**Pattern: Reviewer**

> **First time?** Read `{skillDir}/SETUP.md` — it tells you exactly which files to create and where.
> **Reference:** `{skillDir}/references/workspace-files.md` — what each file does, token budgets, update triggers.

## When to Use

Use when the agent detects that **workspace files are out of sync with reality**: user corrects the same behavior twice, expresses a new preference, finishes a project, or explicitly asks to update config files. Also triggers at session end to batch-propose pending updates.

**Don't use when:** You're already mid-edit on a workspace file, or the change is a one-off instruction that doesn't need to persist.

## Prerequisites

- Workspace files exist at `~/.openclaw/workspace/` (or agent-specific workspace path)
- `{skillDir}/references/workspace-files.md` is readable (describes file roles and token budgets)
- `{skillDir}/SETUP.md` exists (first-time setup guide)
- Write access to workspace directory (to update files after user confirms)

## 核心理念

每个文件有自己的**自然更新节奏**，不是等用户抱怨才改。

## 各文件的 Trigger 表

| 文件 | 更新时机 | 信号 |
|------|---------|------|
| **SOUL.md** | Agent 行为需要调整 | 同类纠正 2+ 次；沟通风格变了；新边界 |
| **USER.md** | 用户情况变了 | 新方向；新偏好；新习惯；新设备/环境 |
| **AGENTS.md** | 工作流程变了 | 新 docs/ 规则文件；启动流程调整；新触发规则 |
| **TOOLS.md** | 工具链变了 | 新工具；旧工具出事；致命用法发现 |
| **MEMORY.md** | 世界状态变了 | 新项目；项目完结；新环境配置 |
| **WORKING.md** | 项目进度变了 | 实质进展；新项目；项目暂停/完成 |
| **IDENTITY.md** | 几乎不变 | 改名；改定位 |
| **HEARTBEAT.md** | 检查清单变了 | 新定时任务；旧任务移除 |

## 触发后流程

### 1. 读写作指南

必须先读：`{skillDir}/references/workspace-files.md`

### 2. 读取对应文件

根据 trigger 类型读对应文件。

### 3. 对比分析

- 文件内容是否和现实一致？
- 该加的信息放哪个文件？（根据 Guide 职责划分）
- 加了会不会超 token 预算？
- 有没有旧内容该删/归档？

### 4. 输出建议

```
📝 [文件名] 该更新了

原因：[什么 trigger 了这次检查]
现在：[当前相关内容]
建议：[具体修改]

要更新吗？
```

### 5. 确认后执行

- 用户确认 → 执行修改
- 用户拒绝 → 记录到 memory/ 留底

---

## 主动检查场景

除了被动 trigger，以下场景**主动检查**：

1. **新项目讨论完毕** → 检查 MEMORY.md 和 WORKING.md 是否需要加项目
2. **一轮深度对话结束** → 检查有没有新发现该落进 USER.md 或 SOUL.md
3. **新 docs/ 文件创建后** → 检查 AGENTS.md 索引是否需要加入
4. **安装新 Skill 后** → 检查 TOOLS.md 是否需要加规则
5. **用户明显改变沟通风格** → 检查 USER.md 是否需要更新偏好

---

## 清理审计（Cleanup Audit）

**每 ~20 轮对话或用户说"done"/"完成"/"做完了"时触发：**

检查以下内容，发现有积压就提醒：

1. **Cron 孤儿** — 有没有已完成任务对应的 cron 还没删？
   - 提示用户：`openclaw cron list` 查看，完成的手动 rm
   
2. **任务追踪文件积压** — workspace 里的 DECISIONS.md、TODO.md、backlog 等有没有已完成未归档的条目？
   - 完成的条目 → 移进 `memory/YYYY-MM-DD.md`，从文件里删掉

3. **pending-updates.md 积压** — 有没有超过 7 天未处理的条目？
   - 提醒用户处理或主动清除

**输出格式：**
```
🧹 清理提醒

发现以下积压：
- Cron: N 个可能已完成（`openclaw cron list` 确认）
- DECISIONS.md: 有 N 条已完成条目未归档
- pending-updates.md: 有 N 条超过 7 天未处理

现在清理吗？
```

**Generic 原则：** 只检查实际存在的文件，不假设文件结构。跳过不存在的文件。

---

## 规则

1. **不自动改文件** — 必须用户确认
2. **一次只建议改一个文件**（结束钩子例外，最多3个）
3. **遵守 Guide 的职责划分和 token 预算**
4. **检查重复** — 已有类似内容不重复加
5. **该删也提** — 过时内容建议删除或归档
6. **措辞匹配** — 新内容风格和文件现有内容一致

---

## N-Turn 心跳（主动审计）

**每 ~10 轮对话**，静默检查一次：
- 对话中有没有新工具/新决定/新偏好没有落进 workspace files？
- 如果有 → 按正常流程输出建议
- 如果没有 → 不打扰，静默跳过

---

## Session 结束钩子

检测到以下信号时触发：
- 用户说："好了"、"bye"、"今天就这样"、"没了"、"先这样"、"结束"
- Context 接近上限（通常 agent 会主动告知）

触发后：
1. 回顾整个对话，整理出所有待更新的 workspace files
2. **批量推送**，最多3个，格式：

```
📋 今天有 N 个文件建议更新，一起处理吗？

1. TOOLS.md — 加 research-pro 架构、skills-watchdog
2. WORKING.md — skills 重构完成，建议归档
3. MEMORY.md — 已更新 ✅（跳过）

确认更新 1 和 2？
```

3. 用户确认 → 依次执行
4. 用户拒绝或忽略 → 写入 `pending-updates.md`

---

## Pending Updates 管理

**写入时机：** 建议被忽略或对话结束时未处理
**文件路径：** `~/.openclaw/workspace/pending-updates.md`
**格式：**
```
- [ ] 2026-03-22 TOOLS.md: 加 skills-watchdog 说明
- [ ] 2026-03-22 WORKING.md: skills 重构归档
```

**读取时机：** 每次新 session 开始时检查，有 pending 就提醒：
```
📌 上次有 2 个建议没处理，现在做吗？
· TOOLS.md — 加 skills-watchdog
· WORKING.md — 归档 skills 重构
```

## Token 预算

| 文件 | 最大 |
|------|------|
| SOUL.md | 800B |
| USER.md | 800B |
| IDENTITY.md | 300B |
| AGENTS.md | 1.5KB |
| TOOLS.md | 1KB |
| MEMORY.md | 1.5KB |

## Examples

### Example 1: User corrects same behavior twice → update SOUL.md

**Trigger:** User has twice asked the agent to stop adding bullet points when summarizing.

**Agent output:**
```
📝 SOUL.md 该更新了

原因：用户两次纠正同类行为（摘要用了 bullet points）
现在：SOUL.md 中无相关约束
建议：在 SOUL.md 加入 "摘要默认用段落，不用 bullet points"

要更新吗？
```

**User:** "是的更新"

**Agent:** Reads SOUL.md → appends the new rule → confirms update.

### Example 2: Session end batch update

**Trigger:** User says "好了，今天就这样"

**Agent output:**
```
📋 今天有 2 个文件建议更新，一起处理吗？

1. USER.md — 加入新偏好：深色模式 + 简体中文界面
2. WORKING.md — skills 重构完成，建议归档

确认更新 1 和 2？
```

## Error Handling

| Error | Cause | Solution |
|-------|-------|----------|
| Workspace file not found | 文件路径不存在或首次使用 | 先读 `{skillDir}/SETUP.md` 创建初始文件结构 |
| Write permission denied | workspace 目录无写权限 | 检查目录权限：`ls -la ~/.openclaw/workspace/` |
| File exceeds token budget | 内容超出 token 限制 | 归档旧内容到 `memory/YYYY-MM-DD.md`，删除过期条目 |
| `pending-updates.md` missing | 首次运行或文件被删除 | 自动创建文件，格式见上方 Pending Updates 管理 |
| Conflicting updates proposed | 两次建议修改同一字段 | 合并成一次建议；先读当前内容再更新 |
