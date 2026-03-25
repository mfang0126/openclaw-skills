# 使用指南

## 如何 Spawn 角色化 Agent

### Developer Agent
```python
sessions_spawn(
  task=f"""
你是 Developer Agent。

{read("skills/development/templates/developer-agent.md")}

---

任务: {具体任务}
项目: {项目路径}
上下文: {相关信息}
输出到: .problem-solving/IMPLEMENTATION.md
""",
  label="developer",
  model="moonshot/kimi-k2.5"  # 代码任务用 Kimi
)
```

### Architect Agent
```python
sessions_spawn(
  task=f"""
你是 Architect Agent。

{read("skills/development/templates/architect-agent.md")}

---

问题: {问题描述}
代码位置: {相关文件}
输出到: .problem-solving/SOLUTION_DESIGN.md
""",
  label="architect",
  model="anthropic/claude-opus-4-5"  # 架构设计用 Opus
)
```

### Tech Lead Agent
```python
sessions_spawn(
  task=f"""
你是 Tech Lead Agent。

{read("skills/development/templates/tech-lead-agent.md")}

---

任务: 协调 {问题} 的解决
状态文件: .problem-solving/
参与 Agent: architect, developer
""",
  label="tech-lead",
  model="anthropic/claude-sonnet-4-5"  # 协调用 Sonnet
)
```

## 完整流程示例

```python
# 1. Tech Lead 启动，评估问题
spawn("tech-lead", task="评估问题，决定是否需要 Architect")

# 2. 如需设计，启动 Architect
spawn("architect", task="分析问题，设计方案")

# 3. 方案确定后，启动 Developer
spawn("developer", task="按方案实施，本地测试")

# 4. Tech Lead 汇总，创建 PR
spawn("tech-lead", task="汇总结果，创建 PR")

# 5. 通知用户看 Preview
notify_user("PR 已创建，请在 Preview 验收")
```

## 共享状态目录

```
.problem-solving/
├── 0-TASK.md              # 任务描述
├── 1-PROBLEM_ANALYSIS.md  # Architect: 问题分析
├── 2-SOLUTION_DESIGN.md   # Architect: 方案设计
├── 3-IMPLEMENTATION.md    # Developer: 实施报告
├── 4-TEST_REPORT.md       # Developer: 测试报告
├── 5-PR_INFO.md           # PR 信息
└── COORDINATOR.md         # 协调状态
```

## 反思记录

每次使用后更新 `REFLEXION_LOG.md`:
- 什么做得好？
- 什么可以改进？
- 发现了什么新问题？
