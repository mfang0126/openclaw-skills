---
user-invocable: false
name: browser-routing
description: |
  Browser tool routing decision maker. Auto-selects the most token-efficient and reliable tool for any web operation.

  USE FOR:
  - "open website", "打开网页", "screenshot", "截图", "view page content"
  - "scrape page", "抓内容", "fill form", "填表单", "login website", "登录网站"
  - "自动化浏览器", "automate browser", "需要用哪个浏览器工具"
  - "web automation", "which browser tool", "browser task", "网页操作"
  - Any task that involves a browser, webpage, or web automation

  REPLACES: Guessing which browser tool to use; prevents costly screenshot token waste

  REQUIRES:
  - At least one browser tool installed: agent-browser, browser-use, or browser (built-in)
  - web_fetch available for read-only tasks (zero token cost)

  **每次涉及浏览器/网页操作时必须先过这个决策树。**
---

# Browser Routing — 浏览器工具统一决策器

**Pattern: Inversion** (Google ADK)

## When to Use
Use this skill **every time** the user asks for anything involving a browser or webpage. It prevents you from defaulting to expensive screenshot-based tools when cheaper alternatives exist (web_fetch, snapshot).

**Don't use when:** The task is clearly not browser-related (e.g., file operations, coding, math).

## Prerequisites
1. At minimum, have `web_fetch` available (built-in, zero cost)
2. For interactive tasks: install `agent-browser` (recommended default)
3. For AI-autonomous tasks: install `browser-use`
4. For OpenClaw cookie access: use the built-in `browser` tool

> 合并自 `docs/BROWSER_ROUTING.md` + `research/2026-03-15-browser-automation-guide.md`
> 更新：2026-03-17（增加 token 成本优先级、web_fetch 前置）

## 核心原则

> **能不开浏览器就不开。能用文字就不用图片。重叠功能选最便宜，独占功能选最强。**

---

## 快速决策（5 秒判断）

```
1. 只读文字？         → web_fetch
2. 需要用户登录态？    → browser + profile="user" 或 browser-use -b real --profile
3. 需要 OpenClaw cookie？ → browser（内置）
4. localhost？         → agent-browser 或 curl
5. AI 自主完成任务？   → browser-use run "task"
6. 需要代理/伪装国家？ → browser-use -b remote --proxy-country
7. 需要录视频？        → agent-browser record
8. 需要 iOS 测试？     → agent-browser -p ios
9. 其他所有           → agent-browser（默认）
```

---

## Token 成本排序（从低到高，严格遵守）

```
1. web_fetch            — 零图片 token，零浏览器
2. web_search           — 零图片 token
3. agent-browser snapshot -i  — 零图片 token，文字 DOM
4. agent-browser 交互    — 零图片 token
5. agent-browser screenshot — 存文件，不消耗 token
6. browser snapshot      — 零图片 token（但启动内置浏览器）
7. browser act           — 零图片 token
8. snap API              — 云端截图，零 token
9. firecrawl             — 大规模抓取
10. browser screenshot   — ⚠️ 消耗图片 token，最后手段
```

---

## 三大浏览器工具能力矩阵

| 能力 | agent-browser | browser-use | browser（内置） |
|------|:---:|:---:|:---:|
| 基础操作（click/fill） | ✅ | ✅ | ✅ |
| Snapshot/DOM | ✅ `snapshot -i` @ref | ✅ `state` index | ✅ `snapshot` |
| Screenshot | ✅ **存文件（零 token）** | ✅ 存文件 | ⚠️ **消耗 token** |
| 登录态持久化 | ✅ `state save/load` | ✅ `--profile` | ✅ OpenClaw profile |
| 真实 Chrome Profile | ✅ `--profile <path>` | ✅ `-b real --profile` | ✅ `profile="user"` |
| CDP 连接 | ✅ `connect <port>` | ❌ | ✅ |
| **视频录制** | ✅ `record start/stop` | ❌ | ❌ |
| **Trace 录制** | ✅ `trace start/stop` | ❌ | ❌ |
| **设备模拟** | ✅ `set device` | ❌ | ❌ |
| **iOS 真机/模拟器** | ✅ `-p ios` | ❌ | ❌ |
| **地理位置模拟** | ✅ `set geo` | ❌ | ❌ |
| **AI 自主 Agent 模式** | ❌ | ✅ `run "task"` | ❌ |
| **云端远程浏览器** | ❌ | ✅ `-b remote` | ❌ |
| **代理国家切换** | ❌ | ✅ `--proxy-country` | ❌ |
| 文件上传 | ✅ `upload` | ❌ | ✅ |
| PDF 导出 | ✅ `pdf` | ❌ | ✅ |
| JS 执行 | ✅ `eval` | ✅ `eval` | ✅ `evaluate` |
| 并行 Session | ✅ `--session` | ✅ `--session` | ✅ `targetId` |
| Token 成本 | **零** | **零** | snapshot 零 / screenshot **高** |

### 独占能力总结

| 工具 | 只有它能做的 |
|------|------------|
| **agent-browser** | 视频录制、iOS 模拟器、地理位置模拟、Trace、设备模拟 |
| **browser-use** | AI 自主模式 `run "task"`、云端远程浏览器、代理国家切换 |
| **browser 内置** | OpenClaw profile 持久化 cookie（唯一能用已有登录态的） |

