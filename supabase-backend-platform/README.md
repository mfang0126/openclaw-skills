# supabase-backend-platform

> Supabase backend knowledge on demand — database, auth, RLS, storage, realtime, edge functions, Next.js integration.

## How It Works

**Pattern: Tool Wrapper** (Google ADK)

This skill loads Supabase API/SDK knowledge on demand via reference files. Claude reads the relevant reference file based on what you're building — no need to load everything at once.

## Reference File Map

```
references/
├── database.md        # PostgREST CRUD, advanced queries, RPC, pagination
├── auth.md            # Email/password, OAuth, magic links, phone, auth state
├── rls.md             # RLS fundamentals, common patterns, auth.uid() helpers
├── storage.md         # Upload, download, signed URLs, image transforms, storage RLS
├── realtime.md        # DB changes, presence, broadcast
├── edge-functions.md  # Deno runtime, invocation, examples
├── nextjs.md          # App Router, middleware, server/client components, server actions
├── typescript.md      # Type generation CLI, typed queries
├── cli.md             # Local dev, migrations, CLI commands
├── security.md        # API key management, RLS best practices, input validation
├── production.md      # DB optimization, connection pooling, monitoring, backups
└── advanced-patterns.md  # Optimistic updates, infinite scroll, debounced search
```

## Design Decisions

- **Split vs inline**: Content was ~1400 lines inline — exceeds the 500-line guideline by 3x. Split into 12 focused reference files averaging 100 lines each, reducing load time for typical use cases
- **Decision tree in SKILL.md**: Helps Claude pick the right reference file without reading everything
- **Next.js App Router focus**: Patterns for Server Components, not Pages Router (still compatible)

## Framework Compatibility

| Framework | Support | Reference |
|-----------|---------|-----------|
| Next.js App Router | ✅ Full | `references/nextjs.md` |
| Next.js Pages Router | ⚠️ Partial (use older SSR patterns) | `references/auth.md` |
| React (SPA) | ✅ Full | `references/auth.md`, `references/database.md` |
| Vue / Nuxt | ✅ Compatible | Same JS API, adapt component syntax |

## Limitations

- Requires a live Supabase project (or local Supabase CLI setup)
- Version tracked: supabase-js v2, Next.js App Router patterns
- No offline support — all features require network access to Supabase project
- Service role key patterns are server-only — never expose in client code
