# Upgrade Plan: content-research-writer

## Pattern: Pipeline
## 理由: 固定步骤：理解项目 → 协作大纲 → 调研引用 → 逐段反馈 → 终稿审查

## 缺少的文件
- [ ] README.md
- [ ] _meta.json
- [ ] evals/evals.json
- [ ] SKILL.md Pattern 标注（当前无 "Pattern: Pipeline" 标签）
- [ ] SKILL.md frontmatter 缺少 `USE FOR:` 和 `REQUIRES:` 字段

## README 要点
- 工作机制概述：从大纲到终稿的完整协作流程
- 设计决策：为什么采用逐段反馈（incremental feedback）而非一次性审查
- 声音保留（Voice Preservation）原则与实现方式
- 支持的输出格式：博客、Newsletter、技术文档、思想领袖文章
- 局限性：不自动发布，不直接调用外部 CMS，仅适合文字内容（非代码文档）

## Evals 测试用例（草案）
- eval 1: 用户说"帮我写一篇关于 AI 对产品管理影响的文章大纲" → 应输出结构化大纲，包含 Hook/Introduction/Main Sections/Research To-Do
- eval 2: 用户提供一段介绍文字并说"帮我改进 hook" → 应分析当前 hook 并提供 3 个改进选项，附上理由
- eval 3: 用户说"我刚写完第三节，帮我看看" → 应以标准反馈格式输出（What Works / Suggestions / Line Edits / Questions）
