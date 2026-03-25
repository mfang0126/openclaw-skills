# OpenClaw 配置字段参考手册

> 完整字段手册，列出每个常改字段的路径、类型、合法值、默认值。
> 官方文档：https://docs.openclaw.ai/gateway/configuration-reference

---

## 1. agents — Agent 配置

### agents.defaults（全局默认值）

| 字段路径 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `agents.defaults.workspace` | string | `~/.openclaw/workspace` | 默认 workspace 路径 |
| `agents.defaults.model.primary` | string | — | 默认主模型（格式：`provider/model`） |
| `agents.defaults.model.fallbacks` | string[] | `[]` | 回退模型列表 |
| `agents.defaults.models` | object | — | 模型目录（key=模型ID，value={alias}） |
| `agents.defaults.heartbeat.every` | string | — | 心跳间隔（如 `"30m"`、`"1h"`） |
| `agents.defaults.contextPruning.mode` | string | — | `"cache-ttl"` 或其他 |
| `agents.defaults.contextPruning.ttl` | string | — | 上下文缓存 TTL（如 `"2h"`、`"6h"`） |
| `agents.defaults.compaction.mode` | string | — | `"safeguard"` / `"default"` |
| `agents.defaults.compaction.memoryFlush.enabled` | bool | false | 启用记忆刷写 |
| `agents.defaults.compaction.memoryFlush.softThresholdTokens` | number | — | 触发刷写的 token 阈值 |
| `agents.defaults.maxConcurrent` | number | — | 最大并发数 |
| `agents.defaults.subagents.maxConcurrent` | number | — | 子 agent 最大并发数 |
| `agents.defaults.blockStreamingDefault` | string | — | `"on"` / `"off"` |
| `agents.defaults.blockStreamingBreak` | string | — | `"text_end"` 等 |

### agents.defaults.memorySearch（记忆搜索）

| 字段路径 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `agents.defaults.memorySearch.enabled` | bool | false | 启用语义搜索 |
| `agents.defaults.memorySearch.provider` | string | — | `"local"` / `"openai"` / `"remote"` |
| `agents.defaults.memorySearch.model` | string | — | embedding 模型名 |
| `agents.defaults.memorySearch.local.modelPath` | string | — | 本地模型路径 |
| `agents.defaults.memorySearch.remote.baseUrl` | string | — | 远程 embedding 服务地址 |
| `agents.defaults.memorySearch.extraPaths` | string[] | `[]` | 额外搜索路径 |
| `agents.defaults.memorySearch.sync.onSessionStart` | bool | false | session 启动时同步 |
| `agents.defaults.memorySearch.sync.onSearch` | bool | false | 搜索时同步 |

### agents.list（Agent 列表）

⚠️ **必须是数组**，不是对象。

每个元素结构：

| 字段 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `id` | string | ✅ | Agent ID（唯一，kebab-case） |
| `workspace` | string | — | 覆盖默认 workspace |
| `model.primary` | string | — | 覆盖默认主模型 |
| `model.fallbacks` | string[] | — | 覆盖回退链 |
| `tools.deny` | string[] | — | 禁用工具列表 |
| `tools.elevated.enabled` | bool | — | 是否允许提权操作 |
| `tools.elevated.allowFrom.telegram` | string[] | — | 允许提权的 Telegram 用户 |
| `subagents.allowAgents` | string[] | — | 允许调用的子 agent 列表 |

---

## 2. channels.telegram

| 字段路径 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `channels.telegram.enabled` | bool | true | 是否启用 |
| `channels.telegram.botToken` | string | `TELEGRAM_BOT_TOKEN` | Bot Token |
| `channels.telegram.tokenFile` | string | — | Token 文件路径（不允许软链） |
| `channels.telegram.dmPolicy` | enum | `"pairing"` | `pairing` / `allowlist` / `open` / `disabled` |
| `channels.telegram.allowFrom` | string[] | — | 白名单用户 ID |
| `channels.telegram.groupPolicy` | enum | `"allowlist"` | `allowlist` / `open` / `disabled` |
| `channels.telegram.streaming` | enum | `"off"` | `off` / `partial` / `block` / `progress` |
| `channels.telegram.mediaMaxMb` | number | 100 | 媒体文件上限 MB |
| `channels.telegram.historyLimit` | number | — | 群聊历史条数 |
| `channels.telegram.replyToMode` | enum | `"off"` | `off` / `first` / `all` |
| `channels.telegram.timeoutSeconds` | number | 60 | 超时秒数 |
| `channels.telegram.proxy` | string | — | 代理 URL |

