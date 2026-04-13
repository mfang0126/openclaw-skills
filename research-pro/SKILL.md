---
name: research-pro
description: |
  系统化研究 skill — 螺旋收敛模型。把任何问题（模糊或清晰）分解成子问题，迭代搜索，越搜越清晰，直到每个子问题都有答案。

  Triggers: "帮我研究", "研究一下", "调研", "分析对比", "research", "investigate", "look up"
  也触发: 竞品分析、市场调研、技术选型对比、趋势了解

  Does NOT trigger:
  - 已经知道答案的简单事实问题
  - 用户直接给了 URL 要抓取的
  - 代码调试、写代码任务

  Output: 结构化研究报告（结论 + 子问题答案 + 来源 + 争议点 + 未解决缺口）

user-invocable: true
version: 3.9.0-mf
metadata:
  fork:
    origin: research-pro-v2
    maintainer: mingfang
    version: v3.3.0-mf
    created: "2026-04-12"
    changes:
      - "v3.0.0-mf: 螺旋收敛模型，Research Map，线索评分，Critic/Reflection"
      - "v3.1.0-mf: Phase 1 加本地上下文检查 + 前提验证；启动时告知深度"
      - "v3.2.0-mf: 工具矩阵更新为实际可用工具（理论推断版）"
      - "v3.3.0-mf: 工具矩阵基于实测修正（第一轮）；移除不可用工具；补充 Tavily Research、YouTube 两步流程"
      - "v3.4.0-mf: 修复 XAI_API_KEY 变量名错误（原 X_AI）；更新 OPENROUTER_API_KEY；加入 Perplexity/sonar 实时搜索（替代 Grok）；Grok 无实时搜索能力"
      - "v3.5.0-mf: 集成 Grok Responses API（web_search + x_search）；模型必须用 grok-4 系列；x_search 可搜 X/Twitter 实时讨论"
      - "v3.6.0-mf: 信号路由规则（S1-S6）+ 工具覆盖检查；防止惰性只用 Tavily；强制多工具组合"
      - "v3.7.0-mf: Phase 5 自动日志（JSONL）+ 每 10 次阈值复盘；跟踪工具使用率 vs 贡献率；支持手动复盘"
      - "v3.8.0-mf: 日志扩展完整字段：token 消耗（Grok/Perplexity 精确值）、费用、tool_calls 次数、sub_questions、direction_change、confidence；复盘加费用分析；phases 修正为 5"
      - "v3.9.0-mf: 工具局限表（9 条已知局限 + 应对策略）；数据来源：Grok API 文档 + Tavily 搜索 + 实测"
  pattern: spiral-convergence
  phases: 5
  requires:
    env: ["TAVILY_API_KEY"]
    optional: ["FIRECRAWL_API_KEY", "YOUTUBE_API", "DATAFORSEO_LOGIN", "DATAFORSEO_PASSWORD", "OPENROUTER_API_KEY", "XAI_API_KEY"]
---

# Research Pro v3.7-mf（螺旋收敛模型）

**核心原则：** 不是"问清楚再搜"，是"边搜边搞清楚"。先看本地，再看网络。

---

## 核心机制：研究地图（Research Map）

在整个研究过程中，在工作记忆中维护研究地图，每轮结束后**必须更新**。

```
研究地图
├── 原始问题: "..."
├── 核心目标: "..."（一句话：最终要知道什么）
├── 当前假设: [对答案的初步猜测，每轮 Reflection 后更新]
├── 子问题列表:
│     - Q1: [问题] | 状态: 未知/部分/已知 | 置信度: 高/中/低
│     - Q2: ...
├── 已知事实: [每条必须带来源 URL 或本地路径]
├── 线索池:
│     - {描述, 来源, 相关性分 0-3, 已追/未追}
└── 搜索轮次: N / 上限: M
```

研究地图是思考过程的载体，不是最终输出。

---

## Phase 1：理解问题

**目标：** 验证问题前提，拆成 2-4 个可以独立回答的子问题。

### Step 1.1：本地上下文检查（先做，再拆问题）

在搜索任何东西之前，先检查本地：

- **问题涉及"我们的"或"当前"系统/项目** → 先读相关文件（配置、代码、文档）
- **问题是关于某工具/库是否存在或已集成** → 先检查 `package.json`、配置文件、`extensions/`、`plugins/`
- **问题涉及某个决策或现状** → 先查 `shared/docs/`、`DECISIONS.md`、`PROJECTS.md`

