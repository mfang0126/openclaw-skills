# Upgrade Plan: deploy-artifact

## Pattern: Tool Wrapper
## 理由: 包装 Vercel Files API + 部署 API，按需调用，返回公开 URL

## 缺少的文件
- [ ] README.md
- [ ] _meta.json
- [ ] evals/evals.json
- [ ] SKILL.md Pattern 标注（当前无 "Pattern: Tool Wrapper" 标签）
- [ ] SKILL.md 缺少 `USE FOR:` 触发关键词列表（frontmatter description 有部分，但正文无独立 `USE FOR:` section）
- [ ] SKILL.md 缺少 `Prerequisites` section（需要 Vercel token、项目已存在等）

## README 要点
- 工作原理：SHA1 哈希 → Files API 上传 → 创建 Deployment → 轮询就绪 → 返回 URL
- 设计决策：为什么用 Vercel artifacts 项目（稳定 URL、免费额度、零配置 CDN）
- 支持的文件类型及大小限制（<100MB）
- Token 配置方式（accounts.json 多账户结构）
- 局限性：不支持动态服务器端渲染，仅静态文件；大文件超时风险

## Evals 测试用例（草案）
- eval 1: 用户说"把这个 HTML 文件发布一下：/tmp/report.html" → 应调用 deploy.sh 并返回 `https://artifacts-pi.vercel.app/report.html`
- eval 2: 用户说"给我一个 /tmp/design.pdf 的分享链接" → 应识别触发词并部署，返回 PDF 公开 URL
- eval 3: token 文件缺失（~/.vercel-tokens/accounts.json 不存在）→ 应明确报错，告知如何配置 token，而非静默失败