### 多账号（channels.telegram.accounts）

```json5
{
  channels: {
    telegram: {
      accounts: {
        "main": {
          botToken: "TOKEN",
          dmPolicy: "allowlist",
          allowFrom: ["123456"],
          groupPolicy: "allowlist",
          streaming: "partial"
        },
        "default": {
          dmPolicy: "pairing",
          groupPolicy: "disabled",
          streaming: "partial"
        }
      }
    }
  }
}
```

每个 account 可覆盖顶层 telegram 配置的字段。

---

## 3. channels.discord

| 字段路径 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `channels.discord.enabled` | bool | true | 是否启用 |
| `channels.discord.token` | string | `DISCORD_BOT_TOKEN` | Bot Token |
| `channels.discord.dmPolicy` | enum | `"pairing"` | DM 策略 |
| `channels.discord.allowFrom` | string[] | — | 白名单用户 ID |
| `channels.discord.allowBots` | bool / `"mentions"` | false | 是否处理 bot 消息 |
| `channels.discord.groupPolicy` | enum | `"allowlist"` | 群组策略 |
| `channels.discord.streaming` | enum | `"off"` | 流式输出 |
| `channels.discord.maxLinesPerMessage` | number | 17 | 每条消息最大行数 |
| `channels.discord.textChunkLimit` | number | 2000 | 单条消息字符上限 |
| `channels.discord.chunkMode` | enum | `"length"` | `length` / `newline` |
| `channels.discord.mediaMaxMb` | number | 8 | 媒体上限 MB |
| `channels.discord.historyLimit` | number | 20 | 历史条数 |
| `channels.discord.replyToMode` | enum | `"off"` | `off` / `first` / `all` |
| `channels.discord.blockStreaming` | bool | — | 是否启用块流 |

### guilds 配置

```json5
{
  guilds: {
    "GUILD_ID": {
      slug: "readable-name",         // string
      requireMention: false,          // bool
      ignoreOtherMentions: true,      // bool
      reactionNotifications: "own",   // off | own | all | allowlist
      users: ["USER_ID"],            // string[]
      channels: {
        "CHANNEL_ID_OR_NAME": {
          allow: true,                // bool，必填
          requireMention: true,       // bool
          users: ["USER_ID"],        // string[]
          skills: ["skill-name"],    // string[]
          systemPrompt: "..."        // string
        }
      }
    }
  }
}
```

### 多账号（channels.discord.accounts）

每个 account 结构同顶层 discord 配置，额外字段：

| 字段 | 类型 | 说明 |
|---|---|---|
| `name` | string | 显示名 |
| `enabled` | bool | 是否启用 |
| `token` | string | Bot Token |
| `allowFrom` | string[] | 白名单用户 |
| `guilds` | object | 同上 |

---

## 4. models — 自定义模型 Provider

| 字段路径 | 类型 | 说明 |
|---|---|---|
| `models.mode` | enum | `"merge"` / `"replace"` |
| `models.providers.<name>.baseUrl` | string | API 地址 |
| `models.providers.<name>.apiKey` | string | API Key（或用 env） |
| `models.providers.<name>.auth` | string | `"api-key"` / `"bearer"` |
| `models.providers.<name>.api` | string | `"openai-completions"` |
| `models.providers.<name>.models` | array | 模型列表 |

### 每个模型定义

