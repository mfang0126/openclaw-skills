# Upgrade Plan: claude-usage

## Pattern: Tool Wrapper
## 理由: 该 skill 封装了 Claude Code CLI 的 `/usage` 命令（通过 tmux 自动化），将其包装成可程序化调用的工具，属于对外部 CLI 的工具包装。

## 缺少的文件
- [ ] README.md
- [ ] _meta.json
- [ ] evals/evals.json
- [ ] SKILL.md Pattern 标注

## README 要点
- 工作原理：tmux session → git init scratch repo → claude CLI → /usage 命令 → 解析输出 → 清理 session
- 与 API billing 工具的本质区别：本工具查的是订阅剩余量（Max/Pro），而非 API token 花费
- 触发场景：rate limit 诊断、配额焦虑、Claude 响应变慢时的第一个排查步骤
- 依赖要求及验证：tmux、claude CLI、git 均需在 PATH，auth 须有效；附快速验证命令
- 已知限制：~8-10s 冷启动、输出格式依赖 CLI 版本（Anthropic 改格式则脚本可能失效）

## Evals 测试用例（草案）
- eval 1: "我还剩多少 Claude 用量？" → 应触发该 skill，调用 `bash scripts/check-usage.sh`，输出 plan 类型 + session % + weekly % + reset 时间
- eval 2: "Claude 最近响应很慢，是不是被限速了？" → 应识别为配额诊断场景，先运行 check-usage，根据剩余量给出建议
- eval 3: "查一下我的 claude 用量，还能用吗" → 中文触发词测试，应正确触发 skill 而非回答关于 claude API billing 的问题
