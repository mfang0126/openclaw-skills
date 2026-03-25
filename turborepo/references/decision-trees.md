# Quick Decision Trees

> Use these decision trees to navigate Turborepo configuration questions quickly.

## Quick Decision Trees

### "I need to configure a task"

```
Configure a task?
├─ Define task dependencies → references/configuration/tasks.md
├─ Lint/check-types (parallel + caching) → Use Transit Nodes pattern (see below)
├─ Specify build outputs → references/configuration/tasks.md#outputs
├─ Handle environment variables → references/environment/RULE.md
├─ Set up dev/watch tasks → references/configuration/tasks.md#persistent
├─ Package-specific config → references/configuration/RULE.md#package-configurations
└─ Global settings (cacheDir, daemon) → references/configuration/global-options.md
```

### "My cache isn't working"

```
Cache problems?
├─ Tasks run but outputs not restored → Missing `outputs` key
├─ Cache misses unexpectedly → references/caching/gotchas.md
├─ Need to debug hash inputs → Use --summarize or --dry
├─ Want to skip cache entirely → Use --force or cache: false
├─ Remote cache not working → references/caching/remote-cache.md
└─ Environment causing misses → references/environment/gotchas.md
```

### "I want to run only changed packages"

```
Run only what changed?
├─ Changed packages + dependents (RECOMMENDED) → turbo run build --affected
├─ Custom base branch → --affected --affected-base=origin/develop
├─ Manual git comparison → --filter=...[origin/main]
└─ See all filter options → references/filtering/RULE.md
```

**`--affected` is the primary way to run only changed packages.** It automatically compares against the default branch and includes dependents.

### "I want to filter packages"

```
Filter packages?
├─ Only changed packages → --affected (see above)
├─ By package name → --filter=web
├─ By directory → --filter=./apps/*
├─ Package + dependencies → --filter=web...
├─ Package + dependents → --filter=...web
└─ Complex combinations → references/filtering/patterns.md
```

### "Environment variables aren't working"

```
Environment issues?
├─ Vars not available at runtime → Strict mode filtering (default)
├─ Cache hits with wrong env → Var not in `env` key
├─ .env changes not causing rebuilds → .env not in `inputs`
├─ CI variables missing → references/environment/gotchas.md
└─ Framework vars (NEXT_PUBLIC_*) → Auto-included via inference
```

### "I need to set up CI"

```
CI setup?
├─ GitHub Actions → references/ci/github-actions.md
├─ Vercel deployment → references/ci/vercel.md
├─ Remote cache in CI → references/caching/remote-cache.md
├─ Only build changed packages → --affected flag
├─ Skip unnecessary builds → turbo-ignore (references/cli/commands.md)
└─ Skip container setup when no changes → turbo-ignore
```

### "I want to watch for changes during development"

```
Watch mode?
├─ Re-run tasks on change → turbo watch (references/watch/RULE.md)
├─ Dev servers with dependencies → Use `with` key (references/configuration/tasks.md#with)
├─ Restart dev server on dep change → Use `interruptible: true`
└─ Persistent dev tasks → Use `persistent: true`
```

### "I need to create/structure a package"

```
Package creation/structure?
├─ Create an internal package → references/best-practices/packages.md
├─ Repository structure → references/best-practices/structure.md
├─ Dependency management → references/best-practices/dependencies.md
├─ Best practices overview → references/best-practices/RULE.md
├─ JIT vs Compiled packages → references/best-practices/packages.md#compilation-strategies
└─ Sharing code between apps → references/best-practices/RULE.md#package-types
```

### "How should I structure my monorepo?"

```
Monorepo structure?
├─ Standard layout (apps/, packages/) → references/best-practices/RULE.md
├─ Package types (apps vs libraries) → references/best-practices/RULE.md#package-types
├─ Creating internal packages → references/best-practices/packages.md
├─ TypeScript configuration → references/best-practices/structure.md#typescript-configuration
├─ ESLint configuration → references/best-practices/structure.md#eslint-configuration
├─ Dependency management → references/best-practices/dependencies.md
└─ Enforce package boundaries → references/boundaries/RULE.md
```

### "I want to enforce architectural boundaries"

```
Enforce boundaries?
├─ Check for violations → turbo boundaries
├─ Tag packages → references/boundaries/RULE.md#tags
├─ Restrict which packages can import others → references/boundaries/RULE.md#rule-types
└─ Prevent cross-package file imports → references/boundaries/RULE.md
```
