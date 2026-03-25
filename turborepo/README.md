# turborepo

> Turborepo monorepo build system configuration and best practices.

## How It Works

**Pattern: Tool Wrapper** (Google ADK)

This skill loads Turborepo knowledge on demand via decision trees and reference files. The SKILL.md contains the critical rules and quick summaries; deeper reference files handle the details.

## Skill Organization

```
turborepo/
├── SKILL.md                               # Core rules, decision summaries, reference index
├── references/
│   ├── decision-trees.md                  # Full decision trees for config questions
│   ├── anti-patterns.md                   # 8 critical mistakes with wrong/correct code
│   ├── common-task-configurations.md      # Ready-to-use turbo.json task patterns
│   └── [other existing reference files]   # Via references/ directory
├── command/
│   └── turborepo.md                       # CLI flags reference (treat as references/cli)
└── scripts/
    └── validate_turbo_config.sh           # Validate turbo.json structure
```

## About `command/turborepo.md`

Non-standard directory name — this file documents Turborepo CLI flags and commands. It's equivalent to `references/cli-commands.md`. Read it when the question is about CLI flags (`--filter`, `--affected`, `--dry-run`, etc.).

## Design Decisions

- **Decision trees over prose**: Faster navigation for config questions — most Turborepo questions are "should X depend on Y?" or "why is my cache missing?"
- **Anti-patterns reference**: Grouped all "don't do this" patterns in one file to avoid scattering warnings
- **Version pinned**: Content tracks Turborepo 2.8.12-canary.2 — verify against changelog for newer releases

## Source

- Official Turborepo docs: https://turbo.build/docs
- Version: 2.8.12-canary.2

## Limitations

- Version-specific — some patterns may differ in older or newer Turborepo versions
- Remote cache setup (Vercel/self-hosted) not covered in depth — see official docs
