---
user-invocable: false
name: turborepo
description: |
  Turborepo monorepo build system guidance. Triggers on: turbo.json, task pipelines,
  dependsOn, caching, remote cache, the "turbo" CLI, --filter, --affected, CI optimization, environment
  variables, internal packages, monorepo structure/best practices, and boundaries.

  Use when user: configures tasks/workflows/pipelines, creates packages, sets up
  monorepo, shares code between apps, runs changed/affected packages, debugs cache,
  or has apps/packages directories.

  USE FOR:
  - "set up a monorepo", "配置 Turborepo", "share code between apps"
  - "turbo.json pipeline config", "dependsOn tasks", "remote cache setup"
  - "only build changed packages", "--affected flag", "CI optimization"
  - "debug cache miss", "internal packages", "workspace structure"
  - User has `apps/` and `packages/` directories and needs build orchestration
metadata:
  version: 2.8.12-canary.2
---

# Turborepo Skill

**Pattern: Tool Wrapper**

## When to Use

Use when setting up or maintaining a **JavaScript/TypeScript monorepo** that needs parallel task execution, incremental build caching, and shared packages across multiple apps. Turborepo speeds up builds by caching outputs and only rebuilding what changed.

**Don't use when:** You have a single-app project with no shared packages (plain npm scripts suffice), or you're using a different monorepo tool like Nx that already covers your needs.

## Prerequisites

1. Node.js ≥ 18 and a supported package manager (npm, yarn, pnpm, bun)
2. `npx create-turbo@latest` for new repos, or `npm install turbo --save-dev` for existing
3. `turbo.json` in the repo root (auto-created by CLI)
4. `workspaces` configured in root `package.json` (or `pnpm-workspace.yaml` for pnpm)
5. Optional: Vercel account for Remote Cache (`turbo login && turbo link`)

## Error Handling

| Error | Cause | Solution |
|-------|-------|----------|
| `task not found in turbo.json` | Script exists in package but not registered in turbo.json | Add task entry to `turbo.json` `tasks` object |
| Cache never hits | `outputs` paths don't match actual build output | Check `dist/**` vs `.next/**` etc. match real output dirs |
| `command not found: turbo` | Turbo not installed or not on PATH | `npm install turbo --save-dev`; use `npx turbo` |
| Build runs sequentially | Missing `dependsOn: ["^build"]` for upstream deps | Add `"dependsOn": ["^build"]` to tasks that need dep outputs |
| Env var changes not invalidating cache | Env vars not listed in `env` or `globalEnv` | Add affected env var names to task `env` array in turbo.json |
| Remote cache not hitting in CI | Token or team config missing | Set `TURBO_TOKEN` + `TURBO_TEAM` env vars in CI secrets |

## Examples

### Example 1: Basic turbo.json for a Next.js monorepo

**Input:** User asks "Set up Turborepo for my monorepo with Next.js web app and shared UI package"

**turbo.json:**
```json
{
  "$schema": "https://turbo.build/schema.json",
  "tasks": {
    "build": { "dependsOn": ["^build"], "outputs": [".next/**", "dist/**"] },
    "dev":   { "cache": false, "persistent": true },
    "lint":  {},
    "test":  { "dependsOn": ["build"], "inputs": ["src/**", "tests/**"] }
  }
}
```

**apps/web/package.json scripts:**
```json
{ "build": "next build", "dev": "next dev", "lint": "eslint .", "test": "vitest" }
```

**Root package.json scripts:**
```json
{ "build": "turbo run build", "dev": "turbo run dev", "lint": "turbo run lint" }
```

**Output:** Builds `packages/ui` before `apps/web`; caches `.next/**`; `dev` runs persistent with no cache.

Build system for JavaScript/TypeScript monorepos. Turborepo caches task outputs and runs tasks in parallel based on dependency graph.

## IMPORTANT: Package Tasks, Not Root Tasks

**DO NOT create Root Tasks. ALWAYS create package tasks.**

When creating tasks/scripts/pipelines, you MUST:

