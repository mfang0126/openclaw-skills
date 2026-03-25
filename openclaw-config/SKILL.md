---
name: openclaw-config
description: |
  OpenClaw 配置文件（openclaw.json）的安全修改规则、字段参考和错误学习记录。
  在修改任何 OpenClaw 配置前必须先读此文件和 lessons.md。
triggers: ["config", "openclaw.json", "配置", "改配置", "config.patch", "添加agent", "添加channel", "修改模型", "gateway配置"]
metadata: {"clawdbot":{"emoji":"⚙️"}}
---

# OpenClaw 配置安全修改规则

## ⛔ 铁律（违反任何一条 = 配置损坏）

1. **永远不要**用 Write/Edit 工具直接修改 `~/.openclaw/openclaw.json`
2. **只能**通过 `gateway config.patch` 工具修改配置（内置校验，格式错直接拒绝）
3. **改之前**读 `lessons.md`，检查是否有相关的历史教训
4. **改之前**告诉用户打算改什么，等用户确认
5. **改之后**告诉用户改了哪些字段
6. **改失败**追加记录到 `lessons.md`

## 📋 操作流程

```
1. 读本文件（规则）
2. 读 lessons.md（历史教训）
3. 告诉用户打算改什么 → 等确认
4. 用 gateway config.patch 执行修改
5. 如果成功 → 告诉用户改了什么
6. 如果失败 → 记录到 lessons.md → 修复 → 再试
```

## 🔥 高频踩坑速查

| 陷阱 | 说明 |
|------|------|
| `tools` 是**对象**不是数组 | `{ "tools": { "profile": "coding" } }` |
| `tools.allow` 会**覆盖**全部工具 | 用 `tools.alsoAllow` 追加 |
| `agents.list` 是**数组** | `[{ "id": "xxx", ... }]` 不是 `{ "xxx": {...} }` |
| `allowFrom` 必须是**字符串数组** | `["6883367773"]` 不是 `"6883367773"` |
| `.strict()` 模式 | 任何未知字段直接拒绝启动 |
| `dmPolicy="open"` 需要 `allowFrom: ["*"]` | 否则全部 DM 被丢弃 |
| `gateway.auth.mode` | 有 token + password 时必须显式指定 |
| `heartbeat.every` | 必须是时长字符串如 `"30m"`、`"1h"` |

## 📐 常改字段速查

### agents.list 添加 agent
```json5
{
  "id": "new-agent",           // string，必填，kebab-case
  "workspace": "/path/to/ws",  // string，必填
  "model": {
    "primary": "anthropic/claude-sonnet-4-6"  // string
  },
  "tools": {
    "deny": ["gateway", "cron"],  // string[]，可选
    "elevated": { "enabled": false }  // object，可选
  },
  "subagents": {
    "allowAgents": ["researcher"]  // string[]，可选
  }
}
```

### bindings 添加绑定
```json5
{
  "agentId": "new-agent",       // 必须匹配 agents.list 中的 id
  "match": {
    "channel": "discord",       // telegram | discord | whatsapp | slack
    "accountId": "new-agent"    // 必须匹配 channels.<provider>.accounts 中的 key
  }
}
```

### channels.discord.accounts 添加 bot
```json5
{
  "name": "Display Name",
  "enabled": true,
  "token": "BOT_TOKEN",
  "groupPolicy": "allowlist",
  "streaming": "off",
  "guilds": {
    "GUILD_ID": {
      "channels": {
        "CHANNEL_ID": {
          "allow": true,
          "requireMention": false
        }
      }
    }
  }
}
```

### models.providers 添加自定义模型
```json5
{
  "providerName": {
    "baseUrl": "https://api.example.com/v1",
    "api": "openai-completions",
    "models": [{
      "id": "model-id",
      "name": "Display Name",
      "reasoning": true,
      "input": ["text"],
      "cost": { "input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0 },
      "contextWindow": 128000,
      "maxTokens": 8192
    }]
  }
}
```

## 📚 详细参考

需要更多信息时读 references 目录：
- `references/field-reference.md` — 完整字段手册
- `references/common-errors.md` — 社区 TOP 10 错误 + 修复
- `references/examples.md` — 5 个真实配置例子
- `references/schema-rules.md` — 校验机制详解
