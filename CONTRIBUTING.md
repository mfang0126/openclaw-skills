# OpenClaw Skills 开发维护指南

> **面向所有维护者（包括 AI agent）。** 修改本 repo 中任何 skill 前，先读此文件。
> **第一步：** 读完此文件后，读 `.dev/TODO.md`（任务队列）和 `.dev/SESSION.md`（上次做了什么）。

---

## 0. 目录架构

### 0.1 三个位置，三个用途

| 位置 | 用途 | 工具 |
|------|------|------|
| `~/Code/openclaw-skills/` | 开发（版本控制） | git |
| `~/.openclaw/skills/` | 运行（私有 skill + 状态） | OpenClaw 默认读取 |
| GitHub (mfang0126/openclaw-skills) | 分发（别人装 skill） | git push |

### 0.2 extraDirs 机制

OpenClaw 通过 `extraDirs` 同时从两个位置加载 skill：

```json
// ~/.openclaw/openclaw.json
"skills": { "load": { "extraDirs": ["~/Code/openclaw-skills"] } }
```

- **公开 skill** → 在 `~/Code/openclaw-skills/` 里开发，OpenClaw 自动读到（source: `openclaw-extra`）
- **私有 skill** → 留在 `~/.openclaw/skills/`，不需要同步
- **不需要 sync 脚本、不需要 rsync、不需要符号链接**

### 0.3 .dev/ 目录（gitignored）

`.dev/` 存放开发过程文件，不提交、不推送：

```
.dev/
├── TODO.md           ← 任务队列（每个 session 开始时读）
├── SESSION.md        ← 会话交接（每个 session 结束时更新）
└── case-studies/     ← 踩坑记录和教训
```

### 0.4 文件路由

| 文件类型 | OpenClaw 可读 | push 到 GitHub |
|---------|:---:|:---:|
| 公开 skill（xhs-publisher 等） | ✅ via extraDirs | ✅ |
| 私有 skill（~/.openclaw/skills/） | ✅ 默认位置 | ❌ |
| 开发文件（.dev/） | ❌ | ❌ |
| 运行时状态（state.json） | ❌ | ❌ |

---

## 为什么有这个文件

这个 repo 包含 50+ 个 skill，由不同的人（和 AI）在不同时间维护。没有统一的开发规范，就会出现：

- 硬编码路径，换台机器就不能用
- 直接 push 到 main，没有测试和 review
- 改了文件忘了改对应文档，不一致
- 新来的 AI session 不知道规矩，重复犯错

**本文件的目标：让任何 AI session 在开发第一个 commit 之前就知道所有规矩。**

---

## 1. Git 工作流

### 1.1 Branch 策略

```
main (受保护，禁止直接 push)
  └── feat/xxx (所有开发在这里)
       └── 改完 → 测试 → review → merge 回 main
```

**铁律：**
- 禁止直接 push 到 main
- 所有改动在 feature branch 上进行
- branch 命名：`feat/描述` 或 `fix/描述`
- merge 前必须通过测试

### 1.2 Commit 策略

**每个逻辑步骤一个 commit，方便回退和追踪：**
```
docs: add CONTRIBUTING.md — global development guide
feat: add config support to xhs-publisher
fix: correct relative path in cli-contract.md
```

**Commit message 格式：**
```
<type>: <简短描述>

type:
  feat     — 新功能
  fix      — 修复问题
  docs     — 文档改动
  refactor — 代码重构（不改变行为）
  test     — 测试相关
  chore    — 杂项（配置、gitignore 等）
```

### 1.3 Main 分支保护

| 规则 | 状态 | 执行层 |
|------|------|--------|
| 禁止直接 push | ✅ | 本地 pre-push hook |
| 禁止 force push | ✅ | GitHub branch protection |
| 禁止删除分支 | ✅ | GitHub branch protection |
| 管理员也受限 | ✅ | GitHub branch protection |

**绕过本地 hook（仅紧急情况）：** `git push --no-verify`

### 1.4 常用 git 命令

```bash
# 开始开发
git checkout -b feat/your-feature

# 查看改动
git diff                              # 工作区改动
git diff main...HEAD --stat           # 跟 main 的所有差异
git show <commit-hash>                # 某个 commit 的具体内容

# 回退
git reset --soft HEAD~1               # 回退 commit，保留改动
git reset --hard HEAD~1               # 回退 commit，丢弃改动

# 合并（确认无误后）
git checkout main && git merge feat/your-feature
```

