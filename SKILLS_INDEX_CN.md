# Skills 快速索引（中文版）

> **混合模式** — 手动维护快速开始 + 自动生成 Skills 列表

---

## 🚀 快速开始

### 我想做...

| 场景 | 推荐 Skill | 一句话描述 | 装了就能用？ |
|------|-----------|-----------|------------|
| **研究一个话题** | `research-pro`* | 统一研究工具（Tavily + Grok + Reddit）| ❌ 需要 API key |
| **计算成本/百分比** | `calculator` | 100% 准确的数学计算 | ✅ |
| **打开网页/截图** | `agent-browser`* | 浏览器自动化（Playwright）| ✅ 外部 |
| **抓网页内容** | `firecrawl`* | 网页抓取和搜索 | ❌ 需要 API key |
| **画流程图** | `mermaid-architect`* | Mermaid 图表生成和渲染 | ✅ 外部 |
| **创建 Word 文档** | `docx`* | Word 文档创建和编辑 | ✅ 外部 |
| **处理 PDF** | `pdf`* | PDF 操作（合并、拆分、OCR）| ✅ 外部 |
| **转录音频** | `openai-whisper`* | 本地语音转文字 | ✅ 外部 |
| **下载抖音视频** | `douyin-dl` | 抖音视频下载 | ✅ |
| **部署文件到 Vercel** | `deploy-artifact` | 部署文件获取公开链接 | ✅ |
| **查 IP 地址** | `show-my-ip`* | 显示当前公网 IP | ✅ 外部 |
| **查天气** | `weather`* | 天气查询 | ✅ 外部 |

> *标记为「外部」的技能需单独安装，不包含在本仓库中

---

## 🎯 常用方案组合

### 方案 1: 网页自动化
```
agent-browser + browser-routing + firecrawl
```
用途：打开网页 + 截图 + 抓数据

### 方案 2: 内容创作
```
content-research-writer + docx* + pdf* + mermaid-architect*
```
用途：研究 + 写作 + 生成文档
> *外部依赖 — 需单独安装

### 方案 3: Agent 持续改进
```
reflection + soul-keeper + self-improving
```
用途：记录教训 + 同步配置 + 自我改进

### 方案 4: 前端开发
```
ai-sdk* + mastra* + nextjs-best-practices* + nextjs-supabase-auth*
```
用途：AI SDK + Mastra + Next.js + Supabase
> *外部依赖 — 需单独安装

### 方案 5: 内容下载
```
douyin-dl + platform-bridge* + content-research-writer
```
用途：下载抖音/小红书 + 多平台 + 写作
> *外部依赖 — 需单独安装

### 方案 6: 研究调研
```
research-pro + grok-search + content-research-writer
```
用途：深度研究 + X 搜索 + 写作

---

## 🔍 快速搜索

| 关键词 | 相关 Skills |
|--------|------------|
| **网页** | agent-browser, browser-use, firecrawl, html-screenshot |
| **截图** | agent-browser*, html-screenshot, snap* |
| **计算** | calculator |
| **文档** | docx*, pdf*, mermaid-architect* |
| **音频** | openai-whisper, songsee, video-frames |
| **视频** | video-frames, video-analyzer, demo-video |
| **下载** | douyin-dl, platform-bridge |
| **研究** | research-pro, grok-search, content-research-writer |
| **部署** | deploy-artifact, vercel |
| **记忆** | reflection, soul-keeper, self-improving |
| **开发** | ai-sdk*, mastra*, nextjs-best-practices* |
| **测试** | python-code-review, skills-watchdog |
| **配置** | openclaw-config, node-connect |

---

## 📊 统计

| 分类 | 数量 | 即装即用 | 需要 API key |
|------|------|----------|--------------|
| **AI & 开发** | 6 | 6 | 0 |
| **内容 & 文档** | 4 | 4 | 0 |
| **研究 & 分析** | 3 | 1 | 2 |
| **平台 & 集成** | 4 | 4 | 0 |
| **工具 & 实用** | 4 | 4 | 0 |
| **音频 & 视频** | 2 | 2 | 0 |
| **测试 & 质量** | 2 | 2 | 0 |
| **Agent & 记忆** | 3 | 3 | 0 |
| **系统 & 配置** | 2 | 2 | 0 |
| **后端 & 数据库** | 2 | 1 | 1 |
| **SEO & 营销** | 1 | 1 | 0 |
| **总计** | **31** | **30** | **5** |

---

## 📦 外部依赖

> 以下技能需**单独安装**，不包含在本仓库中。
> 可通过 ClawHub、Claude Code 内置或第三方来源获取。

### ClawHub 技能（7）
| 技能 | 描述 | 来源 |
|------|------|------|
| `ffmpeg-cli` | FFmpeg 命令行视频/音频处理 | ClawHub |
| `mermaid-architect` | 生成并渲染 Mermaid 图表为 PNG/SVG | ClawHub |
| `snap` | 快速截取任意网站截图 | ClawHub |
| `show-my-ip` | 显示当前公网 IP 地址 | ClawHub |
| `tailscale` | Tailscale VPN 管理 | ClawHub |
| `ui-ux-pro-max-2` | UI/UX 设计指南 | ClawHub |

### Claude Code 内置（2）
| 技能 | 描述 | 来源 |
|------|------|------|
| `docx` | Word 文档创建和编辑 | Claude Code |
| `pdf` | PDF 操作（合并、拆分、OCR）| Claude Code |

### 第三方技能（5）
| 技能 | 描述 | 来源 |
|------|------|------|
| `mastra` | Mastra 框架指南，用于构建 Agent 和工作流 | 第三方 |
| `nano-banana-2` | 通过 nano-banana CLI 生成 AI 图像 | 第三方 |
| `nextjs-best-practices` | Next.js App Router 最佳实践 | 第三方 |
| `nextjs-supabase-auth` | Supabase Auth 与 Next.js 集成 | 第三方 |
| `supabase-postgres-best-practices` | Supabase 的 Postgres 优化 | 第三方 |

---

## 📊 所有 Skills（自动生成）

> 以下内容从所有 SKILL.md 的 frontmatter 自动生成

---

**最后更新**: 2026-04-02

