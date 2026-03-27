---
name: research-pro
description: |
  Unified research skill — handles ANY research, investigation, or information-gathering task automatically.
  Selects the right depth (Quick/Standard/Deep/Crawl) and tools (Tavily API, Grok X/web search, Reddit, Firecrawl) based on what the user needs.

  USE FOR:
  - "research / investigate / look up / explore / analyze" + any topic
  - "帮我研究/查/了解/调研/分析/对比" + 任何话题
  - 竞品分析、市场调研、技术对比、趋势了解
  - 需要 X/Twitter 实时讨论、Reddit 社区意见、YouTube 视频内容
  - 不确定用哪个工具时 → 直接用这个，它会自动选

  别名路由（Alias Routing）：
  - 用户说 "grok search X" / "用 grok 搜" → 强制用 Grok web_search
  - 用户说 "tavily search/extract/crawl/map/research X" → 强制用对应 tvly 命令
  - 用户说 "firecrawl scrape/search/map X" → 强制用 firecrawl CLI
  - 用户说 "reddit X" → 强制用 reddit-cli
  - 用户说 "youtube X" → 强制用 YouTube 方法
  - 用户只说 "search X" / "搜 X"（不指定工具）→ 默认 tvly search
  - 没有工具偏好的研究请求 → 正常进入模式判断

  不触发：
  - 用户给了具体 URL 要抓内容（直接用 firecrawl）
  - 已知答案的简单事实问题

user-invocable: true
metadata: {"clawdbot":{"emoji":"🔬","requires":{"env":["TAVILY_API_KEY","XAI_API_KEY"]}}}
---

# Research Pro — 统一研究入口

**你是研究员，不是工具操作员。** 用户不需要知道你用了哪个工具，他们只要高质量的结果。

**架构定位：** 这是所有搜索/研究 skill 的调度层。下层工具（grok-search、reddit-cli、youtube、tavily-*、firecrawl）通常由本 skill 调用，不直接被用户触发。

---

## Phase 1: 判断模式（5秒内完成）

```
用户请求
    │
    ├── 简单事实 / "X 是什么" / 最新版本？
    │   → Quick Mode
    │
    ├── 了解一个话题 / 趋势 / 概览？
    │   → Standard Mode
    │
    ├── 多源对比 / 深度分析 / 决策支持？
    │   → Deep Mode
    │
    └── 批量收集多个目标的信息？
        → Crawl Mode
```

**判断信号：**
- "快速"、"简单"、"大概"、"quick"、"briefly" → Quick
- "详细"、"深度"、"全面"、"报告"、"comprehensive"、"in-depth" → Deep
- 多个实体需要对比 → Deep 或 Crawl
- 用户给了 URL 列表 → Crawl
- 不确定 → Standard（最安全的默认值）
- 话题太模糊 → 先问一个澄清问题，再进入模式

---

## Phase 1.5: 别名路由（Alias Routing）

**在判断模式之前，先检查用户是否指定了工具。** 如果指定了，跳过模式判断，直接用指定工具。

```
用户请求
    │
    ├── 包含 "grok" → 用 Grok（web 或 x，根据上下文判断）
    │   node {skillDir}/scripts/grok_search.mjs "<query>" --web
    │   node {skillDir}/scripts/grok_search.mjs "<query>" --x
    │
    ├── 包含 "tavily search" → tvly search "<query>" --json
    ├── 包含 "tavily extract" → tvly extract "<url>" --json
    ├── 包含 "tavily crawl" → tvly crawl "<url>" --json
    ├── 包含 "tavily map" → tvly map "<url>" --json
    ├── 包含 "tavily research" → tvly research "<query>" --json
    │
    ├── 包含 "firecrawl" → firecrawl <subcommand> ...
    │
    ├── 包含 "reddit" → node {skillDir}/scripts/reddit-cli.js search "<query>"
    │
    ├── 包含 "youtube" → YouTube workflow（见下方 YouTube 章节）
    │
    ├── 只说 "search" / "搜"（无工具名）→ tvly search "<query>" --json
    │
    └── 无工具偏好 → 进入 Phase 1 模式判断
```

**别名路由后的输出：** 直接返回工具原始结果 + 简短总结。不需要走完整的模式流程。

---

## Phase 2: 按模式执行

### Quick Mode（~30秒）

**目标：** 快速拿到答案，不过度挖掘。

1. **Grok web_search** — 搜话题，取 top 5 结果
2. 读 snippets — 够用就直接总结
3. 不够 → **firecrawl scrape** 最相关的 1 页全文
4. 涉及社区观点 → **reddit-cli search** 补充
5. 输出紧凑总结

