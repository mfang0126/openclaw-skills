---
user-invocable: false
name: nextjs-supabase-auth
description: "Expert integration of Supabase Auth with Next.js App Router Use when: supabase auth next, authentication next.js, login supabase, auth middleware, protected route, oauth callback, session refresh, protected page, @supabase/ssr."
source: vibeship-spawner-skills (Apache 2.0)
risk: unknown
requires:
  bins: []
  modules: ["@supabase/ssr", "next"]
---

# Next.js + Supabase Auth

**Pattern: Tool Wrapper** (Google ADK) — Loads specialized Next.js + Supabase Auth knowledge on demand; expert reference layer.

## USE FOR

- "set up supabase auth in next.js"
- "protect a route with middleware"
- "supabase login page app router"
- "oauth callback handler next.js"
- "session refresh middleware"
- "server component auth check"
- "supabase auth with server actions"

## When to Use

- User is setting up Supabase Auth in a Next.js App Router project
- User needs protected routes with session-aware middleware
- User needs an OAuth callback route
- User is migrating from `@supabase/auth-helpers-nextjs` to `@supabase/ssr`
- Any auth-related Next.js question involving Supabase

**Don't use when:** Using a non-Supabase auth provider (Auth0, NextAuth, Clerk), or building a static site without auth needs.

## Prerequisites

- Next.js 13+ with App Router
- Supabase project created (get URL + anon key from dashboard)
- `@supabase/ssr` installed: `npm install @supabase/ssr @supabase/supabase-js`
- Environment variables set: `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`

## Quick Start

```typescript
// The most common pattern: server-side client (Server Component / Route Handler)
import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'

export function createClient() {
  const cookieStore = cookies()
  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() { return cookieStore.getAll() },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value, options }) =>
            cookieStore.set(name, value, options))
        },
      },
    }
  )
}
```

You are an expert in integrating Supabase Auth with Next.js App Router.
You understand the server/client boundary, how to handle auth in middleware,
Server Components, Client Components, and Server Actions.

Your core principles:
1. Use @supabase/ssr for App Router integration
2. Handle tokens in middleware for protected routes
3. Never expose auth tokens to client unnecessarily
4. Use Server Actions for auth operations when possible
5. Understand the cookie-based session flow

## Capabilities

- nextjs-auth
- supabase-auth-nextjs
- auth-middleware
- auth-callback

## Requirements

- nextjs-app-router
- supabase-backend

## Patterns

### Supabase Client Setup

Three client types — use the right one for each context:

| Context | Import | Use When |
|---------|--------|----------|
| Server Component / Route Handler | `createServerClient` from `@supabase/ssr` | Reading user, fetching data server-side |
| Client Component | `createBrowserClient` from `@supabase/ssr` | Listening to auth state, real-time |
| Middleware | `createServerClient` with response cookies | Refreshing session on every request |

### Auth Middleware

Protect routes and refresh sessions in middleware. Add to `middleware.ts`:

```typescript
import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

export async function middleware(request: NextRequest) {
  let supabaseResponse = NextResponse.next({ request })

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() { return request.cookies.getAll() },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(name, value, options))
        },
      },
    }
  )

  const { data: { user } } = await supabase.auth.getUser()

  if (!user && !request.nextUrl.pathname.startsWith('/login')) {
    const url = request.nextUrl.clone()
    url.pathname = '/login'
    return NextResponse.redirect(url)
  }

  return supabaseResponse
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico).*)'],
}
```

### Auth Callback Route

Handle OAuth callback and exchange code for session. Create `app/auth/callback/route.ts`:

```typescript
import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'
import { NextResponse } from 'next/server'

export async function GET(request: Request) {
  const { searchParams, origin } = new URL(request.url)
  const code = searchParams.get('code')
  const next = searchParams.get('next') ?? '/'

  if (code) {
    const cookieStore = cookies()
    const supabase = createServerClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
      {
        cookies: {
          getAll() { return cookieStore.getAll() },
          setAll(cookiesToSet) {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options))
          },
        },
      }
    )
    const { error } = await supabase.auth.exchangeCodeForSession(code)
    if (!error) {
      return NextResponse.redirect(`${origin}${next}`)
    }
  }

  return NextResponse.redirect(`${origin}/auth/auth-code-error`)
}
```

## Anti-Patterns

### ❌ getSession in Server Components

### ❌ Auth State in Client Without Listener

### ❌ Storing Tokens Manually

## Related Skills

Works well with: `nextjs-app-router`, `supabase-backend`

## Error Handling

| Error | Cause | Fix |
|-------|-------|-----|
| `AuthSessionMissingError` | Cookie not set or expired | Check middleware is running; verify env vars |
| `invalid_grant` on callback | Code expired or already used | Ensure callback URL is in Supabase dashboard allowed list |
| `NEXT_PUBLIC_SUPABASE_URL missing` | Env var not set | Add to `.env.local` and restart dev server |
| Session not persisting | Using `getSession()` in Server Component | Use `getUser()` instead — `getSession()` is client-side only |
| PKCE error | Auth code flow misconfigured | Set `flowType: 'pkce'` in Supabase client options |
| Redirect loop in middleware | Protected route includes `/login` | Add `/login` to the middleware matcher exclusion list |

## Example

**User says:** "set up Supabase auth login page in my Next.js app"

**Steps:**
1. Install `@supabase/ssr` and `@supabase/supabase-js`
2. Create `utils/supabase/client.ts` (browser client) and `utils/supabase/server.ts` (server client)
3. Add `middleware.ts` to refresh sessions on every request
4. Create `app/login/page.tsx` with email/password form using Server Action
5. Create `app/auth/callback/route.ts` to handle OAuth code exchange
6. Protect `app/dashboard/page.tsx` with `getUser()` + redirect

**Output:** Fully working auth flow with middleware-protected routes, server-side session validation, and OAuth callback handler.

**Reply:** "I've set up Supabase Auth with email/password login and protected routes. Your `/dashboard` now requires authentication — unauthenticated users are redirected to `/login`. Set `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` in `.env.local` to connect to your Supabase project."

## Example: End-to-End Protected Page

```typescript
// app/dashboard/page.tsx (Server Component)
import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'

export default async function DashboardPage() {
  const supabase = createClient()
  const { data: { user } } = await supabase.auth.getUser()

  if (!user) {
    redirect('/login')
  }

  return <div>Welcome, {user.email}</div>
}
```

Combined with the middleware above, this gives **double protection**: middleware redirects unauthenticated requests before the page renders, and the page itself validates again as a safety net.
