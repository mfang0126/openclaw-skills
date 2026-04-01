---
user-invocable: false
name: multi-agent
description: Orchestrate parallel and serial multi-agent task pipelines. Use when user says "multi-agent", "parallel processing", "assign to agent", "use multiple agents", "team collaboration", or asks researcher/content/tech-lead/verifier to do something.
---

# Multi-Agent 调度 Skill

**Pattern: Pipeline** (Google ADK) — Route → Spawn → Coordinate → Collect → Report

> 当用户要求"用多智能体"/"并行处理"/"分配给 agent" 时，读取此文件。

## USE FOR
- "use multi-agent to..."
- "assign this to the researcher"
- "parallel processing"
- "分配任务给 agent"
- "让 researcher/content/tech-lead/verifier 去做"
- "multi-agent pipeline"
- "run this in parallel"
- "team collaboration"

## REPLACES
- N/A

## REQUIRES
- OpenClaw multi-agent support (`sessions_spawn` tool)
- Discord bot configured for each agent
- Agent IDs configured in openclaw.json: researcher, content, tech-lead, product-owner, verifier

## When to Use

Use when a task requires multiple specialized agents OR when parallelism would save significant time.

**Do NOT use** for simple tasks a single agent can handle — overhead is not worth it.

Trigger keywords: multi-agent, parallel, assign to agent, researcher, content, tech-lead, verifier.

## Prerequisites

- Agents configured in openclaw.json: researcher, content, tech-lead, product-owner, verifier
- Discord channels set up for each agent (see Agent Roster table)
- `sessions_spawn` tool available

## Quick Start

```javascript
// Parallel (independent tasks)
sessions_spawn(agentId="researcher", task="Research X")
sessions_spawn(agentId="content", task="Write outline for Y")

// Serial (dependent tasks)
// 1. Spawn researcher
sessions_spawn(agentId="researcher", task="Research X")
// 2. Wait for result, then spawn content with researcher output
sessions_spawn(agentId="content", task="Write based on: {result}")
```

---

## Agent 清单

| Agent | agentId | 擅长 | Discord accountId | Discord 频道 ID |
|-------|---------|------|-------------------|----------------|
| Researcher | `researcher` | 深度调研、技术分析、竞品对比、数据收集 | `researcher` | `1476322844760871160` |
| Content Writer | `content` | 博客、LinkedIn、文案、技术写作 | `content` | `1475052382151774270` |
| Tech Lead | `tech-lead` | 任务拆解、技术方案、代码架构 | `tech-lead` | `1475052380444692592` |
| Product Owner | `product-owner` | User Story、需求拆解、验收标准 | `product-owner` | `1475052378351730812` |
| Verifier | `verifier` | 独立验证、QA、验收标准检查 | `verifier` | `1476322704964452564` |
| King | `king` | Discord #常规 入口（用户在 Discord 时的调度员） | `king` | `1475051197978247244` |

---

## 调用方式

### 并行独立任务（首选）
多个互不依赖的任务同时跑：
```
sessions_spawn(agentId="researcher", task="研究 X", mode="run")
sessions_spawn(agentId="content", task="写 Y 大纲", mode="run")
// 两个同时执行，互不等待
```

### 串行依赖任务
一个的输出是另一个的输入：
```
1. sessions_spawn(agentId="researcher", task="研究 X", mode="run")
2. 等 researcher 结果回来
3. sessions_spawn(agentId="content", task="用以下研究写文章: {researcher的结果}", mode="run")
```

### Discord 留痕（每个 spawn 任务必须包含）
在 task 指令末尾加：
```
完成后用 message 工具发到 Discord：
- action: "send"
- channel: "discord"
- accountId: "{该 agent 的 accountId}"
- target: "channel:{该 agent 的频道 ID}"
- message: "{进度或结果摘要}"
```

---

## 任务路由表

| 用户意图 | 用谁 | 模式 |
|---------|------|------|
| 研究/调研/搜索/分析/找资料 | researcher | 单 agent |
| 写文章/博客/LinkedIn/文案 | content | 单 agent |
| 先研究再写文章 | researcher → content | 串行 |
| 拆需求/User Story/产品规划 | product-owner | 单 agent |
| 技术方案/代码架构/任务拆解 | tech-lead | 单 agent |
| 验证/检查/QA/验收 | verifier | 单 agent |
| 需求到上线（全流程） | PO → TL → Verifier | 串行 |
| 同时研究多个话题 | N × researcher | 并行 |
| 研究 + 写大纲 + 竞品（各自独立） | researcher + content | 并行 |

---

## 关键规则

1. **并行 = 互不依赖**。有依赖必须串行（先完成 A 再用 A 结果给 B）。
2. **每个 spawn 都加 Discord 留痕指令**。用户想在 Discord 看到过程。
3. **最多 8 个并行**（maxConcurrent: 8）。
4. **不要让 agent 互相 sessions_send**。由 main 中转结果。
5. **简单任务自己干**。不要为了用 agent 而用 agent — 一个搜索、一个小修改，main 直接做更快。
6. **结果汇总回复用户**。所有 agent 完成后，main 发一条简洁汇总。

---

## Examples / 示例

**User says:** "用 3 个 agent 并行研究这 3 个竞品" → Steps: spawn 3 `researcher` sub-agents in parallel, each targeting one competitor → Output: 3 separate research reports returned via sessions_yield → Reply: "✅ 3 份竞品报告已完成：[竞品A摘要] / [竞品B摘要] / [竞品C摘要]"

---

用户："帮我用多智能体研究 MCP 协议然后写一篇博客"

```
main 思考：
  - 研究 = researcher（先）
  - 写博客 = content（后，依赖研究结果）
  - 模式 = 串行

执行：
  1. sessions_spawn(agentId="researcher", mode="run", task="""
     研究 MCP 协议的最新发展，包括：
     - 核心概念和架构
     - 主流实现（Anthropic, OpenAI, Google）
     - 社区采用情况和评价
     - 与其他方案的对比
     
     完成后用 message 工具发到 Discord：
     action=send, channel=discord, accountId=researcher, 
     target=channel:1476322844760871160, message=研究摘要
  """)
  
  2. 收到 researcher 结果后 →
  
  sessions_spawn(agentId="content", mode="run", task="""
     用以下研究结果写一篇博客文章：
     {researcher 的完整结果}
     
     要求：Ming 的风格（直接、实用、有代码示例）
     平台：example.com blog
     
     完成后用 message 工具发到 Discord：
     action=send, channel=discord, accountId=content,
     target=channel:1475052382151774270, message=文章摘要+路径
  """)
  
  3. 汇总回复用户：
     "✅ MCP 博客完成 · 研究 + 写作 · 文件路径"
```

## Error Handling

| Error | Cause | Fix |
|-------|-------|-----|
| Agent not responding | Sub-agent stalled or crashed | Check sessions_history, re-spawn or do inline |
| Discord message not sent | Bot token issue or wrong channel ID | Verify accountId and channel ID in agent roster |
| Result never arrives | Missing sessions_yield | Ensure sub-agent calls sessions_yield |
| Wrong agent used | Misrouted task | Consult task routing table before spawning |
| Timeout after 5 min | Agent hung silently | Watchdog fires — take over inline |