**输出：** 3–5 个要点 + 来源 URL，可选提示"想要更深入的报告吗？"

---

### Standard Mode（~1–2分钟）

**目标：** 有引用支撑的全面话题覆盖。

1. **Grok web_search** — top 10 结果
2. **Grok x_search** — 检查 X/Twitter 近期讨论（话题较新时）
3. **reddit-cli search** — 社区真实意见（产品/技术类话题）
4. 判断是否需要 YouTube 内容（教程/演讲/评测类话题）→ **youtube search + transcript**
5. 识别 3–5 个最有价值的 URL
6. **firecrawl scrape** 并行抓取
7. 综合所有来源，输出结构化报告

**输出：** 概述段 → 按主题的关键发现 → 编号引用 → 建议后续方向

---

### Deep Mode（~2–5分钟）

**目标：** 多源交叉验证的研究报告，支持决策。

1. **Tavily Research 先行**（有 `TAVILY_API_KEY` 时）：
   ```bash
   bash {skillDir}/scripts/research.sh '{"input": "<topic>", "model": "pro"}' ./temp_report.md
   ```
2. **Grok x_search** — 补充 X/Twitter 上的实时观点和社区反应
3. **reddit-cli** — 补充 Reddit 真实用户讨论
4. **YouTube** — 如果话题有重要演讲/教程 → 拿字幕补充
5. **Firecrawl 补深度：**
   - 从 Tavily 报告提取关键 URL
   - 识别遗漏角度（官方文档、技术博客、论坛）
   - `firecrawl scrape` 补充内容
   - 需要站点结构 → `firecrawl map` 先探索
6. **交叉验证：** 对比各来源，标注分歧，注明信息时效

**输出：**
- Executive Summary（3–5句，可以直接给人看）
- 详细分析（分章节）
- 合并引用列表（去重）
- 可靠度说明（已确认 vs 待验证）
- 建议下一步

---

### Crawl Mode（~3–10分钟）

**目标：** 批量收集多个目标的信息，结构化对比。

典型场景：竞品分析、技术选型、市场扫描。

1. **确定目标：**
   - 用户给了 URL → 直接用
   - 用户给了名称/关键词 → Grok web_search 找官网/文档页
2. **批量收集：**
   - `firecrawl scrape` 并行抓取所有目标
   - 需要多页面 → `firecrawl crawl`（设 limit 避免过度）
3. **结构化提取：**
   - 有明确对比维度 → `firecrawl extract` 用 schema 拿 JSON
   - 没有 → 先抓内容，再自行提取共性维度
4. **补充社区声音：** reddit-cli 搜各目标的用户评价

**输出：** 对比矩阵（Markdown 表格）→ 各目标详细分析 → 优劣势总结 → 建议

---

## Phase 3: 输出格式（所有模式通用）

```markdown
# [话题] — 研究结果

> **模式**: Quick / Standard / Deep / Crawl
> **日期**: YYYY-MM-DD
> **来源数**: N

## 摘要
[1–3句核心结论]

## 关键发现
[按主题组织]

## 来源
1. [标题](URL) — 引用原因
2. ...

## 后续建议（可选）
- [建议下一步]
```

**引用规则：** 每个事实性陈述标注来源编号如 [1][3]，注明来源类型（官方文档/新闻/博客/论坛/论文）

**输出前自查：**
- [ ] 回答了用户的核心问题？
- [ ] 有没有遗漏重要角度？
- [ ] 引用可追溯？
- [ ] 信息足够新？
- [ ] 非专家能看懂？

---

## 工具调用参考

| 需求 | 首选工具 | 备选 |
|------|---------|------|
| 普通网页搜索 | `grok web_search` | `tvly search` |
| X/Twitter 内容 | `grok x_search` | — |
| Reddit 社区讨论 | `reddit-cli search` | grok web_search + site:reddit.com |
| YouTube 视频/字幕 | `youtube search` + `youtube transcript` | — |
| 单页内容提取 | `firecrawl scrape` | `web_fetch` |
| 站点结构发现 | `firecrawl map` | — |
| 多页批量抓取 | `firecrawl crawl` | 循环 scrape |
| 结构化数据提取 | `firecrawl extract` | 手动解析 |
| 深度研究报告 | `tavily research` (scripts/research.sh) | Deep Mode 手动流程 |
| 百科类事实 | `grok web_search` | `tvly search` |

