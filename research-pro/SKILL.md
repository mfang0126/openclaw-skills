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
version: 3.3.0-mf
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
  pattern: spiral-convergence
  phases: 4
  requires:
    env: ["TAVILY_API_KEY"]
    optional: ["FIRECRAWL_API_KEY", "YOUTUBE_API", "DATAFORSEO_LOGIN", "DATAFORSEO_PASSWORD", "OPENROUTER_API_KEY", "XAI_API_KEY"]
---

# Research Pro v3.1-mf（螺旋收敛模型）

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
2. 选工具（见下方矩阵）
3. 按"对核心目标的影响"排优先级

**Keyword 构建原则：**
- 用具体名词，不用动词短语（"React RSC limitations 2025" 好过 "what are the problems with RSC"）
- 一个宽泛版本 + 一个具体版本
- 技术问题加版本号或年份

**工具选择（基于实测 2026-04-12）：**
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
| X/Twitter 实时讨论 | 实时 | 🔲 TODO: Grok x_search | 需用 Responses API `/v1/responses`，见下方备注 | Tavily site:x.com |

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

# 🔲 TODO: Grok web_search + x_search（实时网页 + X/Twitter）
# 必须用 Responses API，不是 /v1/chat/completions
# 正确端点: POST https://api.x.ai/v1/responses
# 正确格式:
#   "tools": [{"type": "web_search"}, {"type": "x_search"}]
#   "model": "grok-4.20-reasoning"（reasoning 系列幻觉最少）
# 支持参数: allowed_domains, excluded_domains, enable_image_understanding
# 计费: $5 / 1000 tool calls（单独计费）
# 参考: https://docs.x.ai/docs/guides/tools/overview
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