---

## 按场景选工具

### 读页面内容
```
web_fetch（首选）→ agent-browser snapshot → browser snapshot
```

### 检查是否登录
```
看 URL 是否跳转到 /login → agent-browser snapshot 看 DOM
❌ 永远不要为了检查登录状态而 screenshot
```

### 需要用户已有的 Chrome 登录态（GSC/Gmail/GitHub）
```
browser profile="user"  ← 需用户确认
browser-use -b real --profile "Default"  ← 复制 Chrome profile
```

### 需要 OpenClaw 浏览器已有的 cookie
```
browser（内置）← 唯一选择
```

### 自动化操作（无需登录态）
```
agent-browser（默认首选，零 token）
```

### localhost 预览
```
agent-browser open http://localhost:3000
agent-browser snapshot -i
❌ browser 内置工具可能不支持 localhost
```

### 定时任务 / 固定流程
```
agent-browser + state save auth.json（最可靠）
```

### 截图给用户看
```
agent-browser screenshot out.png → message send media=out.png
❌ 不要用 browser screenshot（token 白花）
```

### 视频录制 / Demo
```
agent-browser record start demo.webm [url]
agent-browser record stop
```

### iOS 模拟 / 移动端测试
```
agent-browser -p ios --device "iPhone 15 Pro" open <url>
```

### 地理位置模拟
```
agent-browser set geo 31.2304 121.4737  ← 上海
```

### AI 自主完成复杂任务
```
browser-use run "登录并下载报告"         ← 本地
browser-use -b remote run "填写表单"     ← 云端
```

### 代理/伪装来源国家
```
browser-use -b remote run "task" --proxy-country cn
```

### 大规模爬取
```
firecrawl scrape/crawl
```

### 连接已运行的 Chrome
```
agent-browser connect 9222
```

---

## 常见错误

| ❌ 错误 | ✅ 正确 |
|--------|---------|
| screenshot 看定价表文字 | web_fetch 直接拿 markdown |
| screenshot 检查是否登录 | 看 URL 是否含 /login |
| browser screenshot 截图发用户 | agent-browser screenshot → message send |
| 简单页面用 browser-use | agent-browser（更省） |
| 固定流程用 browser-use | agent-browser + state save（更可靠） |

---

## 登录态管理

| 方案 | 工具 | 持久性 | 适合 |
|------|------|--------|------|
| OpenClaw profile | browser 内置 | ✅ 自动 | 需要已有 cookie |
| Chrome Extension | browser profile="user" | ✅ 复用用户 session | GSC/Gmail 等 |
| state save/load | agent-browser | ✅ auth.json 文件 | 定时任务 |
| real --profile | browser-use | ✅ 本地 Chrome | 完整 profile |
| cookie sync | browser-use remote | ⚠️ 可能过期 | 云端执行 |

### agent-browser 登录保存
```bash
agent-browser --headed open https://app.example.com/login
# 手动登录...
agent-browser state save ~/.openclaw/auth/site-auth.json

# 后续复用
agent-browser --state ~/.openclaw/auth/site-auth.json open https://app.example.com
```

---

## 其他工具

| 工具 | 用途 | 什么时候用 |
|------|------|-----------|
| **web_fetch** | URL → markdown | 读文字内容（首选） |
| **web_search** | Brave 搜索 | 搜索多个结果 |
| **firecrawl** | 大规模爬取 | 整站抓取/结构化数据 |
| **snap API** | 云端截图 | 远程截图（不占本地） |
| **html-screenshot** | 本地 HTML 截图 | 开发时看效果 |
| **playwright** | 底层驱动 | 自定义脚本（一般不直接用） |

---

## Examples

### Example 1: User wants page content (text only)
**User says:** "What's on the pricing page of example.com?"
**Steps:** Use `web_fetch` (cheapest, zero browser token cost)
**Output:** Markdown text of the page
**Reply:** "Here's what's on the pricing page: ..."

### Example 2: User wants to fill a form
**User says:** "Fill out the signup form on app.example.com"
**Steps:** `agent-browser open → snapshot -i → fill @e1 → click @e2`
**Output:** Confirmation that form was submitted
**Reply:** "Done! The form has been submitted successfully."

## Error Handling

| Error | Cause | Solution |
|-------|-------|----------|
| Chose screenshot when text would do | Defaulted to expensive tool | Always check: can `web_fetch` answer this? Use it first |
| `agent-browser` not found | CLI not installed | Install via `brew install agent-browser` or npm |
| `browser-use` not found | CLI not installed | Run `browser-use doctor` to diagnose and install |
| localhost not accessible via browser built-in | Built-in browser may block localhost | Use `agent-browser open http://localhost:PORT` instead |
| OpenClaw cookies not available in agent-browser | agent-browser uses separate session | Switch to built-in `browser` tool (only one with OpenClaw cookies) |

## 更新记录

| 日期 | 变更 |
|------|------|
| 2026-03-15 | 初版研究 `research/2026-03-15-browser-automation-guide.md` |
| 2026-03-15 | 创建 `docs/BROWSER_ROUTING.md` |
| 2026-03-17 | 合并为统一 skill，增加 token 成本优先级、web_fetch 前置、完整能力矩阵 |
