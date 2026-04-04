# xhs-publisher 开发维护指南

> **通用规则见 repo 根目录 [CONTRIBUTING.md](../../CONTRIBUTING.md)。** 本文件只记录 xhs-publisher 特有的内容。

---

## 1. 项目概述

xhs-publisher 是一个小红书安全发帖 skill，通过 sau CLI 执行发布，内置频率控制、反 bot 行为模拟和人审门控。

```
xhs-publisher/
├── SKILL.md              ← 入口（路由）
├── CONTRIBUTING.md       ← 本文件
├── config.template.json  ← 配置模板
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

## 2. 脚本参数

### publish.py

```
--account       账号名（必填）
--sau-dir       sau 安装路径（必填）
--type          笔记类型：note 或 video（必填）
--title         标题（必填）
--note          图文正文（图文时）
--desc          视频简介（视频时）
--tags          标签，逗号分隔
--images        图片路径，空格分隔，支持多张
--file          视频文件路径
--schedule      定时发布 YYYY-MM-DD HH:MM
--headed        有头模式（可见浏览器）
--headless      无头模式（默认）
--skip-warmup   跳过预热（仅测试用）
```

### warmup.py

```
--account       账号名（必填）
--sau-dir       sau 安装路径（必填）
--headless      无头模式（默认）
--headed        有头模式
```

两个脚本都通过 `--sau-dir` 自动推导 venv 路径：`$SAU_DIR/.venv/bin/activate`

---

## 3. 配置

### config.json

从 config.template.json 复制并填写实际值：

```json
{
  "account": "your-account-name",
  "sauDir": "<social-auto-upload 安装路径>",
  "limits": {
    "maxPerDay": 5,
    "minIntervalMinutes": 120,
    "randomOffsetMinutes": 30
  }
}
```

- `account` — sau 账号名（一个名称对应一组 cookie）
- `sauDir` — social-auto-upload 项目路径
- `limits` — 频率限制参数（可选，有默认值）

### AI 使用配置的方式

```
1. AI 读取 config.json → 获取 sau_dir 和 account
2. AI 用这些值构建 CLI 命令：
   python3 ./scripts/publish.py --account <account> --sau-dir <sau_dir> --type note ...
3. 脚本不读 config.json，只接受 CLI 参数
```

---

## 4. 测试

### 脚本参数验证

```bash
python3 ./scripts/publish.py --help
python3 ./scripts/warmup.py --help
```

### 快速验证（跳过预热）

```bash
python3 ./scripts/publish.py \
  --account test --sau-dir <sauDir> \
  --type note --title "测试" --skip-warmup --headed
```

### 配置可读性

```bash
python3 -c "import json; c=json.load(open('config.json')); print(c)"
```

### 频率检查模拟

```bash
python3 -c "
import json, datetime
with open('state.json') as f: s = json.load(f)
today = datetime.datetime.now().strftime('%Y-%m-%d')
count = len([p for p in s['posts'] if p['date'] == today])
print(f'今日已发: {count} 篇')
"
```

### Session 检查

```bash
source <sau_dir>/.venv/bin/activate
sau xiaohongshu check --account <account>
```

---

## 5. Skill 特有陷阱

| 陷阱 | 说明 |
|------|------|
| sau 路径推导 | venv 路径从 `--sau-dir` 自动推导，不要硬编码 |
| cookie 过期 | sau 的 cookie 有效期约 30 天，check 返回 invalid 需重新登录 |
| 预热失败 | warmup.py 失败不阻断发帖，但会打印警告 |
| 频率检查时区 | 禁止时段 00:00-06:00 指用户本地时间 |
| state.json 日期格式 | 必须是 YYYY-MM-DD，否则频率检查会漏计 |
| AI 读到旧缓存 | review 时把文件内容直接塞进 prompt，不要让 AI 自己读 |
