# OpenClaw 真实配置例子

> 从 GitHub 社区收集的不同复杂度的配置模板
> 最后更新：2026-03-21

---

## 例1：⭐ 极简配置（快速上手）

```json5
{
  agents: {
    defaults: {
      workspace: "~/.openclaw/workspace",
      model: {
        primary: "anthropic/claude-sonnet-4-6",
      },
    },
  },
  gateway: {
    port: 18789,
    bind: "loopback",
  },
}
```

适用：刚开始用，单 agent，本地运行。

---

## 例2：⭐⭐ 单 Agent + Telegram（个人日常）

```json5
{
  env: {
    ANTHROPIC_API_KEY: "sk-ant-...",
  },
  agents: {
    defaults: {
      workspace: "~/.openclaw/workspace",
      model: {
        primary: "anthropic/claude-sonnet-4-6",
        fallbacks: ["openai/gpt-4.1"],
      },
      contextPruning: {
        mode: "cache-ttl",
        ttl: "6h",
      },
      heartbeat: {
        every: "30m",
      },
    },
  },
  channels: {
    telegram: {
      enabled: true,
      botToken: "123:ABC...",
      dmPolicy: "allowlist",
      allowFrom: ["123456789"],
      streaming: "partial",
    },
  },
  gateway: {
    port: 18789,
    bind: "loopback",
    auth: {
      mode: "token",
      token: "YOUR_TOKEN",
    },
  },
}
```

---

## 例3：⭐⭐ 多 IM 集成（Telegram + Discord）

```json5
{
  env: {
    ANTHROPIC_API_KEY: "...",
  },
  agents: {
    defaults: {
      workspace: "~/.openclaw/workspace",
      model: {
        primary: "anthropic/claude-sonnet-4-6",
      },
    },
    list: [
      {
        id: "main",
        workspace: "~/.openclaw/workspace",
      },
      {
        id: "discord-bot",
        workspace: "~/.openclaw/workspace-discord",
      },
    ],
  },
  channels: {
    telegram: {
      enabled: true,
      accounts: {
        main: {
          botToken: "TELEGRAM_TOKEN",
          dmPolicy: "allowlist",
          allowFrom: ["123456789"],
        },
      },
    },
    discord: {
      enabled: true,
      accounts: {
        "discord-bot": {
          name: "My Bot",
          enabled: true,
          token: "DISCORD_TOKEN",
          groupPolicy: "allowlist",
          guilds: {
            "GUILD_ID": {
              channels: {
                "general": { allow: true, requireMention: false },
              },
            },
          },
        },
      },
    },
  },
  bindings: [
    { agentId: "main", match: { channel: "telegram", accountId: "main" } },
    { agentId: "discord-bot", match: { channel: "discord", accountId: "discord-bot" } },
  ],
  gateway: {
    port: 18789,
    bind: "loopback",
    auth: { mode: "token", token: "YOUR_TOKEN" },
  },
}
```

---

## 例4：⭐⭐⭐ 多 Agent 协调模式（生产级）

```json5
{
  env: {
    ANTHROPIC_API_KEY: "...",
    OPENAI_API_KEY: "...",
  },
  agents: {
    defaults: {
      model: {
        primary: "anthropic/claude-sonnet-4-6",
        fallbacks: ["openai/gpt-4.1", "google/gemini-2.5-pro"],
      },
      models: {
        "anthropic/claude-sonnet-4-6": { alias: "Sonnet" },
        "openai/gpt-4.1": { alias: "GPT" },
        "google/gemini-2.5-pro": { alias: "Gemini" },
      },
      contextPruning: { mode: "cache-ttl", ttl: "6h" },
      compaction: {
        mode: "safeguard",
        memoryFlush: { enabled: true, softThresholdTokens: 40000 },
      },
      heartbeat: { every: "30m" },
      maxConcurrent: 4,
      subagents: { maxConcurrent: 8 },
    },
    list: [
      {
        id: "main",
        workspace: "~/.openclaw/workspace",
        subagents: { allowAgents: ["researcher", "content"] },
      },
      {
        id: "researcher",
        workspace: "~/.openclaw/agents/researcher",
        tools: {
          deny: ["gateway", "cron", "sessions_spawn"],
          elevated: { enabled: false },
        },
      },
      {
        id: "content",
        workspace: "~/.openclaw/agents/content",
        tools: {
          deny: ["gateway", "cron", "sessions_spawn"],
          elevated: { enabled: false },
        },
      },
    ],
  },
  tools: {
    web: { search: { enabled: true } },
    exec: { security: "full", ask: "off" },
    elevated: {
      enabled: true,
      allowFrom: { telegram: ["123456789"] },
    },
  },
  channels: {
    telegram: {
      enabled: true,
      accounts: {
        main: {
          botToken: "TOKEN",
          dmPolicy: "allowlist",
          allowFrom: ["123456789"],
        },
      },
    },
  },
  bindings: [
    { agentId: "main", match: { channel: "telegram", accountId: "main" } },
  ],
  gateway: {
    port: 18789,
    bind: "loopback",
    auth: { mode: "token", token: "YOUR_TOKEN" },
  },
}
```

**关键设计：**
- main agent 可调用 researcher 和 content 子 agent
- 子 agent 禁止 gateway/cron/spawn 操作（权限最小化）
- 所有 agent 共享同一套模型和回退链

---

## 例5：⭐ 自定义本地模型（Ollama/NVIDIA NIM）

```json5
{
  models: {
    mode: "merge",    // merge = 追加到内置模型；replace = 替换
    providers: {
      ollama: {
        baseUrl: "http://localhost:11434/v1",
        api: "openai-completions",
        models: [
          {
            id: "qwen2.5:32b",
            name: "Qwen 2.5 32B",
            reasoning: false,
            input: ["text"],
            cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
            contextWindow: 131072,
            maxTokens: 8192,
          },
        ],
      },
    },
  },
}
```

---

## 配置模式对比

| 模式 | Agent 数 | 适合 | 月成本预估 |
|------|---------|------|-----------|
| 极简 | 1 | 刚入门 | $5-10 |
| 个人日常 | 1 | 日常使用 | $10-30 |
| 多 IM | 2 | 多平台 | $20-40 |
| 协调者+工作者 | 3-5 | 团队/生产 | $45-80 |