**本地检查结果决定下一步：**
- 发现问题前提错误（如"要不要集成X" → X 已经集成了）→ 立即触发 Phase 4 方向转变，问用户
- 发现有用的上下文 → 加入研究地图"已知事实"，跳过对应子问题的外部搜索
- 没有相关本地信息 → 继续 Step 1.2

### Step 1.2：歧义检查

检查问题是否有未定义的关键词：
- "我们的系统" / "最好的" / "值不值得" → 确认判断标准
- 问题涉及两个层面但只说了一个（如"multi-agent"可能指架构层面或 LLM 部署层面）
- 问题极其模糊（如"帮我研究AI"）

发现歧义 → 问用户 **1 个** 最关键的澄清问题（只问一个）

### Step 1.3：拆子问题

1. 提炼**核心目标**（一句话）
2. 写下**当前假设**（哪怕是错的）
3. 拆出 2-4 个子问题

**⛔ Gate：**
- 每个子问题必须能独立回答
- 所有子问题合起来必须覆盖核心目标

### Step 1.4：告知用户

Phase 1 结束时输出一行：
```
深度：[Quick/Standard/Deep]（最多 N 轮）| 子问题：Q1, Q2, Q3 | 如需调整深度请说明
```

---

## Phase 2：搜索准备

**目标：** 为每个"未知"或"部分"子问题构建 query，选工具。

1. 每个子问题提取 **2-3 个 keyword 组合**
2. 对每个子问题过一遍**信号路由规则**（见下方），确定工具组合
3. 执行**工具覆盖检查**
4. 按"对核心目标的影响"排优先级

**Keyword 构建原则：**
- 用具体名词，不用动词短语（"React RSC limitations 2025" 好过 "what are the problems with RSC"）
- 一个宽泛版本 + 一个具体版本
- 技术问题加版本号或年份

### 信号路由规则（必须逐条过）

对每个子问题，按顺序检查以下信号。匹配到的工具**必须加入**该子问题的工具组合（不是二选一，是叠加）：

| # | 信号 | 触发条件 | 必须加入的工具 |
|---|------|---------|---------------|
| S1 | 社区情绪 | 问题涉及"开发者怎么看"、"社区反馈"、"用户体验"、产品口碑 | Grok x_search + Tavily site:reddit.com |
| S2 | 实时性 | 问题涉及"最新"、"最近"、"2026"、"本周"、新闻、发布 | Perplexity sonar（快）或 Grok web_search（带引用） |
| S3 | 深度对比 | 问题是 A vs B、技术选型、竞品分析 | Tavily Research + 至少一个实时工具（S2） |
| S4 | 教程/How-to | 问题涉及"怎么做"、实现方式、代码示例 | Tavily search + YouTube（可能有视频教程） |
| S5 | 市场/热度 | 问题涉及"有多少人用"、"趋势"、"市场份额" | DataForSEO + Grok x_search |
| S6 | 单一权威源 | 已知某个 URL 有关键信息 | Firecrawl scrape（非 Reddit）/ Tavily extract（Reddit） |

**没有匹配任何信号？** → 默认 Tavily search。

### 工具覆盖检查（⛔ 强制）

选完工具后，必须回答这个问题：

> "这组子问题里，有没有哪个维度只用了 Tavily？如果是，有没有第二个工具能提供**不同视角**的信息？"

- 如果所有子问题都只用 Tavily → **至少给一个子问题加一个非 Tavily 工具**
- 每次研究至少使用 **2 种不同的工具**（Tavily 算一种）

**工具选择矩阵（基于实测 2026-04-12）：**
| 问题类型 | 时效 | 首选工具 | 命令 | 备用 |
|---------|------|---------|------|------|
| 通用技术搜索 | 不限 | Tavily | `tvly search "query"` | Firecrawl search |
| 深度综合报告 | 不限 | Tavily Research | `tvly research "query"` | — |
| 最新动态/实时 | 实时 | Perplexity sonar | OpenRouter REST API | Tavily |
| 社区/Reddit 讨论 | 近期 | Tavily site filter | `tvly search "query site:reddit.com"` | WebSearch |
| 深挖单页（普通） | 不限 | Firecrawl scrape | `firecrawl scrape "URL"` | Tavily extract |
| 深挖单页（Reddit） | 不限 | Tavily extract | `tvly extract "URL"` | WebFetch |
| 视频内容 | 不限 | YouTube API + Transcript | 见下方两步流程 | — |
| 关键词热度/SERP | 不限 | DataForSEO | REST API | — |
| 复杂推理 + 实时搜索 | 实时 | Perplexity sonar-pro | OpenRouter REST API | Tavily Research |
| X/Twitter 实时讨论 | 实时 | Grok x_search | Responses API `/v1/responses` | Tavily site:x.com |
| 实时网页搜索（带引用） | 实时 | Grok web_search | Responses API `/v1/responses` | Perplexity sonar |

