# Upgrade Plan: agent-browser

## Pattern: Tool Wrapper
## 理由: 该 skill 封装了 `agent-browser` CLI 工具，按需加载其命令/能力供 AI agent 调用。

## 缺少的文件
- [ ] README.md
- [ ] _meta.json
- [ ] evals/evals.json
- [ ] SKILL.md Pattern 标注

## README 要点
- 工具原理：agent-browser 是基于 Playwright 的无 token 消耗浏览器 CLI，snapshot -i 返回文字 DOM ref
- 与 browser-use / browser 内置工具的区别（三者能力矩阵，独占能力：视频录制、iOS 模拟器、地理位置）
- Ref 生命周期说明：页面跳转/DOM 变化后必须重新 snapshot
- 常见工作流模板：表单填写、登录态持久化（state save/load）、数据提取、并行 session
- 限制说明：不支持 AI 自主模式（用 browser-use run）、不支持云端远程浏览器

## Evals 测试用例（草案）
- eval 1: "打开 https://example.com 并截图保存到 /tmp/test.png" → 应调用 `agent-browser open` + `agent-browser screenshot /tmp/test.png`
- eval 2: "登录 https://app.example.com，填写邮箱 user@test.com 和密码 pass123，点击提交" → 应使用 snapshot -i 获取 ref，再 fill + click
- eval 3: "用两个并行 session 分别打开 site-a.com 和 site-b.com，各自截图" → 应使用 `--session site1` / `--session site2`
