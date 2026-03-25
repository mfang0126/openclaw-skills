# Upgrade Plan: html-screenshot

## Pattern: Tool Wrapper
## 理由: 包装 agent-browser CLI，检测视觉变更后按需调用截图并发送到对应频道

## 缺少的文件
- [ ] _meta.json（虽然 SKILL.md frontmatter 中有 metadata.openclaw，但独立 _meta.json 文件缺失）
- [ ] evals/evals.json
- [ ] SKILL.md Pattern 标注（当前无 "Pattern: Tool Wrapper" 标签）
- [ ] README.md 符合 SOP 规范（已有多个 README 变体，但无标准 README.md 结构）

## README 要点
- 工作原理：调用 scripts/screenshot.sh → agent-browser 启动 Chromium 渲染 → 保存 PNG → 按频道发送
- 设计决策：为什么区分 Telegram（宽松触发）vs Browser/Terminal（严格触发）——用户在不同频道查看本地文件的能力不同
- 频道适配逻辑（telegram → message tool / webchat → Read tool / 其他 → 返回路径）
- 视觉变更 vs 非视觉变更的判断标准（附正反例）
- 局限性：仅支持静态 HTML，不支持需要后端交互的页面；截图为确定性渲染（相同 HTML = 相同图片）

## Evals 测试用例（草案）
- eval 1: 用户在 Telegram 频道修改了 HTML 背景颜色 → 应自动截图并通过 message tool 发送图片到 Telegram，无需用户说"截图"
- eval 2: 用户说"看看效果"并提供 /tmp/design.html → 应调用 screenshot.sh 并在当前频道展示截图
- eval 3: agent-browser 未运行（截图失败）→ 应回复标准错误信息（截图失败 + 文件路径 + 是否重试），不应静默失败
