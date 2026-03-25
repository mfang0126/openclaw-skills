# Skill 开发权威指南

> 最后更新：2026-03-24
> 整合：Google ADK 五模式 + Skill Creator 方法 + 项目经验
> **写 skill 前必读此文件**

---

## 一、先选模式（Google ADK 五模式）

写 skill 之前，先判断你要解决什么问题：

```
这个 Skill 要做什么？
├── 运行时加载某套知识        → Tool Wrapper
├── 产出固定结构的内容        → Generator
├── 评估/审查已有输入          → Reviewer
├── 开始前必须先补全信息      → Inversion
└── 有严格步骤不能跳的流程    → Pipeline
```

### 1. Tool Wrapper（按需注入知识）

**问题：** 把所有知识塞进 system prompt，浪费 context
**做法：** Skill 只在需要时加载对应知识

```
skill-name/
├── SKILL.md          ← 判断何时加载哪个 reference
└── references/
    ├── react.md      ← 只在改 React 时加载
    ├── database.md   ← 只在改 DB 时加载
    └── api.md
```

**例子：** 改 React 页面 → 加载 React 规范；写 SQL → 不加载前端知识

### 2. Generator（固定输出结构）

**问题：** 同样的任务，每次输出格式不一样
**做法：** 模板 + 风格指南，不让 AI 现场发挥

两个核心组件：
- **Template** — 产出什么（必须有哪些段落）
- **Style Guide** — 怎么写（语气、格式、术语）

**例子：** API 文档、commit message、技术报告

### 3. Reviewer（审查器）

**问题：** 检查什么和怎么检查混在一起
**做法：** 拆开——Checklist 可换，流程不变

输出统一成：
- **ERROR** — 必须修
- **WARNING** — 建议修
- **INFO** — 只是提醒

**例子：** 代码审查、安全检查、合规检查

### 4. Inversion（先问再做）

**问题：** AI 太爱猜，信息不够就开始做
**做法：** 先发问补全信息，门控指令：信息没齐不准开工

三个阶段：
1. **Discovery** — 确认要解决什么问题
2. **Constraints** — 问完平台、技术栈、限制条件
3. **Synthesis** — 信息齐了才开始

**例子：** 需求澄清、方案规划

### 5. Pipeline（流水线）

**问题：** 多步骤任务跳步骤
**做法：** 写成工作流定义 + 门控（Gate）

每步明确：做什么 → 什么条件进入下一步 → 每步只加载当前所需 reference

**例子：** 文档生成、发布流程、复杂代码修改

### 模式可以叠加

- Generator 前面接 Inversion（先问再生成）
- Pipeline 结尾接 Reviewer（最后审查）
- Tool Wrapper 叠在任何模式上（按需注入知识）

---

## 二、Skill 文件结构

```
skill-name/
├── SKILL.md           # 核心文件（必需，< 500 行）
├── _meta.json         # 元数据（可选）
├── scripts/           # 可执行脚本
│   └── main.sh
├── references/        # 按需加载的文档
│   ├── aws.md
│   └── vercel.md
├── assets/            # 模板、图标等
└── evals/             # 测试用例
    └── evals.json
```

### SKILL.md 必需结构

```markdown
---
name: skill-name
description: |
  一段话说明做什么 + 什么时候触发。
  要 pushy——列出触发关键词，明确替代关系。
  
  USE FOR:
  - 具体场景1
  - 具体场景2
  - "用户会说的话1", "用户会说的话2"
metadata: {"clawdbot":{"emoji":"🔧","requires":{"bins":["aws"]}}}
---

# Skill 标题

## When to Use
（和 description 呼应，更详细）

## Prerequisites
（依赖、API key、安装步骤）

## Quick Start
（最常用的命令/流程）

## Instructions
（详细步骤，用自然语言条件）

## Examples
（至少一个完整示例）

## Error Handling
（常见错误 + 解决方案表格）
```