**已知局限（选工具时必须考虑）：**
| 工具 | 局限 | 应对 |
|------|------|------|
| Tavily search | 结果偏 SEO 优化内容，深度不够；JS 重度渲染页可能抓不全 | 深度内容用 Firecrawl scrape 或 Tavily Research |
| Tavily Research | ~42s 慢；结果是 AI 综合的，可能丢原始细节 | 需要原始来源时用 search + extract 组合 |
| Tavily extract | 对复杂 JS SPA 页面效果差 | 换 Firecrawl scrape |
| Firecrawl | ❌ 无法抓 Reddit；Cloudflare 保护的站点可能被拦；付费墙内容抓不到 | Reddit → Tavily extract；被拦 → WebFetch |
| Grok x_search | ~50s 慢；日期过滤只支持 YYYY-MM-DD 精度到天；很老的帖子相关性下降 | 时效性强的问题优先用；历史讨论考虑 Tavily site:x.com |
| Grok web_search | ~50s 慢；非英文内容覆盖可能不如 Tavily | 中文搜索优先用 Tavily 或 Perplexity |
| Perplexity sonar | 引用可能存在幻觉（URL 看着对但内容不匹配）；结果是 AI 综合的 | Critic 步骤必须验证关键引用 URL 真实性 |
| YouTube | 不是所有视频有字幕；自动字幕质量参差；API quota 有限 | 检查 transcript 可用性再决定是否深挖 |
| DataForSEO | 中文关键词支持有限；数据有延迟（非实时） | 中文市场用 Grok x_search 补充 |

**调用方式：**
```bash
# Tavily — 快速搜索（1.7s）
tvly search "query"
tvly extract "https://url"

# Tavily — 深度综合报告（~42s，自动整合多源）
tvly research "query"

# Perplexity via OpenRouter — 实时网络搜索 + 推理（需要 OPENROUTER_API_KEY）
# sonar: 快速实时搜索；sonar-pro: 更深度，带引用
source ~/.openclaw/.env
curl -s https://openrouter.ai/api/v1/chat/completions \
  -H "Authorization: Bearer $OPENROUTER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"perplexity/sonar","messages":[{"role":"user","content":"QUERY"}],"max_tokens":500}'

# Firecrawl — 深挖单页完整内容（不支持 Reddit）
firecrawl search "query" --limit 10
firecrawl scrape "https://url"

# YouTube — 两步流程：先找视频，再提取字幕
# Step 1: YouTube Data API（需要 YOUTUBE_API env var）
curl "https://www.googleapis.com/youtube/v3/search?part=snippet&q=QUERY&type=video&maxResults=5&key=$YOUTUBE_API"
# Step 2: 提取字幕（无需额外 key）
youtube_transcript_api "VIDEO_ID" --format text

# DataForSEO — 关键词搜索量 + SERP 结构分析
# 使用 DATAFORSEO_LOGIN / DATAFORSEO_PASSWORD env vars
# REST API: https://api.dataforseo.com/v3/serp/google/organic/live/advanced

# Grok web_search — 实时网页搜索，带引用（~50s，返回带 URL 引用的结构化回答）
# 必须用 grok-4 系列模型（grok-3 不支持 server-side tools）
source ~/.openclaw/.env
curl -s https://api.x.ai/v1/responses \
  -H "Authorization: Bearer $XAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"grok-4","tools":[{"type":"web_search"}],"input":"QUERY","max_output_tokens":500}'

# Grok x_search — X/Twitter 实时讨论搜索（Tavily 做不到的独特能力）
source ~/.openclaw/.env
curl -s https://api.x.ai/v1/responses \
  -H "Authorization: Bearer $XAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"grok-4","tools":[{"type":"x_search"}],"input":"QUERY","max_output_tokens":500}'

# Grok web_search + x_search 同时使用（网页 + X/Twitter 双搜）
source ~/.openclaw/.env
curl -s https://api.x.ai/v1/responses \
  -H "Authorization: Bearer $XAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"grok-4","tools":[{"type":"web_search"},{"type":"x_search"}],"input":"QUERY","max_output_tokens":500}'

# 解析 Grok 响应：输出文本在 output[].content[].text（type=message 的元素里）
# 引用在 output[].content[].annotations[]（type=url_citation）
# 计费: $5 / 1000 tool calls（单独计费）
```

