---
name: wordpress-cli
description: |
  通过命令行直接发布 Markdown 文章到 WordPress，带完整 CSS 样式优化。

  USE FOR:
  - "把这篇文章发到 WordPress", "publish to WordPress", "发布到博客"
  - "post this as a draft", "发布为草稿", "upload markdown to blog"
  - "更新 WordPress 文章", "send this to WordPress", "blog post"
  - "把 Markdown 发布到网站", "push article to WordPress"
  - "publish", "发布", "上传文章", "markdown to wordpress"

  REQUIRES:
  - Node.js (v14+)
  - WordPress site with REST API enabled
  - WordPress Application Password configured
version: 1.0.0
author: DeveloperFang
---

# WordPress CLI 发布工具

**Pattern: Tool Wrapper** — Markdown File → HTML Conversion + Inline CSS → WordPress REST API → Published Post URL

> ⚠️ **安全警告：** `publish.js` 中存在硬编码密码回退 (`WP_PASS` fallback)。建议迁移到环境变量。详见 README.md。

通过简单的聊天指令，将 Markdown 文章直接发布到 WordPress，无需登录后台。

## When to Use

Use when the user wants to **publish or update a Markdown document to their WordPress blog**. Typical triggers:
- User has a finished `.md` article and says "发布到 WordPress" / "post this to my blog"
- User wants to push a draft for review ("发布为草稿")
- User needs to update an existing post by ID

**Don't use when:** User's site doesn't have WordPress REST API enabled, the target platform is not WordPress (use other publishing skills), or the user only wants a local HTML preview.

## Prerequisites

1. **Node.js v14+** installed: `node --version`
2. **WordPress site** with REST API enabled (default for WP 4.7+)
3. **Application Password** generated in WordPress:
   - WP Admin → Users → Profile → Application Passwords
   - Generate and save the password
4. **Config** set in `publish.js`:
   ```javascript
   const WP_URL  = 'yourdomain.com';
   const WP_USER = 'your-email@example.com';
   const WP_PASS = 'xxxx xxxx xxxx xxxx xxxx xxxx'; // App password
   ```
5. Script is executable: `chmod +x ~/.openclaw/workspace/skills/wordpress-cli/wp-publish`

## Quick Start

```bash
# 发布为草稿
wp-publish article.md

# 直接发布（公开）
wp-publish article.md publish

# 指定自定义标题
wp-publish article.md draft "自定义标题"
```

## Features

- ✅ Markdown → HTML 自动转换
- ✅ 表格、代码块、引用样式优化（内联 CSS）
- ✅ 支持发布为草稿或直接发布
- ✅ 自动提取标题和摘要
- ✅ 兼容所有 WordPress 主题

## Examples

### Example 1: Publish a Markdown article as draft

**User says:** "把 ~/articles/my-post.md 发布为草稿到 WordPress"

**Steps:**
```bash
wp-publish ~/articles/my-post.md draft
```

**Output:**
```
✅ Draft created successfully!
Post ID: 217
URL: https://mingfang.tech/?p=217
Edit: https://mingfang.tech/wp-admin/post.php?post=217&action=edit
```

**Reply to user:** "✅ 草稿已创建，Post ID: 217 — 可在后台预览：https://mingfang.tech/?p=217"

### Example 2: Publish directly (live post)

**User says:** "把这篇文章直接发布到博客"

```bash
wp-publish article.md publish
```

**Output:** Returns the public post URL, immediately accessible.

### Example 3: Markdown input → WordPress output

**Input Markdown:**
```markdown
# 文章标题

> **核心发现**：这是一个重要发现

| 指标 | A  | B  |
|------|----|----|
| 速度 | 快 | 慢 |
```

**WordPress Result:**
- 带蓝边表头、悬停效果的 HTML 表格
- 带背景和蓝边的引用块
- 内联 CSS，无需修改主题

## Supported Markdown

| Element | Support |
|---------|---------|
| H1–H6 标题 | ✅ |
| 粗体/斜体 | ✅ |
| 代码块（语法高亮） | ✅ |
| 表格（带样式） | ✅ |
| 引用块 | ✅ |
| 有序/无序列表 | ✅ |
| 任务列表 | ✅ |
| 链接和图片 | ✅ |

## Error Handling

| Error | Cause | Solution |
|-------|-------|----------|
| `401 Unauthorized` | Application Password 错误或未配置 | 重新生成 WP Application Password，更新 `publish.js` |
| `REST API disabled` | WordPress REST API 被禁用 | 安装 WP 插件或检查 `.htaccess` 规则 |
| `node: command not found` | Node.js 未安装 | `brew install node` 或 `nvm install 18` |
| `ECONNREFUSED` / 连接超时 | 域名/IP 配置错误或网络问题 | 检查 `WP_URL`；确认站点可访问 |
| 格式错乱 | Markdown 语法不标准 | 检查表格是否用标准 `\| 列1 \| 列2 \|` 格式 |
| `Permission denied` | 脚本无执行权限 | `chmod +x ~/.openclaw/workspace/skills/wordpress-cli/wp-publish` |

## 相关文件

- `publish.js` — 核心发布脚本（Markdown → HTML → WP REST API）
- `wp-publish` — 命令行包装脚本
- `README.md` — 详细配置说明

## 更新日志

### v1.0.0 (2026-02-12)
- 初始版本：完整 Markdown 转换 + 内联 CSS + WordPress REST API 发布
