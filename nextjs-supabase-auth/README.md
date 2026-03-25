# nextjs-supabase-auth

> Expert knowledge layer for integrating Supabase Auth with Next.js App Router.

**Pattern: Tool Wrapper** (Google ADK)

## How It Works

This skill injects specialized knowledge at prompt time — no scripts, no runtime dependencies. When loaded, the agent has expert-level understanding of:

- `@supabase/ssr` client setup (server, browser, middleware contexts)
- Auth middleware for protecting routes and refreshing sessions
- OAuth callback route (`/auth/callback`)
- Server Component auth patterns (using `getUser()`, not `getSession()`)
- Server Actions for auth operations

## Design Decisions

**Why `@supabase/ssr` over `@supabase/auth-helpers-nextjs`?**
`auth-helpers-nextjs` is deprecated. `@supabase/ssr` is the current official package for App Router, with proper cookie handling across server/client boundary.

**Why `getUser()` not `getSession()` in Server Components?**
`getSession()` reads from local storage (client-side). `getUser()` calls the Supabase Auth server to validate the JWT — secure and correct for server-side use.

**Why middleware for session refresh?**
The Supabase session token refreshes via cookies. Without middleware running `getUser()` on every request, cookies can go stale and the user gets logged out unexpectedly.

## Supported Patterns

| Pattern | Description |
|---------|-------------|
| Server Client | `createServerClient` for Server Components, Route Handlers, Server Actions |
| Browser Client | `createBrowserClient` for Client Components with real-time auth |
| Middleware | Session refresh + route protection on every request |
| OAuth Callback | PKCE code exchange at `/auth/callback` |

## Limitations

- App Router only — **not compatible with Pages Router** (`getServerSideProps` / `getStaticProps` patterns differ)
- Requires Next.js 13.4+ (server actions need 13.4+)
- PKCE flow requires cookies to be enabled in the browser

## Related Skills

- `nextjs-app-router` — General Next.js App Router patterns
- `supabase-backend` — Supabase database, RLS, storage

## Quick Reference

```bash
# Install
npm install @supabase/ssr @supabase/supabase-js

# Required env vars
NEXT_PUBLIC_SUPABASE_URL=https://xxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJh...
```
