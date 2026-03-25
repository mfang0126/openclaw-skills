# 反思触发机制

## 自动触发

### 1. Heartbeat 检查 (每 30 分钟)
在 `HEARTBEAT.md` 添加：
```markdown
## 🔄 开发反思检查
- 最近有代码任务吗？
- 是否遵循了 Dev Server → Preview 流程？
- 有工具使用教训吗？
```

### 2. Cron 深度反思 (每天 22:00)
```python
cron(
  schedule="0 22 * * *",  # 每天 22:00
  task="""
  读取 memory/YYYY-MM-DD.md
  提取今日教训：
  - 工具选择错误
  - 流程遗漏
  - 成功经验
  
  更新：
  - REFLEXION_LOG.md (最近 5 条)
  - skills/development/SKILL.md (如有新发现)
  - MEMORY.md (重要决策)
  """
)
```

### 3. 任务完成时自动反思
每个开发任务完成后，Developer Agent 自动：
```markdown
## 任务反思
- 流程是否正确？
- 有什么可以改进？
- 需要更新哪些文档？
```

---

## 反思模板

### 工具/流程教训
```markdown
## YYYY-MM-DD: [简短标题]

**场景**: xxx
**问题**: xxx
**正确做法**: xxx
**更新文件**: [SKILL.md | TOOLS.md | AGENTS.md]
```

### 成功经验
```markdown
## YYYY-MM-DD: [简短标题]

**场景**: xxx
**做对了什么**: xxx
**可以复用**: xxx
```

---

## 反思检查清单

### 开发任务后
- [ ] 是否用了 Dev Server 测试？
- [ ] 是否在等 Preview 前完成了本地验证？
- [ ] 是否有新的工具使用教训？

### Sub-Agent 任务后
- [ ] 角色选择是否正确？
- [ ] 输出格式是否符合预期？
- [ ] 协调流程是否顺畅？

### 每日总结
- [ ] 今日 REFLEXION_LOG 有新条目吗？
- [ ] 需要更新 SKILL.md 吗？
- [ ] 需要更新 MEMORY.md 吗？