### Description 是最重要的部分

Description 决定 AI 何时自动触发 skill。写得不好 = skill 永远不会被用到。

**好的 description：**
```yaml
description: |
  Add custom domains to Vercel projects with automatic AWS Route 53 DNS setup.
  
  USE FOR:
  - "帮我加域名", "bind domain", "domain setup"
  - Adding subdomain to Vercel project
  - Setting up DNS records in Route 53
  - Vercel + AWS domain configuration
  
  REQUIRES: vercel CLI, aws CLI with SSO profile
```

**差的 description：**
```yaml
description: Manage domains  # 太模糊，不会被触发
```

---

## 三、Progressive Disclosure（三层加载）

1. **Metadata**（name + description）— 始终在 context（~100 words）
2. **SKILL.md body** — skill 触发时加载（< 500 行）
3. **References** — 按需加载（无限制）

**原则：** SKILL.md 里放决策逻辑和流程，重的知识放 references/

---

## 四、条件逻辑写法

**用自然语言，不用代码：**

```markdown
## Instructions

1. Check if AWS SSO session is valid
   - If valid → proceed to Step 2
   - If expired → run `aws sso login --profile yuyan-dev --use-device-code`
   - Send device code to user, wait for confirmation

2. Add domain to Vercel
   - If project found → `vercel domains add <domain> <project>`
   - If project not found → list projects, ask user to choose
```

**决策树（复杂分支用）：**
```
User request
    │
    ├── Has specific project name? → add domain directly
    │
    └── No project name? → list projects first
                              │
                              ├── User picks one → add domain
                              └── User says "cancel" → stop
```

---

## 五、开发流程（Skill Creator 方法）

### 1. 确定意图
- Skill 做什么？
- 什么时候触发？
- 输出什么格式？

### 2. 选择模式
→ 回到第一节的决策树

### 3. 写 Draft
- SKILL.md < 500 行
- Description 要 pushy
- 至少一个完整 Example

### 4. 写测试用例（2-3 个）
```json
{
  "skill_name": "vercel-domain-setup",
  "evals": [
    {
      "id": 1,
      "prompt": "帮我把 app.lighttune.com.au 绑到 Vercel 的 fortune-web-app 项目",
      "expected_output": "DNS 记录创建成功，域名可访问"
    }
  ]
}
```

### 5. 跑测试 → Review → 改进 → 重复

### 6. 优化 Description
用 skill-creator 的 `run_loop` 脚本优化触发准确率。

---

## 六、我们的账号配置（写 skill 时要知道）

### Vercel 账号
| 账号 | Scope | 用途 |
|------|-------|------|
| mfang0126 | mfang0126s-projects | 个人项目 |
| yuyanceshi | lighttune | CCL/商业项目 |

切换：`vercel login` → device code flow

### AWS Profiles
| Profile | Account | 用途 |
|---------|---------|------|
| yuyan-dev | 207567773792 | 开发环境，有 Route 53 |
| yuyan-prod | 605134460779 | 生产环境 |
| freedom | 348818836721 | freedom 账号 |
| mingfang | 670326884047 | mingfang SSO |
| default | 670326884047 | s3.tech（只有 S3 权限）|

SSO 登录：`aws sso login --profile <name> --use-device-code`

---

## 七、参考文件索引

| 文件 | 位置 | 内容 |
|------|------|------|
| Google ADK 五模式原文 | `research/google-adk-skill-patterns.md` | 详细解释 + 示例 |
| Skill Creator 完整流程 | `~/.agents/skills/skill-creator/SKILL.md` | eval、benchmark、优化 |
| 已安装 Skills 列表 | `~/.agents/SKILLS_REGISTRY.md` | 63 个 skill 索引 |
| Skill Development Guide (旧) | `docs/SKILL_DEVELOPMENT_GUIDE.md` | 2月版，已被本文替代 |