**⛔ Gate：** 每个子问题有至少 2 个 keyword 组合才能开始搜索。

---

## Phase 3：搜索 + 地图更新（循环核心）

**目标：** 执行搜索，更新研究地图，发现并评分新线索。

**步骤：**

1. **并行发起**所有未知子问题的搜索
2. 对每条结果：
   - 提取事实 → 加入已知事实（**必须带来源 URL**）
   - 更新子问题状态
3. 扫描结果中的新线索，打分：

**线索评分：**
| 分 | 标准 | 动作 |
|----|------|------|
| 3 | 直接回答子问题，或根本改变核心目标理解 | 立即追 |
| 2 | 与核心目标相关，但是支线 | 加入线索池，本轮后追 |
| 1 | 边缘相关，不影响核心目标 | 记录但不追 |
| 0 | 不相关或重复 | 忽略 |

**Critic（每轮必做）：**
- 已知事实中有矛盾吗？→ 标记为争议点
- 关键来源 URL 是真实可访问的吗？
- 给每条关键事实打 Evidence Strength（强/中/弱）

**Reflection（每轮必做，1-2 句）：**
> "本轮最重要的新发现是什么？哪个假设被推翻或加强？下一轮优先追什么？"

更新研究地图中的"当前假设"。

**自我校准规则：**
- 已知事实越多 → 1 分线索阈值自动提高（更严格）
- 某方向连续 2 轮无新发现 → 降低优先级，换方向
- 新线索与已有假设矛盾 → 自动升为 3 分，优先追

**Token 管理：**
- 每 3 轮：summarize 已知事实为要点列表，清理 0-1 分线索

---

## Phase 4：收敛判断

每轮 Phase 3 完成后（或 Phase 1 检查发现重大问题时）执行：

**1. 方向转变检查（最优先）**
- 发现问题前提错误，或本轮发现根本改变了核心目标？
- 是 → 暂停，告诉用户具体发现了什么，问是否调整方向
- 否 → 继续

**2. 覆盖检查**
- 所有子问题状态都是"已知"？→ 进入输出
- 还有"未知" + 线索池有 3 分线索？→ 回 Phase 3 继续
- 还有"未知"但线索池空了？→ 回 Phase 2 重新构建 keyword

**3. 轮次上限**
- Quick: 2 轮 | Standard: 5 轮 | Deep: 10 轮
- 达到上限未完全覆盖 → 输出"部分结果"，说明缺口

---

## Phase 5：日志 + 自我优化

### Step 5.1：自动日志（每次研究结束后必做）

输出报告后，用 Bash 追加一行 JSONL：

```bash
echo '{...}' >> ~/.openclaw/projects/research-pro-v3/run-log.jsonl
```

**JSONL 字段（完整）：**

```jsonc
{
  // 基础
  "ts": "2026-04-13",
  "question": "简短问题摘要",
  "depth": "standard",
  "rounds": 3,
  "sub_questions": 3,
  "direction_change": false,
  "confidence": "high",

  // 工具追踪
  "tools_used": ["tavily", "grok_x", "perplexity"],
  "tools_contributed": ["tavily", "grok_x"],
  "tools_planned_not_used": ["youtube"],
  "tool_calls": {"tavily": 4, "grok_x": 1, "perplexity": 1},
  "signals_matched": ["S1", "S3"],

  // 质量
  "citations": 22,
  "gaps": 0,

  // Token & 费用（从 API 响应中提取）
  "tokens": {
    "grok": {"in": 4312, "out": 1696, "calls": 1},
    "perplexity": {"in": 850, "out": 420, "calls": 1},
    "tavily": {"calls": 4},
    "firecrawl": {"calls": 0},
    "youtube": {"calls": 0},
    "dataforseo": {"calls": 0}
  },
  "cost_usd": {
    "grok": 0.035,
    "perplexity": 0.002,
    "tavily": 0,
    "total": 0.037
  }
}
```

**Token 数据提取方式：**

```bash
# Grok — 响应自带（精确）
# response.usage.input_tokens / output_tokens / cost_in_usd_ticks
# cost_in_usd_ticks 除以 1,000,000,000 = USD

# Perplexity via OpenRouter — 响应自带（精确）
# response.usage.prompt_tokens / completion_tokens

# Tavily / Firecrawl / YouTube / DataForSEO — 只记调用次数
```