### Grok Search
```bash
# Web 搜索
node {skillDir}/scripts/grok_search.mjs "<query>" --web

# X/Twitter 搜索
node {skillDir}/scripts/grok_search.mjs "<query>" --x

# 参数: --max <n>  --days <n>  --from YYYY-MM-DD  --to YYYY-MM-DD
```
需要 `XAI_API_KEY`。

### Reddit CLI
```bash
node {skillDir}/scripts/reddit-cli.js search "query"                    # 全 Reddit 搜索
node {skillDir}/scripts/reddit-cli.js search "query" --sub subreddit    # 指定版块
node {skillDir}/scripts/reddit-cli.js posts subreddit 10                # 热门帖子
```

### YouTube
```bash
# 搜索（无需 API Key）
yt-dlp "ytsearch5:<query>" --dump-json --no-download --quiet

# 获取字幕
python3 -c "from youtube_transcript_api import YouTubeTranscriptApi; api = YouTubeTranscriptApi(); t = api.fetch('<VIDEO_ID>'); print(' '.join(s.text for s in t))"
```
需要 `YOUTUBE_API_KEY`（用 API 搜索时）。yt-dlp 搜索无需 key。

### Tavily Research Script
```bash
bash {skillDir}/scripts/research.sh '{"input": "<topic>", "model": "pro"}' ./report.md
```
model: `mini`（快速）/ `pro`（深度）/ `auto`（自动）
需要 `TAVILY_API_KEY`（已配置）。

---

## Tavily CLI 参考

> 详细 API 文档见 `references/tavily/` 目录。

### tvly search — 网页搜索

```bash
# 基础搜索
tvly search "your query" --json

# 高级搜索（更多结果、更高质量）
tvly search "quantum computing" --depth advanced --max-results 10 --json

# 新闻搜索
tvly search "AI news" --time-range week --topic news --json

# 限定域名
tvly search "SEC filings" --include-domains sec.gov,reuters.com --json

# 包含页面全文（省去后续 extract）
tvly search "react hooks tutorial" --include-raw-content --max-results 3 --json
```

| 参数 | 说明 |
|------|------|
| `--depth` | `ultra-fast` / `fast` / `basic`(默认) / `advanced` |
| `--max-results` | 最大结果数 0–20（默认 5） |
| `--topic` | `general`(默认) / `news` / `finance` |
| `--time-range` | `day` / `week` / `month` / `year` |
| `--include-domains` | 限定域名（逗号分隔） |
| `--exclude-domains` | 排除域名 |
| `--include-raw-content` | 返回页面全文（`markdown` 或 `text`） |
| `--include-answer` | 包含 AI 回答（`basic` 或 `advanced`） |
| `-o, --output` | 保存到文件 |

### tvly extract — URL 内容提取

```bash
# 单个 URL
tvly extract "https://example.com/article" --json

# 多个 URL（最多 20 个）
tvly extract "https://example.com/page1" "https://example.com/page2" --json

# 按查询聚焦提取
tvly extract "https://example.com/docs" --query "authentication API" --chunks-per-source 3 --json

# JS 渲染页面
tvly extract "https://app.example.com" --extract-depth advanced --json
```

| 参数 | 说明 |
|------|------|
| `--query` | 按相关度重排 chunks |
| `--chunks-per-source` | 每 URL 返回 chunks 数（1–5，需配合 `--query`） |
| `--extract-depth` | `basic`(默认) / `advanced`（JS 页面） |
| `--format` | `markdown`(默认) / `text` |
| `--timeout` | 超时（1–60 秒） |

### tvly crawl — 多页抓取

```bash
# 基础爬取
tvly crawl "https://docs.example.com" --json

# 保存为本地 markdown 文件
tvly crawl "https://docs.example.com" --output-dir ./docs/

# 路径过滤
tvly crawl "https://example.com" --select-paths "/api/.*,/guides/.*" --exclude-paths "/blog/.*" --json

# 语义聚焦
tvly crawl "https://docs.example.com" --instructions "Find authentication docs" --chunks-per-source 3 --json
```

| 参数 | 说明 |
|------|------|
| `--max-depth` | 爬取深度 1–5（默认 1） |
| `--max-breadth` | 每页链接数（默认 20） |
| `--limit` | 总页数上限（默认 50） |
| `--instructions` | 语义聚焦指令 |
| `--select-paths` | 路径正则（包含） |
| `--exclude-paths` | 路径正则（排除） |
| `--output-dir` | 保存每页为 .md 文件 |

### tvly map — URL 发现

