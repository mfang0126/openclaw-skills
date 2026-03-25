# Detection Triggers

## Correction Triggers → run `reflection log` immediately

| Trigger Phrase | Confidence | Action |
|----------------|------------|--------|
| "No, do X instead" | High | Log correction: tag=correction |
| "Actually, it should be..." | High | Log correction: tag=correction |
| "You're wrong about..." | High | Log correction: tag=correction |
| "I told you before..." | High | Flag as repeated, bump weight |
| "Stop doing X" | High | Log correction: tag=correction |
| "Why do you keep..." | High | Flag as repeated, bump weight |
| "I prefer X, not Y" | Confirmed | Log preference: tag=preference |
| "Always do X for me" | Confirmed | Log preference: tag=preference |
| "Never do Y" | Confirmed | Log preference: tag=preference |

## Preference Signals → log to Layer 3, promote after 3x

| Signal | Action |
|--------|--------|
| "I like when you..." | Log as preference, weight=1 |
| "My style is..." | Log as preference, weight=1 |
| "For [project], use..." | Log as scoped preference |
| Same instruction repeated 3x | Ask to confirm → promote to Layer 2 |
| User praises specific approach | Log as positive pattern, weight=2 |

## Self-Reflection Triggers → agent-initiated

| Condition | Action |
|-----------|--------|
| Multi-step task completed | Evaluate: did output match intent? |
| Bug fixed | Log: what caused it, how to prevent |
| Output could be better | Log: what specifically, what to change |
| Feedback received (pos or neg) | Log with appropriate tag |

## Do NOT Log

- One-time instructions ("do X now") — ephemeral
- Context-specific ("in this file...") — not generalizable
- Hypotheticals ("what if...") — not confirmed
- Silence — not confirmation
- Third-party preferences ("John likes...") — no consent
- Single instance of anything — wait for repetition

## Classification by Type

| Type | Example | Tag |
|------|---------|-----|
| Format | "Use bullets not prose" | format |
| Technical | "SQLite not Postgres" | technical |
| Communication | "Shorter messages" | communication |
| Workflow | "Always run tests first" | workflow |
| Project-specific | "This repo uses Tailwind" | project |

## Classification by Scope

- **Global** — applies everywhere → Layer 1 candidate
- **Domain** — applies to category (code, writing) → Layer 2
- **Project** — applies to specific context → Layer 2 with tag
- **Session** — applies to this session only → Layer 3 only
