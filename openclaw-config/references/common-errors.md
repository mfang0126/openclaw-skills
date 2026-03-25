# OpenClaw 配置常见错误 TOP 10

> 来源：Reddit r/openclaw 社区 + GitHub Issues + 官方文档
> 最后更新：2026-03-21

---

## ❌ #1：`tools` 字段类型错误 — 传数组而非对象

**报错：**
```
config validation failed: tools — invalid input, expected object, received array
```

**错误写法：**
```json
{ "tools": ["run_code", "file_read", "file_write"] }
```

**正确写法：**
```json
{ "tools": { "profile": "coding", "allow": ["exec", "read", "write"] } }
```

**来源：** u/Tameron700 (r/openclaw)

---

## ❌ #2：`tools.allow` 覆盖默认工具集

设置 `tools.allow = ["exec"]` 会**完全替换**默认工具集，所有未列出的工具被禁用。

**正确做法：** 用 `tools.alsoAllow` 追加：
```json
{ "tools": { "alsoAllow": ["memory_search", "sessions_spawn"] } }
```

**规则：** `allow` = 替换；`alsoAllow` = 追加

---

## ❌ #3：`gateway.auth.mode` 缺失（v2026.3.7+）

同时存在 `auth.token` 和 `auth.password` 但无 `auth.mode`，网关拒绝启动。

**修复：**
```json
{ "gateway": { "auth": { "mode": "token", "token": "YOUR_TOKEN" } } }
```

---

## ❌ #4：Docker 部署 token 不同步

Onboard 向导在 `openclaw.json` 写入自己生成的 token，与 `.env` 里的不一致。

**修复：** 手动对比并统一两处 token 值。

---

## ❌ #5：`gateway.bind` 暴露公网

`bind` 未设置或为 `"0.0.0.0"`，gateway 暴露给整个网络。

**检查：**
```bash
netstat -an | grep 18789 | grep LISTEN
# 应该是 127.0.0.1:18789 不是 0.0.0.0:18789
```

**修复（VPS）：** `"bind": "loopback"` + SSH 隧道
**修复（Docker）：** `network_mode: host` + 删除 `ports:`

---

## ❌ #6：升级后工具消失（v2026.3.2+）

v2026.3.2 新安装默认 `tools.profile` 改为 `messaging`（无 Shell/文件权限）。

**症状：** Agent 报 "I cannot execute commands"

**修复：**
```json
{ "tools": { "profile": "coding" } }
```

---

## ❌ #7：Cron 通知静默失效（v2026.3.11）

Breaking change：Cron 不再支持 ad hoc agent sends 发通知。

**修复：** `openclaw doctor --fix`

---

## ❌ #8：allowlist 含未安装插件的工具

`apply_patch`、`memory_search` 等工具在 allowlist 中，但对应 plugin 未启用。

**症状：** 工具间歇性不可用

**修复：** `openclaw config validate --json` 检查 + 安装对应 plugin 或移除条目

---

## ❌ #9：Agent 直接编辑 openclaw.json 损坏配置

**最高频反馈。** 模型写错 JSON 格式、字段类型、或与 gateway 产生竞态覆盖。

> "每隔三次让它改配置，它就会以各种方式搞坏自己。" — Reddit 用户

**解决：** 永远用 `config.patch`，永远不直接写文件

---

## ❌ #10：env 变量名不一致导致 silent failure

工具期待 `AUTH_TOKEN`，实际配置了 `TWITTER_AUTH_TOKEN`。无错误日志。

**修复：** `openclaw secrets audit --check`

---

## 版本兼容变更

| 版本 | 变更 | 受影响字段 | 迁移操作 |
|------|------|---------|---------|
| v2026.3.2 | tools.profile 默认改为 messaging | `tools.profile` | 手动改为 `coding` |
| v2026.3.7 | 双 auth 字段需显式 mode | `gateway.auth.mode` | 添加 `"mode": "token"` |
| v2026.3.11 | Cron 通知机制变更 | cron 配置 | `openclaw doctor --fix` |

---

## 快速诊断流程

```
发现问题
  │
  ├─ openclaw config validate --json  → 看 issues
  ├─ openclaw doctor                  → 看 warnings
  ├─ openclaw doctor --fix            → 自动修复
  └─ 手动修复 → 再次 validate 确认
```