1. Add the script to each relevant package's `package.json`
2. Register the task in root `turbo.json`
3. Root `package.json` only delegates via `turbo run <task>`

**DO NOT** put task logic in root `package.json`. This defeats Turborepo's parallelization.

```json
// DO THIS: Scripts in each package
// apps/web/package.json
{ "scripts": { "build": "next build", "lint": "eslint .", "test": "vitest" } }

// apps/api/package.json
{ "scripts": { "build": "tsc", "lint": "eslint .", "test": "vitest" } }

// packages/ui/package.json
{ "scripts": { "build": "tsc", "lint": "eslint .", "test": "vitest" } }
```

```json
// turbo.json - register tasks
{
  "tasks": {
    "build": { "dependsOn": ["^build"], "outputs": ["dist/**"] },
    "lint": {},
    "test": { "dependsOn": ["build"] }
  }
}
```

```json
// Root package.json - ONLY delegates, no task logic
{
  "scripts": {
    "build": "turbo run build",
    "lint": "turbo run lint",
    "test": "turbo run test"
  }
}
```

```json
// DO NOT DO THIS - defeats parallelization
// Root package.json
{
  "scripts": {
    "build": "cd apps/web && next build && cd ../api && tsc",
    "lint": "eslint apps/ packages/",
    "test": "vitest"
  }
}
```

Root Tasks (`//#taskname`) are ONLY for tasks that truly cannot exist in packages (rare).

## Secondary Rule: `turbo run` vs `turbo`

**Always use `turbo run` when the command is written into code:**

```json
// package.json - ALWAYS "turbo run"
{
  "scripts": {
    "build": "turbo run build"
  }
}
```

```yaml
# CI workflows - ALWAYS "turbo run"
- run: turbo run build --affected
```

**The shorthand `turbo <tasks>` is ONLY for one-off terminal commands** typed directly by humans or agents. Never write `turbo build` into package.json, CI, or scripts.

## Quick Decision Trees

> **See `references/decision-trees.md`** for the full decision trees.

**Most common decisions:**

- **Should task X depend on Y?** → Does X need Y's output? Yes → `dependsOn: ["^Y"]`. No → omit.
- **Cache missing?** → Check `outputs` covers all generated files; check `env` covers env vars affecting output
- **Only build changed packages?** → Use `--affected` flag with `turbo run build --affected`
- **Debug cache?** → `turbo run build --verbosity=2` shows cache reasons


## Critical Anti-Patterns

> **See `references/anti-patterns.md`** for detailed examples with wrong/correct code.

**Top mistakes:**

1. **Using `turbo` shorthand in code** → Always use `turbo run <task>` in package.json and CI
2. **Root scripts bypassing Turbo** → Root package.json must delegate via `turbo run`, not run tasks directly
3. **Incorrect cache outputs** → Missing cache output paths means cache never hits
4. **All tasks in root turbo.json** → Package tasks need scripts in their own package.json
5. **Wrong `dependsOn` direction** → `"^build"` = wait for dependencies; `"build"` = wait for same package
6. **Using `--no-cache` in production** → Defeats the purpose of remote cache
7. **Environment variables not in `env`** → Variables affecting output must be in `globalEnv` or task `env`
8. **Too many root dependencies** → Only repo tools (turbo, changesets) go in root; app deps in packages


## Common Task Configurations

> **See `references/common-task-configurations.md`** for ready-to-use patterns.

Quick reference:
- **build** → `dependsOn: ["^build"]`, `outputs: ["dist/**", ".next/**"]`
- **test** → `dependsOn: ["build"]`, `inputs: ["src/**", "tests/**"]`  
- **lint** → no dependsOn (independent per package)
- **dev** → `cache: false`, `persistent: true`
- **type-check** → `dependsOn: ["^build"]`, `inputs: ["**/*.ts", "**/*.tsx"]`

For more patterns (monorepo with shared UI, with/without remote cache, CI matrix builds), read `references/common-task-configurations.md`.


## Reference Index

