# xhs-publisher 开发维护指南

> 本文件面向所有维护者（包括 AI agent）。修改此项目前必须先阅读。

---

## 1. 项目概述

xhs-publisher 是一个小红书安全发帖 skill，通过 sau CLI 执行发布，内置频率控制、反 bot 行为模拟和人审门控。

### 架构

```
xhs-publisher/
├── SKILL.md              ← 入口（路由），AI 先读这个
├── CONTRIBUTING.md       ← 本文件，开发维护指南
├── config.template.json  ← 配置模板（在 repo 里）
├── config.json           ← 用户配置（gitignore，不在 repo 里）
├── state.json            ← 发帖状态（gitignore，不在 repo 里）
├── workflow/
│   └── publish-flow.md   ← Step 1-6 发帖流程
├── knowledge/
│   ├── safety-policy.md  ← 频率限制、超发模式、行为模拟
│   ├── content-guidelines.md ← 标题/正文/标签规范
│   ├── cli-contract.md   ← sau 和 publish.py 命令格式
│   ├── runtime-requirements.md ← 环境安装
│   └── troubleshooting.md ← 故障排查
├── scripts/
│   ├── publish.py        ← 安全发帖包装脚本
│   ├── warmup.py         ← 预热脚本
│   └── setup.sh          ← 首次安装向导
└── evals/
    └── evals.json        ← 测试用例
```

---

## 2. Git 工作流

### 2.1 Branch 策略

```
main (受保护，禁止直接 push)
  └── feat/xxx (所有开发在这里)
       └── 改完测试通过 → merge 回 main
```

**规则：**
- **禁止直接 push 到 main** — 本地 pre-push hook + GitHub branch protection 双重保护
- 所有改动在 feature branch 上进行
- branch 命名：`feat/描述` 或 `fix/描述`
- 合并前必须通过测试

### 2.2 Commit 策略

**每个逻辑步骤一个 commit：**
```
docs: add CONTRIBUTING.md — maintenance guide for future AI sessions
refactor: move publish.py and warmup.py into repo with --account and --sau-dir params
feat: add config.template.json and .gitignore
docs: replace hardcoded paths with relative paths in all knowledge files
test: update evals for generic config
```

**Commit message 格式：**
```
<type>: <简短描述>

type 可选值：
  feat     — 新功能
  fix      — 修复问题
  docs     — 文档改动
  refactor — 代码重构（不改变行为）
  test     — 测试相关
  chore    — 杂项（配置、gitignore 等）
```

### 2.3 Main 分支保护

当前保护规则：

| 规则 | 状态 |
|------|------|
| 禁止 force push | ✅ GitHub + 本地 hook |
| 禁止删除分支 | ✅ GitHub |
| 管理员也受限 | ✅ GitHub |
| 禁止直接 push | ✅ 本地 pre-push hook |

**绕过 hook（不推荐）：** `git push --no-verify origin main`

### 2.4 常用 git 命令

```bash
# 创建 feature branch
git checkout -b feat/your-feature

# 查看当前改动
git diff

# 查看跟 main 的所有差异
git diff main...HEAD --stat

# 回退最近一个 commit（保留改动）
git reset --soft HEAD~1

# 回退最近一个 commit（丢弃改动）
git reset --hard HEAD~1

# 查看某个 commit 改了什么
git show <commit-hash>

# 合并回 main（确认无误后）
git checkout main
git merge feat/your-feature
```

---

## 3. 路径规范

### 3.1 绝对禁止

- ❌ **禁止硬编码绝对路径**（如 `~/Projects/social-auto-upload`、`~/.openclaw/skills/xhs-publisher/`）
- ❌ **禁止硬编码账号名**（如 `myaccount`）

### 3.2 正确做法

| 需要什么 | 怎么做 |
|---------|--------|
| sau 路径 | 从 `config.json` 读取 `sau_dir` |
| 账号名 | 从 `config.json` 读取 `account` |
| skill 内部文件 | 用相对路径（如 `./scripts/publish.py`） |
| state.json | 相对路径 `./state.json`（skill 根目录下） |

### 3.3 文档中的写法

❌ 不要用占位符语法（AI 会原样执行）：
```
python3 {skill_dir}/scripts/publish.py --account {account}
```