| 字段 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `id` | string | ✅ | 模型 ID |
| `name` | string | ✅ | 显示名 |
| `api` | string | — | 覆盖 provider 级别的 api |
| `reasoning` | bool | — | 是否支持推理 |
| `input` | string[] | — | `["text"]` / `["text", "image"]` |
| `cost.input` | number | — | 输入 cost per M tokens |
| `cost.output` | number | — | 输出 cost per M tokens |
| `cost.cacheRead` | number | — | 缓存读取 cost |
| `cost.cacheWrite` | number | — | 缓存写入 cost |
| `contextWindow` | number | — | 上下文窗口大小 |
| `maxTokens` | number | — | 最大输出 token |
| `compat.supportsDeveloperRole` | bool | — | 是否支持 developer role |

---

## 5. bindings — 路由绑定

⚠️ **必须是数组**。

```json5
[
  {
    agentId: "main",          // 必须匹配 agents.list 中的 id
    match: {
      channel: "telegram",    // telegram | discord | whatsapp | slack 等
      accountId: "main"       // 必须匹配 channels.<provider>.accounts 中的 key
    }
  }
]
```

---

## 6. gateway — 网关配置

| 字段路径 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `gateway.port` | number | 18789 | 端口 |
| `gateway.mode` | enum | `"local"` | `local` / `remote` |
| `gateway.bind` | enum | `"loopback"` | `loopback` / `lan` / `"0.0.0.0"` |
| `gateway.auth.mode` | enum | — | `"token"` / `"password"` |
| `gateway.auth.token` | string | — | 认证 token |
| `gateway.tailscale.mode` | enum | `"off"` | `off` / `on` |
| `gateway.controlUi.allowedOrigins` | string[] | — | 允许的来源 URL |

⚠️ `bind` 为 `"lan"` 或 `"0.0.0.0"` 时 gateway 暴露给网络，确保有 auth token。

---

## 7. session — 会话配置

| 字段路径 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `session.scope` | enum | `"per-sender"` | `per-sender` / `per-channel` |
| `session.dmScope` | enum | — | `per-channel-peer` 等 |

---

## 8. tools — 工具策略

| 字段路径 | 类型 | 说明 |
|---|---|---|
| `tools.web.search.enabled` | bool | 启用 web 搜索 |
| `tools.web.search.apiKey` | string | Brave Search API Key |
| `tools.web.fetch.enabled` | bool | 启用 web fetch |
| `tools.exec.security` | enum | `"full"` / `"allowlist"` / `"deny"` |
| `tools.exec.ask` | enum | `"off"` / `"on-miss"` / `"always"` |
| `tools.elevated.enabled` | bool | 启用提权操作 |
| `tools.elevated.allowFrom.telegram` | string[] | 允许提权的用户 |
| `tools.agentToAgent.enabled` | bool | 启用 agent 间通信 |

---

## 9. env — 环境变量

```json5
{
  env: {
    OPENAI_API_KEY: "sk-...",
    ANTHROPIC_API_KEY: "sk-ant-...",
    // key 必须是 /^[A-Z][A-Z0-9_]{0,127}$/ 格式
  }
}
```

---

## 10. auth — 认证 Profile

```json5
{
  auth: {
    profiles: {
      "anthropic:default": { provider: "anthropic", mode: "token" },
      "openai:default": { provider: "openai", mode: "api_key" },
      // mode: "token" | "api_key" | "oauth"
    }
  }
}
```

---

## 11. plugins — 插件配置

| 字段路径 | 类型 | 说明 |
|---|---|---|
| `plugins.allow` | string[] | 允许加载的插件白名单 |
| `plugins.entries.<name>.enabled` | bool | 是否启用 |
| `plugins.slots.memory` | string | 内存插件 slot |

---

## 12. memory — 记忆后端

| 字段路径 | 类型 | 说明 |
|---|---|---|
| `memory.backend` | enum | `"qmd"` / `"lancedb"` |
| `memory.qmd.paths` | array | `[{ path: "docs", pattern: "**/*.md" }]` |

---

## 13. hooks — 内部钩子

| 字段路径 | 类型 | 说明 |
|---|---|---|
| `hooks.internal.enabled` | bool | 启用内部钩子 |
| `hooks.internal.entries.boot-md.enabled` | bool | 启动 MD 加载 |
| `hooks.internal.entries.session-memory.enabled` | bool | 会话记忆 |
| `hooks.internal.entries.command-logger.enabled` | bool | 命令日志 |
