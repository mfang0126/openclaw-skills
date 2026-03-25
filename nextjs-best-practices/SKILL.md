---
name: nextjs-best-practices
description: "Next.js App Router best practices, patterns, and decisions. Use when user asks about Next.js, App Router, Server Components, Client Components, data fetching, RSC, routing, metadata, caching, or server actions."
allowed-tools: Read, Write, Edit, Glob, Grep
risk: unknown
source: community
---

# Next.js Best Practices

**Pattern: Tool Wrapper** (Google ADK) — Trigger → Load Knowledge → Answer → Guide

> Principles for Next.js App Router development.

## USE FOR
- "should this be a server or client component?"
- "how do I fetch data in Next.js App Router?"
- "Next.js routing patterns"
- "server actions best practices"
- "Next.js caching strategy"
- "optimize my Next.js app"
- "Next.js metadata setup"
- "App Router file conventions"
- "RSC vs client component"

## REPLACES
- N/A

## REQUIRES
- Next.js 13+ with App Router enabled
- React 18+

## When to Use

Load this skill whenever the user is working on a Next.js App Router project and needs guidance on:
- Component type decisions (server vs client)
- Data fetching strategy
- Routing and file conventions
- Performance optimization
- Caching and revalidation
- SEO and metadata

Trigger keywords: Next.js, App Router, Server Components, RSC, server actions, ISR, `use client`, `use server`.

**Don't use when:** User is working with Pages Router (not App Router), or using a non-Next.js framework entirely.

## Prerequisites

- Project uses Next.js App Router (not Pages Router)
- `app/` directory exists in project root

## Quick Start

1. Default to **Server Components** — add `'use client'` only when needed
2. Fetch data in Server Components, pass as props to Client Components
3. Use `loading.tsx` + `error.tsx` for every significant route
4. Prefer `generateMetadata` for dynamic pages, static export for fixed pages

## Example

**User says:** "should this be a server or client component?" → Steps: apply the decision tree (needs useState/useEffect/event handlers? → Client; pure data fetch, no interactivity? → Server; both? → split into Server parent + Client child) → Output: component type recommendation with rationale → Reply: "Use a **Server Component** for the data fetching, then pass the data as props to a `'use client'` child component for the interactive parts."

---

**User:** "I need to show a user's dashboard with live data and interactive charts."

```
app/dashboard/
├── page.tsx           ← Server Component: fetch user data server-side
├── layout.tsx         ← Server Component: shared dashboard nav
├── loading.tsx        ← Loading skeleton
└── components/
    ├── StatsCard.tsx  ← Server Component: display static stats
    └── ChartWidget.tsx← Client Component ('use client'): interactive chart
```

`page.tsx` fetches data server-side, passes to `StatsCard` (server) and `ChartWidget` (client props only).

## Error Handling

| Error | Cause | Fix |
|-------|-------|-----|
| "useState in Server Component" | Missing 'use client' | Add `'use client'` directive at top of file |
| Hydration mismatch | Server/client render difference | Check for browser-only APIs in server code |
| Stale data shown | Over-aggressive caching | Use `revalidate: 0` or `no-store` for dynamic data |
| Build error in Server Action | Missing 'use server' | Add `'use server'` directive to action file/function |
| Large client bundle | Too many Client Components | Move logic to Server Components, use dynamic imports |

---

## 1. Server vs Client Components

### Decision Tree

```
Does it need...?
│
├── useState, useEffect, event handlers
│   └── Client Component ('use client')
│
├── Direct data fetching, no interactivity
│   └── Server Component (default)
│
└── Both? 
    └── Split: Server parent + Client child
```

### By Default

| Type | Use |
|------|-----|
| **Server** | Data fetching, layout, static content |
| **Client** | Forms, buttons, interactive UI |

---

## 2. Data Fetching Patterns

### Fetch Strategy

| Pattern | Use |
|---------|-----|
| **Default** | Static (cached at build) |
| **Revalidate** | ISR (time-based refresh) |
| **No-store** | Dynamic (every request) |

### Data Flow

| Source | Pattern |
|--------|---------|
| Database | Server Component fetch |
| API | fetch with caching |
| User input | Client state + server action |

---

## 3. Routing Principles

### File Conventions

| File | Purpose |
|------|---------|
| `page.tsx` | Route UI |
| `layout.tsx` | Shared layout |
| `loading.tsx` | Loading state |
| `error.tsx` | Error boundary |
| `not-found.tsx` | 404 page |

### Route Organization

| Pattern | Use |
|---------|-----|
| Route groups `(name)` | Organize without URL |
| Parallel routes `@slot` | Multiple same-level pages |
| Intercepting `(.)` | Modal overlays |

---

## 4. API Routes

### Route Handlers

| Method | Use |
|--------|-----|
| GET | Read data |
| POST | Create data |
| PUT/PATCH | Update data |
| DELETE | Remove data |

### Best Practices

- Validate input with Zod
- Return proper status codes
- Handle errors gracefully
- Use Edge runtime when possible

---

## 5. Performance Principles

### Image Optimization

- Use next/image component
- Set priority for above-fold
- Provide blur placeholder
- Use responsive sizes

### Bundle Optimization

- Dynamic imports for heavy components
- Route-based code splitting (automatic)
- Analyze with bundle analyzer

---

## 6. Metadata

### Static vs Dynamic

| Type | Use |
|------|-----|
| Static export | Fixed metadata |
| generateMetadata | Dynamic per-route |

### Essential Tags

- title (50-60 chars)
- description (150-160 chars)
- Open Graph images
- Canonical URL

---

## 7. Caching Strategy

### Cache Layers

| Layer | Control |
|-------|---------|
| Request | fetch options |
| Data | revalidate/tags |
| Full route | route config |

### Revalidation

| Method | Use |
|--------|-----|
| Time-based | `revalidate: 60` |
| On-demand | `revalidatePath/Tag` |
| No cache | `no-store` |

---

## 8. Server Actions

### Use Cases

- Form submissions
- Data mutations
- Revalidation triggers

### Best Practices

- Mark with 'use server'
- Validate all inputs
- Return typed responses
- Handle errors

---

## 9. Anti-Patterns

| ❌ Don't | ✅ Do |
|----------|-------|
| 'use client' everywhere | Server by default |
| Fetch in client components | Fetch in server |
| Skip loading states | Use loading.tsx |
| Ignore error boundaries | Use error.tsx |
| Large client bundles | Dynamic imports |

---

## 10. Project Structure

```
app/
├── (marketing)/     # Route group
│   └── page.tsx
├── (dashboard)/
│   ├── layout.tsx   # Dashboard layout
│   └── page.tsx
├── api/
│   └── [resource]/
│       └── route.ts
└── components/
    └── ui/
```

---

> **Remember:** Server Components are the default for a reason. Start there, add client only when needed.

## When to Use
This skill is applicable to execute the workflow or actions described in the overview.
