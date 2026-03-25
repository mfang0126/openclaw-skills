# Upgrade Plan: content-inbox

## Pattern: Pipeline
## 理由: 固定步骤：检测链接 → 后台下载 → 询问用户 → 执行动作 → 学习偏好

## 缺少的文件
- [ ] _meta.json
- [ ] evals/evals.json
- [ ] SKILL.md Pattern 标注（当前无 "Pattern: Pipeline" 标签）

## README 要点
- README.md 已存在，但缺少设计决策说明（为什么用 4 层配置系统）
- 缺少与相关 skills 的集成说明（douyin-dl、video-analyzer 的调用边界）
- 缺少 Non-blocking 模式的架构图示
- 缺少"学习机制"触发阈值（3次/5次规则）的详细说明
- 缺少 `_meta.json` 所对应的 version 和 tags 信息

## Evals 测试用例（草案）
- eval 1: 用户发送 `https://v.douyin.com/abc123/`，无其他文字 → 应立即触发下载并询问处理方式 A/B/C/D
- eval 2: 用户发送抖音链接后回复 "B"（转写）→ 应派 subagent 转写并回复"开始转写...预计5分钟"
- eval 3: 用户连续3次选择 "D"（写博客）→ 应询问是否将"写博客"设为默认动作
