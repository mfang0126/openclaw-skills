---
name: supabase-backend-platform
description: |
  Supabase backend platform skill. Use when user mentions: Supabase, Postgres database,
  authentication/auth, RLS, row level security, storage buckets, realtime subscriptions,
  edge functions, supabase-js, createClient, signInWithPassword, .from().select(),
  or building full-stack apps with Next.js/React/Vue requiring integrated backend services.

  USE FOR:
  - "Supabase 项目搭建", "set up Supabase auth", "add Supabase to Next.js"
  - "configure RLS", "row level security policy", "Supabase storage upload"
  - "realtime subscriptions", "edge functions on Deno", "supabase-js createClient"
  - "Firebase alternative", "open-source backend", "Postgres with auth"
  - User needs database + auth + storage integrated in one platform
progressive_disclosure:
  entry_point:
    summary: "Supabase open-source Firebase alternative with Postgres, authentication, storage, and realtime subscriptions. Use when building full-stack applications requiring integrated backend services with Ne..."
    when_to_use: "When working with supabase-backend-platform or related functionality."
    quick_start: "1. Review the core concepts below. 2. Apply patterns to your use case. 3. Follow best practices for implementation."
---
# Supabase Backend Platform Skill

**Pattern: Tool Wrapper**

## When to Use

Use when building **full-stack applications that need a hosted Postgres database with integrated auth, file storage, and realtime features**. Supabase is the go-to when you want Firebase-like DX but with SQL power and open-source flexibility.

**Don't use when:** You only need a raw Postgres connection without auth/realtime (use a plain Postgres provider), or you need highly custom server logic better served by a dedicated Node/Express backend.

## Prerequisites

1. Supabase project created at [supabase.com](https://supabase.com) (or local via CLI)
2. Environment variables: `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY`
3. `npm install @supabase/supabase-js` installed in your project
4. For SSR (Next.js App Router): `npm install @supabase/ssr`
5. For local dev: `npm install -D supabase` + Docker running

## Error Handling

| Error | Cause | Solution |
|-------|-------|----------|
| `Invalid API key` | Wrong or missing anon/service key | Check env vars match Supabase project settings |
| `new row violates RLS policy` | RLS enabled but no matching policy | Add policy for the operation (INSERT/SELECT/UPDATE/DELETE) |
| `JWT expired` | Auth token has expired | Call `supabase.auth.refreshSession()` or re-login |
| `relation does not exist` | Table not created or wrong schema | Run migration or check schema name (default: `public`) |
| `fetch failed` / network error | SUPABASE_URL wrong or project paused | Verify URL; unpause project in dashboard if on free tier |
| `Storage object not found` | File path wrong or bucket doesn't exist | Create bucket first; check exact path used in upload |

## Supabase Fundamentals

### What is Supabase?
Open-source Firebase alternative built on:
- **Postgres Database**: Full SQL database with PostgREST API
- **Authentication**: Built-in auth with multiple providers
- **Storage**: File storage with image transformations
- **Realtime**: WebSocket subscriptions to database changes
- **Edge Functions**: Serverless functions on Deno runtime
- **Row Level Security**: Postgres RLS for data access control

### Project Setup
```bash
# Install Supabase client
npm install @supabase/supabase-js

# Install CLI for local development
npm install -D supabase

# TypeScript types
npm install -D @supabase/supabase-js
```

### Client Initialization
```typescript
// lib/supabase.ts
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

// With TypeScript types
import { Database } from '@/types/supabase'

export const supabase = createClient<Database>(
  supabaseUrl,
  supabaseAnonKey
)
```

## Reference Files

All detailed patterns and code examples are in `references/`. Read the relevant file based on what you're building:

| Reference | Contents | Read When |
|-----------|----------|-----------|
| `references/database.md` | PostgREST API, CRUD, advanced queries, RPC, pagination | Working with database queries |
| `references/auth.md` | Email/password, OAuth, magic links, phone, auth state | Implementing authentication |
| `references/rls.md` | RLS fundamentals, common patterns, helper functions | Setting up row-level security |
| `references/storage.md` | Upload, download, signed URLs, transforms, storage RLS | File storage operations |
| `references/realtime.md` | DB change subscriptions, presence, broadcast | Adding realtime features |
| `references/edge-functions.md` | Deno runtime, function examples, invocation | Building serverless functions |
| `references/nextjs.md` | App Router setup, middleware, server/client components, server actions | Next.js integration |
| `references/typescript.md` | Type generation CLI, typed queries | TypeScript type safety |
| `references/cli.md` | Local dev setup, migrations, CLI commands | Local development |
| `references/security.md` | API key management, RLS best practices, input validation | Security hardening |
| `references/production.md` | DB optimization, connection pooling, monitoring, backups | Production deployment |
| `references/advanced-patterns.md` | Optimistic updates, infinite scroll, debounced search | Advanced React/Next.js patterns |

## Example

**User says:** "set up Supabase auth in my Next.js app"

**Steps:**
1. Install packages: `npm install @supabase/supabase-js @supabase/ssr`
2. Create `lib/supabase.ts` with `createClient(SUPABASE_URL, SUPABASE_ANON_KEY)`
3. Add middleware (`middleware.ts`) to refresh sessions on every request
4. Build sign-in form calling `supabase.auth.signInWithPassword({ email, password })`
5. Protect routes by checking session in middleware or server component

**Output:** Working email/password auth with session persistence, protected routes, and SSR-compatible Supabase client

**Reply:** "Here's a complete Next.js App Router auth setup with Supabase. I've included the client setup, middleware for session refresh, a sign-in form, and a protected dashboard route. Check `references/auth.md` and `references/nextjs.md` for advanced patterns like OAuth and magic links."

---

## Quick Start

```bash
npm install @supabase/supabase-js
```

```typescript
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)
```

## Decision Tree

**What are you building?**
- Auth flow → `references/auth.md`
- Database queries → `references/database.md`
- Access control → `references/rls.md`
- File uploads → `references/storage.md`
- Live updates → `references/realtime.md`
- Serverless logic → `references/edge-functions.md`
- Next.js app → `references/nextjs.md` (also auth.md + rls.md)
- Going to production → `references/security.md` + `references/production.md`

## Core Concepts

**Supabase = Postgres + Auth + Storage + Realtime + Edge Functions**

- All services integrate with the same Postgres database
- Row Level Security (RLS) is the security layer — always enable it
- Use anon key client-side, service_role key server-side only
- supabase-js v2 is the current version (`@supabase/supabase-js`)

## Version

- **supabase-js**: v2
- **Next.js patterns**: App Router (Server Components, Server Actions, Middleware)
- **Auth**: `@supabase/ssr` for SSR-compatible auth

