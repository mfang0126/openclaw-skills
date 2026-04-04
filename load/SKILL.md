---
name: load
description: 检查 agent 是否已加载 bootstrap 文件
user-invocable: true
---

# Load Skill

检查 bootstrap 文件加载状态。

## 执行步骤

1. 读取 `BOOTSTRAP-CHECK.md`（如果存在）
2. 按 progressive disclosure 检查每一级：
   - **Level 1**：用户是谁、我是谁、当前模型
   - **Level 2**：核心规则（SOUL.md 关键点）
   - **Level 3**：当前项目状态（working.md）
   - **Level 4**：最近记忆（memory/ 最新文件）
3. 先报告已知信息，不知道的现场读取
4. 最后给出简洁状态卡

## 输出格式

```
✅ /load 检查完成

**已知：**
- 用户：[名字]
- 我：[身份]
- 模型：[当前模型]

**状态：** [已加载 / 部分加载 / 需要读取]
```
