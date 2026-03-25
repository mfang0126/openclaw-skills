# UPGRADE_PLAN: nextjs-supabase-auth

> Generated: 2026-03-25 | SOP Version: 1.0

## Pattern Classification

**Pattern: Tool Wrapper**
Rationale: Loads specialized Next.js + Supabase Auth knowledge on demand; acts as an expert reference layer rather than executing a step-by-step pipeline or generating fixed-format output.

## Current State

| File | Status |
|------|--------|
| SKILL.md | ✅ Exists (needs content fixes) |
| README.md | ❌ Missing |
| _meta.json | ❌ Missing |
| evals/evals.json | ❌ Missing |
| scripts/ | ❌ Missing |

**Missing files: 4** (README.md, _meta.json, evals/evals.json, scripts/)

## SKILL.md Issues

| Check | Status | Notes |
|-------|--------|-------|
| `name` + `description` in frontmatter | ✅ | Present |
| Description is pushy with trigger keywords | ✅ | Keywords in description |
| `USE FOR:` section | ❌ | Missing — add example trigger phrases |
| `REPLACES:` | ➖ | N/A (no predecessor) |
| `REQUIRES:` | ❌ | Missing — needs nextjs-app-router, supabase-backend listed |
| Pattern label | ❌ | Missing — add "**Pattern: Tool Wrapper**" |
| `When to Use` section | ⚠️ | Exists but is generic boilerplate — needs real triggers |
| `Prerequisites` section | ❌ | Missing — Next.js 13+, @supabase/ssr, etc. |
| `Quick Start` | ❌ | Missing — most common usage snippet |
| `Instructions` / `Pipeline` | ⚠️ | Patterns listed as headers only, no actual content |
| At least 1 complete `Example` | ❌ | Missing |
| `Error Handling` table | ❌ | Missing |
| < 500 lines | ✅ | Well under limit |

## Action Plan

### Priority 1 — Fix SKILL.md (critical)

1. Add `**Pattern: Tool Wrapper**` label near top of body
2. Replace generic `When to Use` with real trigger phrases:
   - "set up supabase auth", "protected route next.js", "auth middleware", "login page supabase", "oauth callback"
3. Add `USE FOR:` section with 5+ example prompts
4. Add `REQUIRES:` frontmatter: `nextjs >=13, @supabase/ssr, supabase project`
5. Add `Prerequisites` section: Next.js App Router, Supabase project setup, `@supabase/ssr` installed
6. Add `Quick Start` section with the most common pattern (server-side client setup)
7. Flesh out the 3 pattern sections (Supabase Client Setup, Auth Middleware, Auth Callback Route) with actual code and explanation
8. Add at least 1 complete `Example`: end-to-end protected route with middleware + Server Component
9. Add `Error Handling` table covering: invalid token, expired session, missing env vars, PKCE errors

### Priority 2 — Create Missing Files

#### `_meta.json`
```json
{
  "name": "nextjs-supabase-auth",
  "version": "1.0.0",
  "author": "King",
  "pattern": "Tool Wrapper",
  "emoji": "🔐",
  "created": "2026-03-25",
  "requires": { "bins": [], "modules": ["@supabase/ssr", "next"] },
  "tags": ["nextjs", "supabase", "auth", "middleware"]
}
```

#### `evals/evals.json`
Minimum 3 test cases:
1. "Set up Supabase Auth in Next.js App Router" → expects client setup code for server + browser contexts
2. "Protect a route using middleware" → expects middleware.ts with session refresh logic
3. "Handle OAuth callback" → expects `/auth/callback/route.ts` with code exchange

#### `scripts/`
This is a knowledge skill (Tool Wrapper) — no runtime script needed.
Add a placeholder `scripts/.gitkeep` or a `scripts/check-deps.sh` that verifies `@supabase/ssr` is installed.

#### `README.md`
- How it works: knowledge injection at prompt time
- Design decisions: why `@supabase/ssr` over legacy `@supabase/auth-helpers-nextjs`
- Supported patterns: server client, browser client, middleware, server actions
- Limitations: App Router only (not Pages Router)
- Related skills: `nextjs-app-router`, `supabase-backend`

## Estimated Effort

| Task | Effort |
|------|--------|
| Fix SKILL.md | ~45 min |
| Write README.md | ~20 min |
| Write _meta.json | ~5 min |
| Write evals.json | ~15 min |
| Total | ~85 min |
