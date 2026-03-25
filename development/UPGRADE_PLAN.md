# Upgrade Plan: development

## Pattern: Pipeline
## 理由: 严格的步骤顺序：理解问题 → 设计方案 → 实施 → Dev Server 验证 → PR → Preview → 用户验收 → Merge

## 缺少的文件
- [ ] README.md（USAGE.md 存在但不符合 SOP 规范的 README 格式）
- [ ] _meta.json
- [ ] evals/evals.json
- [ ] SKILL.md frontmatter（当前无 `---` frontmatter，缺少 `name`、`description` 字段）
- [ ] SKILL.md Pattern 标注（当前无 "Pattern: Pipeline" 标签）
- [ ] SKILL.md 缺少 `USE FOR:`、`When to Use`、`Prerequisites`、`Quick Start`、`Error Handling` 等标准 sections

## README 要点
- 三环境模型详解（Dev Server / Preview / Production）及各自职责
- 为什么必须先用 Dev Server 自测再让用户看 Preview（分工明确）
- agent-browser E2E 测试的标准用法示例
- PR 创建规范（branch 命名、commit message 格式、PR body 模板）
- 常见陷阱：只做编译检查而不模拟真实操作的危害

## Evals 测试用例（草案）
- eval 1: 用户报告"登录按钮点击无响应"→ Agent 应走完完整 Pipeline：复现 → 定位代码 → 修复 → pnpm dev 测试 → 创建 PR，不应直接 merge 到 main
- eval 2: 用户说"改完了，帮我测一下" → Agent 应用 Dev Server + agent-browser 做 E2E 测试，输出测试结果，不应等 Preview
- eval 3: Preview 部署失败 → Agent 应回退到 Dev Server 验证逻辑正确，向用户说明 Preview 失败不等于代码有问题
