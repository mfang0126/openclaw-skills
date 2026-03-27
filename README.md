# OpenClaw Skills Collection

> 一个精心策划的 AI agent skills 集合，为 [OpenClaw](https://github.com/openclaw/openclaw) 提供开箱即用的能力

**快速导航**：
- [Skills 列表](#skills-列表) — 所有 skills 的完整列表
- [快速开始](#快速开始) — 如何安装和使用
- [Skill 分类](#skill-分类) — 按类别查找
- [常见场景](#常见场景) — 我该用哪个 skill？

---

## Skills 列表

### 🌐 Web & Browser（网页和浏览器）

| Skill | 描述 | 什么时候用 | 快速示例 |
|-------|------|-----------|---------|
| **agent-browser** | 浏览器自动化（Playwright） | 打开网页、 填表单、 截图、 抓数据 | "帮我打开 google.com 并截图" |
| **browser-use** | 浏览器自动化（Browser-Use） | 自动化浏览器操作 | "帮我自动登录这个网站" |
| **browser-routing** | 浏览器工具路由决策器 | 不知道用哪个浏览器工具时 | （内部自动触发） |
| **firecrawl** | 网页抓取和搜索（Firecrawl） | 抓网页内容、 搜索、 深度研究 | "帮我抓取这个网页的内容" |

---

### 🧠 AI & Development（AI 和开发）

| Skill | 描述 | 什么时候用 | 快速示例 |
|-------|------|-----------|---------|
| **ai-sdk** | AI SDK 开发指南 | 用 AI SDK 开发应用 | "如何在 Next.js 里用 generateText？" |
| **mastra** | Mastra framework 指南 | 用 Mastra 开发 agents | "怎么用 Mastra 创建一个 agent？" |
| **coding-agent** | 编码任务委派 | 复杂编码、 PR review、 重构 | "帮我重构这个大型代码库" |
| **calculator** | 100% 准确的数学计算 | 任何计算（成本、 百分比、 单位转换） | "帮我算一下 API 成本" |

---

### 📊 Research & Analysis（研究和分析）

| Skill | 描述 | 什么时候用 | 快速示例 |
|-------|------|-----------|---------|
| **research-pro** | 统一研究工具（Tavily + Grok + Reddit） | 深度研究、 调查、 信息收集 | "帮我研究一下这个竞品" |
| **grok-search** | Grok X/Twitter 搜索 | 搜索 X/Twitter、 实时信息 | "搜索一下这个话题在 Twitter 上的讨论" |
| **content-research-writer** | 内容研究 + 写作助手 | 写文章、 加引用、 改进大纲 | "帮我写一篇关于 AI 的文章" |
| **reddit-cli** | Reddit 搜索和浏览 | 查 Reddit 帖子和讨论 | "搜索 Reddit 上关于这个产品的评价" |

---

### 📝 Content & Documentation（内容和文档）

| Skill | 描述 | 什么时候用 | 快速示例 |
|-------|------|-----------|---------|
| **docx** | Word 文档创建和编辑 | 创建/编辑 .docx 文件 | "帮我创建一个 Word 文档" |
| **pdf** | PDF 操作（合并、 拆分、 OCR） | 处理 PDF 文件 | "帮我合并这些 PDF" |
| **mermaid-architect** | Mermaid 图表生成和渲染 | 画流程图、 时序图 | "帮我画一个流程图" |
| **html-screenshot** | HTML 文件截图 | 把 HTML 渲染成图片 | "帮我看看这个 HTML 的效果" |

---

### 🛠️ Utilities & Tools（工具和实用程序）

| Skill | 描述 | 什么时候用 | 快速示例 |
|-------|------|-----------|---------|
| **deploy-artifact** | 部署文件到 Vercel artifacts | 分享文件、 获取公开链接 | "帮我发布这个 HTML 文件" |
| **show-my-ip** | 显示当前公网 IP | 查服务器 IP | "帮我看看当前 IP" |
| **goplaces** | Google Places API 查询 | 搜索地点、 获取详情 | "帮我查一下这个餐厅的信息" |
| **weather** | 天气查询（wttr.in + Open-Meteo） | 查天气、 预报 | "明天天气怎么样？" |

---

### 🎵 Audio & Video（音视频）

| Skill | 描述 | 什么时候用 | 快速示例 |
|-------|------|-----------|---------|
| **songsee** | 音频频谱和特征可视化 | 分析音频文件 | "帮我看看这个音频的频谱" |
| **video-frames** | 视频帧提取和剪辑 | 从视频提取帧或短片 | "帮我从视频里提取一些帧" |
| **openai-whisper** | 本地语音转文字（Whisper） | 转录音频（无需 API） | "帮我转录这个音频" |
| **openai-whisper-api** | OpenAI Whisper API 转录 | 转录音频（用 API） | "帮我转录这个音频" |

---

### 📱 Platform & Integration（平台和集成）

| Skill | 描述 | 什么时候用 | 快速示例 |
|-------|------|-----------|---------|
| **douyin-dl** | 抖音视频下载 | 下载抖音视频 | "帮我下载这个抖音视频" |
| **content-inbox** | 统一内容管理（抖音/小红书/公众号） | 下载和管理内容 | "帮我处理这个链接" |
| **platform-bridge** | 平台适配器（多平台支持） | 跨平台内容处理 | （内部自动触发） |

---

### 🧪 Testing & Quality（测试和质量）

| Skill | 描述 | 什么时候用 | 快速示例 |
|-------|------|-----------|---------|
| **audio-timestamp-verifier** | 音频时间戳验证 | 验证转录时间戳准确性 | "帮我验证这个时间戳" |
| **python-code-review** | Python 代码审查 | 审查 Python 代码 | "帮我 review 这段 Python 代码" |

---

### 🧠 Agent & Memory（Agent 和记忆）

| Skill | 描述 | 什么时候用 | 快速示例 |
|-------|------|-----------|---------|
| **reflection** | 自我反思和学习（三层记忆） | 记录教训、 持续改进 | （用户纠正时自动触发） |
| **soul-keeper** | Workspace 文件同步 | 更新 SOUL.md、 AGENTS.md 等 | （检测到需要更新时触发） |
| **self-improving** | 自我改进（带反思） | Agent 自我评估和改进 | （自动触发） |

---

### 📚 Documentation & Guides（文档和指南）

| Skill | 描述 | 什么时候用 | 快速示例 |
|-------|------|-----------|---------|
| **skill-creator** | 创建和优化 skills | 写新 skill 或改进现有 skill | "帮我创建一个新 skill" |
| **plan-mode** | 计划模式（只想不做） | 分析、 计划、 不执行 | "帮我分析一下这个问题" |
| **sub-agent-patterns** | Sub-agent 模式指南 | 创建和管理 sub-agents | "怎么创建一个自定义 sub-agent？" |

---

### 🔧 System & Config（系统和配置）

| Skill | 描述 | 什么时候用 | 快速示例 |
|-------|------|-----------|---------|
| **openclaw-config** | OpenClaw 配置管理 | 修改 openclaw.json | "帮我改一下配置" |
| **node-connect** | OpenClaw node 连接诊断 | 诊断 node 连接问题 | "我的 node 连不上了" |
| **healthcheck** | 系统安全和加固 | 安全审计、 防火墙配置 | "帮我检查一下系统安全" |

---

### 🎨 Creative & Design（创意和设计）

| Skill | 描述 | 什么时候用 | 快速示例 |
|-------|------|-----------|---------|
| **nano-banana-pro** | 图像生成（Gemini 3 Pro） | 生成或编辑图像 | "帮我生成一张图片" |
| **openai-image-gen** | 批量图像生成（OpenAI） | 批量生成图像 + 画廊 | "帮我批量生成 10 张图" |

---

### 📖 Knowledge & Learning（知识和学习）

| Skill | 描述 | 什么时候用 | 快速示例 |
|-------|------|-----------|---------|
| **summarize** | URL/播客/文件总结 | 总结内容、 提取文本 | "帮我总结这个 YouTube 视频" |
| **Grokipedia** | Grokipedia 百科搜索 | 查 Grokipedia 文章 | "帮我查一下这个概念" |
| **apple-reminders** | Apple Reminders 管理 | 管理 Apple Reminders | "帮我添加一个提醒" |

---

## 快速开始

### 1. 安装 OpenClaw

```bash
# macOS
brew install openclaw

# 或从源码安装
git clone https://github.com/openclaw/openclaw.git
cd openclaw && npm install && npm link
```

---

### 2. 安装 Skills

**方式 A：克隆整个 repo**
```bash
git clone https://github.com/mfang0126/openclaw-skills.git ~/.openclaw/skills
```

**方式 B：从 ClawHub 安装单个 skill**
```bash
openclaw skill install calculator
openclaw skill install mermaid-architect
```

---

### 3. 验证安装

```bash
# 列出所有已安装的 skills
ls ~/.openclaw/skills/

# 查看某个 skill 的详情
cat ~/.openclaw/skills/calculator/SKILL.md | head -20
```

---

## Skill 分类

### 按 Google ADK 五模式分类

| 模式 | Skills | 特点 |
|------|--------|------|
| **Tool Wrapper** | ai-sdk, mastra, nextjs-best-practices | 按需加载知识 |
| **Generator** | mermaid-architect, docx, pdf | 固定输出结构 |
| **Reviewer** | python-code-review, audio-timestamp-verifier | 审查和验证 |
| **Inversion** | plan-mode | 先问再做 |
| **Pipeline** | reflection, soul-keeper | 流水线处理 |

---

## 常见场景

### 🔍 "我想研究一个话题"

```
推荐：research-pro

示例：
"帮我研究一下 LangGraph 和 LangChain 的区别"
→ research-pro 会自动搜索、 对比、 总结
```

---

### 💰 "我需要计算成本/百分比"

```
推荐：calculator

示例：
"帮我算一下 GPT-4 API 的成本：100K input, 50K output"
→ calculator 会精确计算， 不会出错
```

---

### 🌐 "我需要打开网页/截图/抓数据"

```
推荐：agent-browser（自动化） 或 firecrawl（抓取）

示例：
"帮我打开 google.com 并截图" → agent-browser
"帮我抓取这个网页的内容" → firecrawl
```

---

### 📊 "我需要画流程图/时序图"

```
推荐：mermaid-architect

示例：
"帮我画一个用户登录的流程图"
→ mermaid-architect 会生成 Mermaid 代码并渲染成图片
```

---

### 📝 "我需要创建 Word/PDF 文档"

```
Word 文档 → docx
PDF 操作 → pdf

示例：
"帮我创建一个包含表格的 Word 文档" → docx
"帮我合并这些 PDF 文件" → pdf
```

---

### 🎵 "我需要转录音频"

```
本地转录（免费） → openai-whisper
API 转录（更快） → openai-whisper-api

示例：
"帮我转录这个录音" → openai-whisper
```

---

### 📱 "我需要下载抖音/小红书内容"

```
抖音视频 → douyin-dl
多平台内容 → content-inbox

示例：
"帮我下载这个抖音视频" → douyin-dl
"帮我处理这个链接（抖音/小红书/公众号）" → content-inbox
```

---

### 🧠 "我想让 agent 持续学习和改进"

```
反思和学习 → reflection
配置文件同步 → soul-keeper

这两个 skill 会自动触发，不需要手动调用
```

---

## 开发自己的 Skill

### 1. 阅读 Skill 开发指南

```bash
# 完整指南
cat ~/.openclaw/shared/docs/SKILL_GUIDELINE.md

# 或查看这个 repo 的 HOW-TO-WRITE-SKILLS.md
```

---

### 2. 使用 skill-creator

```bash
# 让 AI 帮你创建 skill
"帮我创建一个 skill， 用于..."
→ skill-creator 会引导你完成
```

---

### 3. 参考 template

```bash
# 标准 skill 结构
skill-name/
├── SKILL.md           # 核心文件
├── scripts/           # 可执行脚本
├── references/        # 详细文档
├── assets/            # 模板、 图标
└── evals/             # 测试用例
```

---

## 贡献

欢迎贡献新的 skills 或改进现有 skills！

### 贡献流程

1. Fork 这个 repo
2. 创建新的 skill 或改进现有 skill
3. 确保符合 SKILL_GUIDELINE.md 标准
4. 提交 Pull Request

---

## License

MIT - 自由使用、 改进、 分享

---

## 支持

- **文档**: https://docs.openclaw.ai
- **社区**: https://discord.com/invite/clawd
- **GitHub**: https://github.com/openclaw/openclaw
- **ClawHub**: https://clawhub.com

---

**最后更新**: 2026-03-27
**Skills 数量**: 45+
