# Upgrade Plan: browser-routing

## Pattern: Inversion
## 理由: 该 skill 的核心作用是「在开始任何浏览器任务前，先收集信息（任务类型、是否需要登录态、token 成本要求）来决定使用哪个工具」，是典型的先问后做 Inversion 模式。

## 缺少的文件
- [ ] README.md
- [ ] _meta.json
- [ ] evals/evals.json
- [ ] SKILL.md Pattern 标注

## README 要点
- 设计哲学：为什么需要统一路由层——三大浏览器工具重叠功能多，不路由则乱选导致 token 浪费
- 决策树详解：5 秒判断的 9 个分支，每个分支的理由（web_fetch 零 token 首选原则）
- Token 成本排序说明：10 级成本梯度，截图为何是最后手段
- 独占能力速查：agent-browser（录制/iOS/地理位置）vs browser-use（AI 自主/远程/代理）vs browser 内置（OpenClaw cookie）
- 常见错误模式：截图看文字、截图检查登录状态等反模式及纠正方案

## Evals 测试用例（草案）
- eval 1: "帮我打开 https://news.ycombinator.com 看今天的头条" → 应路由到 web_fetch（纯文字读取，零 token）
- eval 2: "帮我登录 Gmail 查看未读邮件" → 应路由到 browser + profile="user"（需要用户已有登录态）
- eval 3: "自动帮我填写这个招聘网站的申请表单，页面很复杂" → 应路由到 browser-use run "task"（AI 自主完成复杂任务）
