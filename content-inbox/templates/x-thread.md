# X / Twitter Thread 适配模板

## 格式要求
- **每条：** ≤280 字符
- **理想长度：** 5-10 条（太短没深度，太长没人看完）
- **语言：** 英文

## 结构

```
1/ [Hook — 最重要的一句话，让人想看下去]

2/ [背景/问题 — 为什么这件事重要]

3-7/ [核心内容 — 每条一个独立的点]

8/ [总结 or 关键 takeaway]

9/ [CTA — 关注/转发/回复]
```

## 规则
- ✅ 第一条必须独立可读（很多人只看第一条）
- ✅ 每条末尾用 ↓ 或 🧵 暗示"还有下文"
- ✅ 用数字编号（1/、2/...）
- ✅ 穿插截图/代码（打破纯文字疲劳）
- ✅ 最后一条 standalone — 可以被单独转发
- ❌ 不要每条都 @自己
- ❌ 不要前 3 条都是铺垫（读者没耐心）

## 发布策略
- 写完整个 thread 再一次性发（不要边写边发）
- 第一条发出后立刻回复后续条目
- 间隔不超过 1 分钟

## 示例

```
1/ I built a personal AI operating system that runs 24/7 on my Mac Studio.

No cloud. No subscriptions. No data leaving my machine.

Here's the full architecture: 🧵

2/ The brain: OpenClaw — an open-source AI agent platform.

It connects to Claude, GPT, local models. 
Handles memory, skills, multi-agent coordination.

3/ The agents: I have 7 specialized agents.

- Main agent (coordinator)
- Researcher (deep dives)
- Tech Lead (architecture decisions)
- Content writer
- Verifier (QA)

They talk through Discord channels. ↓

4/ The skill system: each capability = one markdown file.

Want to add LinkedIn posting? Write a SKILL.md.
Want web search? Install a skill.

No code required for simple skills. ↓

5/ Memory: three layers.

- L0: injected every session (< 50 lines)
- L1: daily logs (auto-generated)
- L2: deep docs (read on demand)

Simple. No vector DB. Just files. ↓

6/ The result after 3 months:

- 100+ tasks delegated to agents
- 5-6 hours saved per week
- All data on my machine
- Total cost: electricity

7/ The biggest lesson?

AI agents are tools, not magic. 

They need clear specs, watchdogs, and someone who checks their work.

Treat them like junior devs, not like autonomous systems.

8/ If you want to try this yourself:

→ github.com/openclaw/openclaw
→ Start with one agent, one skill
→ Add complexity only when you need it

Follow me for more AI agent architecture posts.
```
