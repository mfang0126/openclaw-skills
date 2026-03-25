# OpenClaw Schema 校验机制详解

> 来源：OpenClaw 源码分析 + GitHub Issues + 官方文档
> 最后更新：2026-03-21

---

## 1. 校验引擎

OpenClaw 使用 **Zod**（TypeScript schema 库）进行配置校验。

### 校验流程

```
openclaw.json 文件读取
    │
    ├─ Step 1: JSON5 语法解析
    │         └─ 失败 → "JSON5 parse failed"
    │
    ├─ Step 2: $include 指令解析
    │         └─ 路径必须在 config 目录内（安全沙箱）
    │
    ├─ Step 3: env 变量展开
    │         └─ 缺失变量 → warnings（非阻塞）
    │
    ├─ Step 4: legacy 字段检测
    │         └─ 旧字段 → legacyIssues（可迁移）
    │
    ├─ Step 5: Zod Schema 校验（OpenClawSchema.safeParse）
    │         └─ 失败 → valid=false + issues 列表
    │
    ├─ Step 6: 业务规则校验（post-Zod）
    │         ├─ agents.list 是否有重复 agentDir
    │         ├─ identity avatar URL 格式
    │         ├─ gateway Tailscale bind 冲突
    │         └─ Plugin config 合法性
    │
    └─ Step 7: 应用默认值 + 路径归一化
              └─ 输出最终配置
```

---

## 2. `.strict()` 模式（最常见的出错原因）

**绝大多数子对象都使用 `.strict()`**，意味着任何未知字段都导致校验失败。

```
❌ Unrecognized key(s) in object: 'unknownField'
```

这意味着：
- 拼错字段名 → 失败
- 用了旧版字段名 → 失败
- 加了自定义字段 → 失败
- 复制了别人的配置但版本不同 → 可能失败

唯一的例外：根对象允许 `$schema` 字段。

---

## 3. 最严格的字段详解

### secrets.providers.*.command
```
- 必须是绝对路径（如 /usr/bin/op）
- 必须通过安全可执行文件检查（防 shell 注入）
```

### browser.profiles 名称
```
- 只允许 /^[a-z0-9-]+$/（小写字母、数字、连字符）
- 每个 profile 必须设置 cdpPort 或 cdpUrl
```

### channels.*.dmPolicy + allowFrom 联动
```
- dmPolicy="open" + 没有 allowFrom:["*"] → 全部 DM 被丢弃
- dmPolicy="allowlist" + 空 allowFrom → 全部 DM 被丢弃
```

### auth.profiles.*.mode
```
- 必须精确匹配：api_key | oauth | token
- 无默认值
```

### heartbeat.every
```
- 必须是合法时长字符串：5m、1h、30s 等
- 无效格式触发 superRefine 报错
```

### env secret ref ID
```
- 必须匹配 /^[A-Z][A-Z0-9_]{0,127}$/
- 全大写 + 数字 + 下划线
```

### $include 路径
```
- 不能用 ../ 逃逸到 config 目录外
- 违反 → 直接 valid=false
```

### sandbox.docker.network
```
- "host" 被明确拒绝
- "container:*" 需要 dangerouslyAllowContainerNamespaceJoin=true
- seccompProfile="unconfined" 被拒绝
```

---

## 4. `openclaw doctor` 能力

### 自动修复的问题

| 修复项 | 说明 |
|--------|------|
| Legacy 字段迁移 | 旧字段自动重命名（如 streamMode → streaming） |
| dm 字段迁移 | dm.policy → dmPolicy |
| 单账号键提升 | 顶层键移入 accounts.default.* |
| Telegram allowFrom | @username 解析为数字 ID |
| Discord 数字 ID | allowlist 数字转字符串 |
| open policy allowFrom | 自动添加 "*" |
| 未知键清理 | 移除 schema 不认识的键 |
| Plugin auto-enable | 根据 env 变量自动启用 |
| safeBinProfiles 脚手架 | 缺少 profile 的命令添加空占位 |

### 只警告不修复的问题

| 问题 | 说明 |
|------|------|
| allowlist + 空 allowFrom | DM 静默丢弃 |
| safeBins 含解释器 | 不自动生成 profile |
| $include 路径越界 | 需手动修复 |

---

## 5. 预校验方法

### 方法 1：CLI 命令（推荐）
```bash
openclaw config validate --json
# 返回 {"valid":true} 或 {"valid":false, "issues":[...]}
```

### 方法 2：config set 内置校验
`openclaw config set` 在写入前自动校验，格式错误直接拒绝不写入。

### 方法 3：gateway config.patch
通过 Gateway API 写入时，同样先校验再写入，失败则返回错误不修改文件。

### 方法 4：手动流程
```bash
cp openclaw.json openclaw.json.bak        # 备份
# ... 修改 ...
openclaw config validate --json            # 校验
openclaw doctor --fix                      # 修复
```

---

## 6. 常见错误信息速查

| 错误信息 | 原因 | 解决 |
|---------|------|------|
| `Unrecognized key(s) in object: 'xxx'` | 拼错字段或版本不匹配 | `doctor --fix` |
| `JSON5 parse failed` | JSON 语法错误 | 检查引号、逗号 |
| `Include path resolves outside config directory` | $include 路径越界 | 移文件到 ~/.openclaw/ |
| `secrets.providers.*.command is unsafe` | 命令不是绝对路径 | 用绝对路径 |
| `invalid duration` | heartbeat.every 格式错 | 用 "5m"、"1h" |
| `Profile names must be alphanumeric with hyphens` | 大写或特殊字符 | 改 [a-z0-9-] |
| `expected object, received array` | 类型错误 | 检查字段应该是对象还是数组 |
| `expected array, received object` | 类型错误 | 同上 |
