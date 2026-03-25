# nextjs-best-practices

> Next.js App Router reference guide: Server Components, data fetching, routing, caching, and server actions.

## Install

No installation needed. This is a knowledge/reference skill — loaded on demand when working on Next.js projects.

## Usage

Reference this skill when making decisions about:
- Server vs Client Components
- Data fetching strategy
- App Router file conventions
- Performance optimization
- Caching and revalidation

## How It Works

**Pattern: Tool Wrapper** (Google ADK)

```
User asks Next.js question
  → Load SKILL.md knowledge
  → Apply relevant section (routing / components / caching / etc.)
  → Answer with concrete guidance + code examples
```

## Design Decisions

- **Tool Wrapper (not Pipeline)**: This is reference knowledge pulled on demand, not a multi-step process.
- **App Router only**: Pages Router is out of scope. If user is on Pages Router, flag it.
- **Server-first philosophy**: The guide defaults to Server Components; `'use client'` is the exception not the rule.
- **Opinionated**: Gives concrete recommendations, not "it depends" non-answers.

## Scope

✅ Covers:
- Server vs Client Component decision tree
- Data fetching patterns (static, ISR, dynamic)
- App Router file conventions (`page.tsx`, `layout.tsx`, `loading.tsx`, `error.tsx`)
- Routing: groups, parallel routes, intercepting routes
- API route handlers
- Performance: images, bundle splitting, dynamic imports
- Metadata: static export vs `generateMetadata`
- Caching strategy: request, data, route layers
- Server Actions: forms, mutations, revalidation
- Anti-patterns to avoid

❌ Does NOT cover:
- Next.js Pages Router
- Deployment (Vercel, Docker, etc.)
- Third-party auth libraries (NextAuth, Clerk — out of scope)
- Database ORM integration (Prisma, Drizzle — out of scope)

## Limitations

- Knowledge cutoff: App Router as of Next.js 14/15
- Does not validate or test code — always test in a real project
- Complex edge cases (Parallel Routes, Intercepting Routes) may need supplementary docs

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/check-structure.sh` | Validate Next.js App Router project structure |

## Related Skills

- None currently
