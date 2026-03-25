# Upgrade Plan: ai-sdk

## Pattern: Tool Wrapper
## 理由: 该 skill 封装了 Vercel AI SDK 的文档和 API，按需检索 node_modules 或在线文档为 AI 提供最新用法，属于知识加载型工具包装。

## 缺少的文件
- [ ] README.md
- [ ] _meta.json
- [ ] evals/evals.json
- [ ] SKILL.md Pattern 标注

## README 要点
- 核心原则：绝不信任内训知识，始终从 `node_modules/ai/docs/` 或 ai-sdk.dev 检索当前 API
- 版本差异：ai@6.0.34+ 有本地 docs；早期版本走在线搜索；如何判断版本及切换检索策略
- Provider 选择：默认用 Vercel AI Gateway，获取最新 model ID 的 curl 命令
- Agent 构建规范：ToolLoopAgent 模式、type-safe-agents、InferAgentUIMessage
- 常见错误快查：parameters→inputSchema 等重命名，`useChat` 破坏性变更，typecheck 失败处理流程

## Evals 测试用例（草案）
- eval 1: "用 AI SDK 写一个 generateText 调用 claude-sonnet 的示例" → 应先检索 node_modules/ai/docs/ 获取当前 API，再用 AI Gateway provider，不能从记忆直接写代码
- eval 2: "我的项目用 useChat 报错 'messages is not a function'，怎么修" → 应先查 references/common-errors.md，识别为 useChat 破坏性变更
- eval 3: "帮我给 Next.js 项目添加流式 AI 聊天功能" → 应先检查 package.json 识别框架，查 framework-specific quickstart，最小化安装依赖