```bash
# 列出所有 URL
tvly map "https://docs.example.com" --json

# 语义过滤
tvly map "https://docs.example.com" --instructions "Find API docs" --json

# 路径过滤
tvly map "https://example.com" --select-paths "/blog/.*" --limit 500 --json
```

**Map + Extract 模式：** 先 map 找 URL，再 extract 特定页面。比 crawl 更高效（只需要几个页面时）。

### tvly research — AI 深度研究

```bash
# 基础研究（等待完成）
tvly research "competitive landscape of AI code assistants"

# Pro 模型（全面分析）
tvly research "electric vehicle market analysis" --model pro

# 实时流式输出
tvly research "AI agent frameworks comparison" --stream

# 保存报告
tvly research "fintech trends 2025" --model pro -o fintech-report.md
```

| 模型 | 适用场景 | 速度 |
|------|---------|------|
| `mini` | 单一话题、针对性研究 | ~30s |
| `pro` | 全面多角度分析 | ~60–120s |
| `auto` | API 自动选择 | 不定 |

**或用 research.sh 脚本：**
```bash
bash {skillDir}/scripts/research.sh '{"input": "<topic>", "model": "pro"}' ./report.md
```

---

## Firecrawl CLI 参考

> 安装指南见 `references/firecrawl/install.md`。

```bash
# 检查状态
firecrawl --status

# 搜索
firecrawl search "your query" -o .firecrawl/search-query.json --json

# 搜索 + 抓取内容
firecrawl search "your query" --scrape -o .firecrawl/search-scraped.json --json

# 单页抓取
firecrawl scrape https://example.com -o .firecrawl/example.md

# 仅主内容
firecrawl scrape https://example.com --only-main-content -o .firecrawl/clean.md

# 等待 JS 渲染
firecrawl scrape https://spa-app.com --wait-for 3000 -o .firecrawl/spa.md

# 站点 URL 发现
firecrawl map https://example.com -o .firecrawl/urls.txt

# 按关键词过滤 URL
firecrawl map https://example.com --search "blog" -o .firecrawl/blog-urls.txt
```

**并行抓取（必须并行，不要顺序执行）：**
```bash
firecrawl scrape https://site1.com -o .firecrawl/1.md &
firecrawl scrape https://site2.com -o .firecrawl/2.md &
firecrawl scrape https://site3.com -o .firecrawl/3.md &
wait
```

**输出目录：** 在工作目录创建 `.firecrawl/`，加入 `.gitignore`。

---

## 错误处理

| 问题 | 处理方式 |
|------|---------|
| Grok 搜索结果差 | 换关键词重试，或切 Tavily |
| firecrawl scrape 失败 | 回退 web_fetch，或跳过该 URL |
| Tavily 不可用 | 降级 Standard Mode（Grok + firecrawl）|
| 抓取内容质量差（广告多）| 跳过，换下一个 URL |
| YouTube transcript 失败 | 跳过，用 Grok/Tavily 文字内容替代 |
| 话题太模糊 | 先问一个澄清问题 |
| XAI_API_KEY 未配置 | 跳过 X/Twitter，用 Tavily 替代网页搜索 |
| TAVILY_API_KEY 未配置 | 跳过 Tavily 报告，用 Grok + firecrawl |

---

## 示例

**Quick:** "Next.js 15 有什么新功能？" → Grok web_search → snippets 足够 → 5个新特性 + 官方链接

**Standard:** "2026年 AI Agent 框架趋势" → Grok web + X → Reddit → 5篇文章 → firecrawl → 综合报告

**Deep:** "详细对比 Supabase vs Firebase vs PocketBase" → Tavily pro → firecrawl补充文档/定价 → Reddit用户反馈 → 对比表

**Crawl:** "调研5个竞品定价：Notion/Coda/Obsidian/Roam/Logseq" → Grok找各定价页 → firecrawl批量抓 → Reddit用户评价 → 对比矩阵

---

## 依赖工具版本追踪

> 每月检查一次，有更新通知 Ming。

| 工具 | 检查方式 |
|------|---------|
| tavily CLI | `tvly --version` |
| firecrawl CLI | `firecrawl --version` |
| xAI API | https://docs.x.ai/docs/guides/tools/search-tools |
| Tavily API | https://tavily.com/changelog |

---



---

## References

### APIs & Tools
- **Tavily API** — https://tavily.com
- **xAI Grok API** — https://docs.x.ai
- **Reddit API** — https://www.reddit.com/dev/api
- **Firecrawl** — https://firecrawl.dev