> **Note on `command/` directory**: `command/turborepo.md` is a tool/command reference (non-standard naming — treat as `references/cli-commands.md`). It documents Turbo CLI flags and is loaded when CLI flag questions arise.

### Configuration

| File                                                                            | Purpose                                                  |
| ------------------------------------------------------------------------------- | -------------------------------------------------------- |
| [configuration/RULE.md](./references/configuration/RULE.md)                     | turbo.json overview, Package Configurations              |
| [configuration/tasks.md](./references/configuration/tasks.md)                   | dependsOn, outputs, inputs, env, cache, persistent       |
| [configuration/global-options.md](./references/configuration/global-options.md) | globalEnv, globalDependencies, cacheDir, daemon, envMode |
| [configuration/gotchas.md](./references/configuration/gotchas.md)               | Common configuration mistakes                            |

### Caching

| File                                                            | Purpose                                      |
| --------------------------------------------------------------- | -------------------------------------------- |
| [caching/RULE.md](./references/caching/RULE.md)                 | How caching works, hash inputs               |
| [caching/remote-cache.md](./references/caching/remote-cache.md) | Vercel Remote Cache, self-hosted, login/link |
| [caching/gotchas.md](./references/caching/gotchas.md)           | Debugging cache misses, --summarize, --dry   |

### Environment Variables

| File                                                          | Purpose                                   |
| ------------------------------------------------------------- | ----------------------------------------- |
| [environment/RULE.md](./references/environment/RULE.md)       | env, globalEnv, passThroughEnv            |
| [environment/modes.md](./references/environment/modes.md)     | Strict vs Loose mode, framework inference |
| [environment/gotchas.md](./references/environment/gotchas.md) | .env files, CI issues                     |

### Filtering

| File                                                        | Purpose                  |
| ----------------------------------------------------------- | ------------------------ |
| [filtering/RULE.md](./references/filtering/RULE.md)         | --filter syntax overview |
| [filtering/patterns.md](./references/filtering/patterns.md) | Common filter patterns   |

### CI/CD

| File                                                      | Purpose                         |
| --------------------------------------------------------- | ------------------------------- |
| [ci/RULE.md](./references/ci/RULE.md)                     | General CI principles           |
| [ci/github-actions.md](./references/ci/github-actions.md) | Complete GitHub Actions setup   |
| [ci/vercel.md](./references/ci/vercel.md)                 | Vercel deployment, turbo-ignore |
| [ci/patterns.md](./references/ci/patterns.md)             | --affected, caching strategies  |

### CLI

| File                                            | Purpose                                       |
| ----------------------------------------------- | --------------------------------------------- |
| [cli/RULE.md](./references/cli/RULE.md)         | turbo run basics                              |
| [cli/commands.md](./references/cli/commands.md) | turbo run flags, turbo-ignore, other commands |

### Best Practices

| File                                                                          | Purpose                                                         |
| ----------------------------------------------------------------------------- | --------------------------------------------------------------- |
| [best-practices/RULE.md](./references/best-practices/RULE.md)                 | Monorepo best practices overview                                |
| [best-practices/structure.md](./references/best-practices/structure.md)       | Repository structure, workspace config, TypeScript/ESLint setup |
| [best-practices/packages.md](./references/best-practices/packages.md)         | Creating internal packages, JIT vs Compiled, exports            |
| [best-practices/dependencies.md](./references/best-practices/dependencies.md) | Dependency management, installing, version sync                 |

### Watch Mode

| File                                        | Purpose                                         |
| ------------------------------------------- | ----------------------------------------------- |
| [watch/RULE.md](./references/watch/RULE.md) | turbo watch, interruptible tasks, dev workflows |

### Boundaries (Experimental)

| File                                                  | Purpose                                               |
| ----------------------------------------------------- | ----------------------------------------------------- |
| [boundaries/RULE.md](./references/boundaries/RULE.md) | Enforce package isolation, tag-based dependency rules |

## Source Documentation

This skill is based on the official Turborepo documentation at:

- Source: `apps/docs/content/docs/` in the Turborepo repository
- Live: https://turborepo.dev/docs
