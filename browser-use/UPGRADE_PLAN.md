# Upgrade Plan: browser-use

## Pattern: Tool Wrapper
## 理由: 该 skill 封装了 `browser-use` CLI 工具，暴露其导航、交互、截图、AI agent 模式等能力，属于对外部 CLI 工具的包装。

## 缺少的文件
- [ ] README.md
- [ ] _meta.json
- [ ] evals/evals.json
- [ ] SKILL.md Pattern 标注

## README 要点
- 四种 browser 模式对比：chromium（默认无头）/ real（本地 Chrome）/ remote（云端）/ real+profile（复用登录态）
- AI 自主 agent 模式（run "task"）的使用场景：何时选 browser-use run 而非手动 click/fill 步骤
- 云端 session 生命周期管理：task vs session 的区别，keep-alive 的正确使用，停止后不可复用的注意事项
- Profile 同步工作流：先 list → 确认 domain → sync → 用 profile id 启动，不要默认全量 sync
- Token 效率：task status 默认最小输出，长任务用 --last 5 / --step N，截图存文件不消耗 token

## Evals 测试用例（草案）
- eval 1: "用 browser-use 打开 https://github.com 并获取首页标题" → 应调用 `browser-use open` + `browser-use state` 或 `browser-use get title`
- eval 2: "用云端浏览器自动搜索 'AI news 2026' 并返回前三条结果" → 应使用 `browser-use -b remote run "..."` 异步模式 + task status 轮询
- eval 3: "需要用我的 GitHub 登录状态来查看私有仓库" → 应先 `browser-use -b real profile list`，询问用户选哪个 profile，再 `browser-use -b real --profile "Default" open <url>`