---

## 2. 路径规范

### 2.1 绝对禁止

- ❌ 硬编码绝对路径（如 `~/Projects/xxx`、`~/.openclaw/skills/xxx/`）
- ❌ 硬编码用户名、账号名（如 `myaccount`、`mingfang`）

### 2.2 正确做法

| 需要什么 | 怎么做 |
|---------|--------|
| 外部工具路径 | 从 config.json 读取 |
| skill 内部文件 | 用相对路径（`./scripts/xxx.py`） |
| 用户特定信息 | 从 config.json 读取 |

### 2.3 文档中的路径写法

❌ **不要用占位符**（AI 会原样执行）：
```
python3 {skill_dir}/scripts/publish.py --account {account}
```

✅ **用自然语言指示 AI**：
```
从 config.json 读取 account 值，然后从 skill 根目录运行：
python3 ./scripts/publish.py --account <account>
```

---

## 3. 配置管理

### 3.1 双文件模式

| 文件 | 在 repo 里 | 用途 |
|------|-----------|------|
| `config.template.json` | ✅ 是 | 模板，展示所有可配置项和默认值 |
| `config.json` | ❌ 否（gitignore） | 用户实际配置，不会被更新覆盖 |

### 3.2 谁读 config

```
用户 → 创建 config.json（从 template 复制并填写）
AI    → 读取 config.json，把值作为 CLI 参数传给脚本
脚本  → 只接受 CLI 参数，不自己读 config.json
```

**脚本保持"哑"——可独立测试、可复用。**

### 3.3 什么该提交 / 不该提交

| 提交 ✅ | 不提交 ❌ |
|---------|----------|
| 脚本、文档、配置模板 | config.json、state.json |
| 测试用例 | .venv/、node_modules/ |
| .gitignore | cookie、token、浏览器 profile |

---

## 4. 每个 Skill 的 CONTRIBUTING.md

**复杂 skill（有脚本、配置、状态管理）应该在 skill 目录下有自己的 CONTRIBUTING.md。**

简单的 skill（一个 SKILL.md 搞定）不需要。

skill 级 CONTRIBUTING.md **只写 skill 特有的内容**，不重复全局规则：

```
xhs-publisher/CONTRIBUTING.md 应该包含：
  ✅ 脚本参数说明（publish.py、warmup.py）
  ✅ 测试方法（怎么 dry run、怎么验证频率检查）
  ✅ skill 特有的陷阱（如 sau 路径推导、cookie 过期处理）

xhs-publisher/CONTRIBUTING.md 不应该包含：
  ❌ Git 工作流（看根目录的）
  ❌ 路径规范（看根目录的）
  ❌ 配置管理模式（看根目录的）
```

### 何时需要 skill 级 CONTRIBUTING.md

| 条件 | 需要？ |
|------|--------|
| 有脚本（.py, .sh） | ✅ |
| 有 config.json | ✅ |
| 有状态文件（state.json） | ✅ |
| 有外部 CLI 依赖 | ✅ |
| 只有 SKILL.md | ❌ |

---

## 5. Review 流程

修改完成后，按以下顺序验证：

1. **`git diff HEAD~1`** — 看本次 commit 改了什么
2. **`git diff main...HEAD --stat`** — 看跟 main 总共差了什么
3. **功能测试** — 脚本 `--help`、配置可读性
4. **硬编码检查** — `grep -rn "myaccount\|~/Projects\|~/.openclaw/skills" --include="*.md" --include="*.json" --include="*.py"`
5. **文档一致性** — 改了命令就改文档，改了参数就改示例
6. **报告给用户** — 全部通过后由用户决定是否 merge

---

## 6. 常见陷阱

| 陷阱 | 正确做法 |
|------|---------|
| 直接 push 到 main | 必须用 feature branch |
| 硬编码路径 | config.json + 相对路径 |
| 文档用 `{placeholder}` | AI 会原样执行，用自然语言 |
| 脚本自己读 config.json | AI 读 config，传参给脚本 |
| 改了代码没改文档 | 一起改，一起 commit |
| commit 后立即 push | 测试 → review → 用户确认 → push |
| AI 读文件读到旧缓存 | 把内容直接塞进 prompt |
| 改了多处但一个 commit | 每个 commit 一个逻辑步骤 |
