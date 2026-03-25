# plan-mode

> 只想不做的安全计划模式。分析意图、盘点资源、制定方案，绝对不执行任何操作。

**Pattern: Pipeline** (Google ADK)

## How It Works

Plan Mode is an **interceptor pattern** — it sits between the user's intent and any action. When triggered, the agent enters a zero-execution mode and produces a structured plan with 5 fixed sections:

```
触发词检测
    │
    ├── 自动触发? → 直接进入 plan mode
    │
    └── 模糊大任务? → 询问是否需要 plan
              │
              ↓
    进入 Plan Mode
    (零工具调用状态)
              │
    输出结构化计划:
    🎯 意图 → 📦 资源 → 🧠 方案 → ❓ 确认项 → 🚫 排除项
              │
    等待用户确认
              │
    ┌─────────┼─────────┐
    ↓         ↓         ↓
  动手/go   修改意见   算了/取消
    │         │         │
  执行      更新计划   不执行
```

## Design Decisions

**Why zero tool calls in plan mode?**
Safety and reversibility. Once a tool call executes (file write, shell command), it may be hard to undo. Plan mode ensures the user sees exactly what will happen before anything runs.

**Why the 5-section output format?**
Reduces ambiguity. The structured format forces the agent to make its assumptions explicit (🎯 intent), surface what's missing (📦 resources), and define scope (🚫 exclusions). Users can correct wrong assumptions before work begins.

**Why "动手" as the exit keyword?**
It's an affirmative, unambiguous signal — hard to trigger accidentally. The agent never exits plan mode from a vague "ok" or "yes".

## The 3 Exit Paths

| Exit | Trigger | Outcome |
|------|---------|---------|
| Execute | `动手`, `go`, `执行`, `run it` | Exits plan mode, begins execution |
| Cancel | `算了`, `取消`, `never mind` | Exits plan mode, no action taken |
| Shelve | `先这样`, `存起来`, `待定` | Saves plan to `~/plan-drafts/`, exits |

## Limitations

- Relies on trigger phrase detection — may miss implicit planning needs
- Cannot enforce plan mode if user doesn't use trigger phrases
- Shelve path (`~/plan-drafts/`) requires writable home directory

## Related Skills

This is a **meta-skill** — it wraps all other skills by intercepting intent before execution. No direct skill dependencies.