**字段说明：**
- `tools_used`: 实际调用了的工具
- `tools_contributed`: 结果进入了最终报告的工具（关键指标）
- `tools_planned_not_used`: 计划用但没用的（信号误匹配）
- `tool_calls`: 每个工具调了几次（不只是用/没用）
- `signals_matched`: 触发了哪些 S1-S6 信号
- `sub_questions`: 拆了几个子问题
- `direction_change`: 是否触发了方向转变（Phase 4.1）
- `confidence`: 最终结论的整体置信度
- `tokens`: 每个 API 工具的精确 token 消耗
- `cost_usd`: 换算成美元的费用（grok 从 cost_in_usd_ticks 算，perplexity 按费率算）
- `gaps`: 未解决缺口数量

### Step 5.2：阈值复盘（每 10 次自动触发）

Phase 1 开始前，检查日志行数：

```bash
wc -l < ~/.openclaw/projects/research-pro-v3/run-log.jsonl 2>/dev/null || echo 0
```

如果行数是 **10 的倍数且 > 0**，在 Phase 1 之前输出复盘：

**复盘必须回答这 5 个问题：**

1. **工具效率**：每个工具的使用率 vs 贡献率是多少？
   - 使用率高但贡献率低 → 该工具被过度使用
   - 使用率低但贡献率高 → 信号路由太窄，应扩大触发条件
2. **信号准确度**：哪些信号经常触发但工具没贡献？→ 信号条件需收紧
3. **工具盲区**：有没有哪种问题类型总是只用 Tavily？→ 覆盖检查没起作用
4. **缺口趋势**：gaps 数量是在减少还是增加？→ 整体质量趋势
5. **Token & 费用**：总 token 消耗和费用趋势，哪个工具性价比最低？

复盘格式：
```
📊 research-pro 复盘（过去 10 次）
工具效率：
  - tavily: 10/10 用 → 8/10 贡献 (80%) ✅ 主力稳定
  - grok_x: 3/10 用 → 3/3 贡献 (100%) ⚠️ 命中率高但触发太少
  - youtube: 2/10 用 → 0/2 贡献 (0%) ⚠️ 考虑降优先级
信号调整建议：
  - S1 扩大触发词（加入"争议"、"吐槽"）
  - S4 对 YouTube 改为可选而非默认
Token & 费用：
  - 总计: ~58K tokens, $0.42
  - 平均/次: ~5.8K tokens, $0.042
  - grok: 15K tokens ($0.35) — 占总费用 83%，但贡献了 40% 关键发现
  - perplexity: 8K tokens ($0.07) — 性价比高
整体：gaps 平均 0.3/次 → 质量良好
```

复盘只输出，不阻塞研究流程。

---

## 调用方式

**用户直接调用：**
```
"帮我研究 [主题]"  →  自动进入 Phase 1
深度默认 Standard（5轮）
```

**Agent 结构化调用：**
```json
{
  "question": "...",
  "depth": "quick|standard|deep",
  "context": "已知背景，跳过部分 Phase 1"
}
```

**复盘调用（随时可用）：**
```
"复盘 research-pro" 或 "research-pro review"
→ 读 run-log.jsonl，输出复盘分析（不需要凑够 10 次）
```

---

## 输出格式

```markdown
深度：Standard（最多5轮）| 子问题：Q1, Q2, Q3 | 如需调整深度请说明

# 研究结果：[核心目标]

## 结论
[1-3 句话直接回答]

## 子问题答案
### Q1: [问题]
[答案] | 置信度: 高/中/低 | 证据强度: 强/中/弱

## 关键发现
- [发现] — [来源](URL)

## 争议点 & 反证
- [相互矛盾的发现，双方来源]（如有）

## 未解决的缺口
- [未完全回答的部分]（如有）

## 搜索摘要
共 N 轮 | M 个来源 | 追踪了 X 条线索
```

---

## 执行铁律

禁止：
- ❌ 跳过 Phase 1 的本地上下文检查直接搜索
- ❌ 发现问题前提错误还继续执行
- ❌ 搜完不更新研究地图
- ❌ 引用没有来源 URL 的"事实"
- ❌ 跳过 Reflection 步骤

必须：
- ✅ Phase 1 先查本地，再查网络
- ✅ Phase 1 结束后告知用户深度和子问题
- ✅ 每轮结束更新研究地图
- ✅ 每轮做 Critic + Reflection
- ✅ 所有事实带来源
- ✅ 方向大变时问用户
- ✅ 研究结束后写日志（Phase 5）
- ✅ 每 10 次自动输出复盘