✅ 用自然语言指示 AI：
```
从 config.json 读取 account 值，然后从 skill 根目录运行：
python3 ./scripts/publish.py --account <account>
```

---

## 4. 配置管理

### 4.1 双文件模式

| 文件 | 在 repo 里 | 用途 |
|------|-----------|------|
| `config.template.json` | ✅ 是 | 模板，展示所有可配置项 |
| `config.json` | ❌ 否（gitignore） | 用户实际配置 |

### 4.2 config.json 结构

```json
{
  "sau_dir": "~/Projects/social-auto-upload",
  "account": "your-account-name"
}
```

### 4.3 什么该提交 / 不该提交

| 提交 ✅ | 不提交 ❌ |
|---------|----------|
| 脚本（publish.py, warmup.py, setup.sh） | config.json |
| 文档（SKILL.md, knowledge/*, workflow/*） | state.json |
| 配置模板（config.template.json） | .venv/ |
| 测试（evals/evals.json） | 浏览器 profile/ |
| CONTRIBUTING.md | cookie 文件 |

---

## 5. 脚本规范

### 5.1 原则

- **脚本不读 config.json** — AI 读 config，通过 CLI 参数传给脚本
- **脚本只接受 CLI 参数** — 保持"哑"，可独立测试
- **publish.py 和 warmup.py 接口一致** — 都接受 `--account` 和 `--sau-dir`

### 5.2 publish.py 参数

```
--account    账号名（必填）
--sau-dir    sau 安装路径（必填）
--type       笔记类型：note 或 video（必填）
--title      标题（必填）
--note       图文正文（图文时）
--desc       视频简介（视频时）
--tags       标签，逗号分隔
--images     图片路径，空格分隔，支持多张
--file       视频文件路径
--schedule   定时发布 YYYY-MM-DD HH:MM
--headed     有头模式（可见浏览器）
--headless   无头模式（默认）
--skip-warmup 跳过预热（仅测试用）
```

### 5.3 warmup.py 参数

```
--account    账号名（必填）
--sau-dir    sau 安装路径（必填）
--headless   无头模式（默认）
--headed     有头模式
```

---

## 6. 测试

### 6.1 脚本测试

```bash
# 验证参数解析
python3 ./scripts/publish.py --help
python3 ./scripts/warmup.py --help

# 快速验证（跳过预热）
python3 ./scripts/publish.py \
  --account test --sau-dir ~/Projects/social-auto-upload \
  --type note --title "测试" --skip-warmup --headed
```

### 6.2 配置测试

```bash
# 验证 config.json 可读
python3 -c "import json; c=json.load(open('config.json')); print(c['sau_dir'], c['account'])"
```

### 6.3 频率检查测试

```bash
# 模拟频率检查逻辑
python3 -c "
import json, datetime
with open('state.json') as f: state = json.load(f)
today = datetime.datetime.now().strftime('%Y-%m-%d')
count = len([p for p in state['posts'] if p['date'] == today])
print(f'今日已发: {count} 篇')
"
```

### 6.4 Session 测试

```bash
# 需要 sau 虚拟环境
source <sau_dir>/.venv/bin/activate
sau xiaohongshu check --account <account>
```

---

## 7. Review 流程

修改完成后，按以下顺序验证：

1. **`git diff HEAD~1`** — 看本次 commit 改了什么
2. **`git diff main...HEAD --stat`** — 看跟 main 总共差了什么
3. **脚本测试** — `--help` 验证参数
4. **配置测试** — 验证 config.json 可读
5. **文档检查** — 确认没有硬编码路径
6. **grep 检查** — `grep -rn "myaccount\|social-auto-upload\|openclaw/skills" --include="*.md" --include="*.json"`

全部通过后，报告给用户，由用户决定是否 merge。

---

## 8. 常见陷阱

| 陷阱 | 正确做法 |
|------|---------|
| AI 直接 push 到 main | hook 会拦截，必须用 feature branch |
| 硬编码路径 | 用 config.json + 相对路径 |
| AI 读到旧缓存文件 | 把文件内容直接塞进 prompt |
| commit 后立即 push | 改完 → 测试 → review → 用户确认 → push |
| publish.py 读 config.json | AI 读 config，传参给脚本 |
| 文档用 `{placeholder}` | AI 会原样执行，用自然语言 |
