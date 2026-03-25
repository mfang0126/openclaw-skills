# Upgrade Plan: nextjs-best-practices

> Generated: 2026-03-25 | SOP Version: 1.0

## Pattern Classification

**Pattern: Tool Wrapper**
> "Load knowledge on demand" — surfaces Next.js App Router knowledge, patterns, and decisions when the user is building or reviewing a Next.js project.

## Current State

| File | Status |
|------|--------|
| SKILL.md | ✅ Exists (incomplete) |
| README.md | ❌ Missing |
| _meta.json | ❌ Missing |
| evals/evals.json | ❌ Missing |
| scripts/ | ❌ Missing |

**Missing files: 4** (README.md, _meta.json, evals/evals.json, scripts/)

## SKILL.md Issues

SKILL.md has solid reference content but is missing most structural/formal requirements:

| Check | Status |
|-------|--------|
| `name` + `description` frontmatter | ✅ (minimal) |
| Description is pushy with trigger keywords | ❌ Description is vague ("principles") |
| `USE FOR:` section | ❌ Missing |
| `REPLACES:` | ❌ Missing |
| `REQUIRES:` dependencies | ❌ Missing |
| Pattern label (`**Pattern: Tool Wrapper**`) | ❌ Missing |
| `When to Use` section | ⚠️ Exists but is 1 generic line at bottom |
| `Prerequisites` section | ❌ Missing |
| `Quick Start` | ❌ Missing |
| `Instructions` / reference content | ✅ Comprehensive (10 sections) |
| At least 1 complete `Example` | ❌ Missing (tables/decisions but no worked examples) |
| `Error Handling` table | ❌ Missing |
| < 500 lines | ✅ |

## Action Items

### Priority 1 — Fix SKILL.md

**Update description in frontmatter** to be pushy with trigger keywords:
```yaml
description: "Next.js App Router best practices, patterns, and decisions. Use when user asks about Next.js, App Router, Server Components, Client Components, data fetching, RSC, routing, metadata, caching, or server actions."
```

**Add pattern label** after the h1:
```markdown
**Pattern: Tool Wrapper**
```

**Add USE FOR: section** (after pattern label):
```markdown
## USE FOR
- "should this be a server or client component?"
- "how do I fetch data in Next.js App Router?"
- "Next.js routing patterns"
- "server actions best practices"
- "Next.js caching strategy"
- "optimize my Next.js app"
- "Next.js metadata setup"
- "App Router file conventions"
```

**Add REQUIRES: section:**
```markdown
## REQUIRES
- Next.js 13+ with App Router enabled
- React 18+
```

**Add Prerequisites section:**
```markdown
## Prerequisites
- Project uses Next.js App Router (not Pages Router)
- `app/` directory exists in project root
```

**Add Quick Start section:**
```markdown
## Quick Start
1. Default to **Server Components** — add `'use client'` only when needed
2. Fetch data in Server Components, pass as props to Client Components
3. Use `loading.tsx` + `error.tsx` for every significant route
4. Prefer `generateMetadata` for dynamic pages, static export for fixed pages
```

**Expand When to Use section:**
```markdown
## When to Use
Load this skill whenever the user is working on a Next.js App Router project and needs guidance on:
- Component type decisions (server vs client)
- Data fetching strategy
- Routing and file conventions
- Performance optimization
- Caching and revalidation
- SEO and metadata

Trigger keywords: Next.js, App Router, Server Components, RSC, server actions, ISR.
```

**Add Example section** with a real worked scenario:
```markdown
## Example

**User:** "I need to show a user's dashboard with live data and interactive charts."

**Answer:**
```
app/dashboard/
├── page.tsx          ← Server Component: fetch user data
├── layout.tsx        ← Server Component: shared dashboard nav
├── loading.tsx       ← Loading skeleton
└── components/
    ├── StatsCard.tsx  ← Server Component: display stats
    └── ChartWidget.tsx← Client Component ('use client'): interactive chart
```

page.tsx fetches data server-side, passes to StatsCard (server) and ChartWidget (client).
```
```

**Add Error Handling table:**
```markdown
## Error Handling

| Error | Cause | Fix |
|-------|-------|-----|
| "useState in Server Component" | Missing 'use client' | Add `'use client'` directive at top of file |
| Hydration mismatch | Server/client render difference | Check for browser-only APIs in server code |
| Stale data shown | Over-aggressive caching | Use `revalidate: 0` or `no-store` for dynamic data |
| Build error in Server Action | Missing 'use server' | Add `'use server'` directive to action file/function |
| Large client bundle | Too many Client Components | Move logic to Server Components, use dynamic imports |
```

### Priority 2 — Create scripts/

This is a knowledge/reference skill — no executable script is strictly needed. However, create a helper that validates a Next.js project structure:

```bash
mkdir -p ~/.openclaw/skills/nextjs-best-practices/scripts
```

Create `scripts/check-structure.sh`:
```bash
#!/bin/bash
# Check if current directory is a valid Next.js App Router project
# Usage: ./scripts/check-structure.sh [project-dir]
DIR="${1:-.}"

echo "=== Next.js App Router Structure Check ==="
echo ""

[ -d "$DIR/app" ] && echo "✅ app/ directory found" || echo "❌ app/ directory missing"
[ -f "$DIR/next.config.js" ] || [ -f "$DIR/next.config.ts" ] && echo "✅ next.config found" || echo "⚠️  next.config not found"
[ -f "$DIR/package.json" ] && echo "✅ package.json found" || echo "❌ package.json missing"

echo ""
echo "=== Key Files ==="
for f in app/layout.tsx app/page.tsx app/globals.css; do
  [ -f "$DIR/$f" ] && echo "✅ $f" || echo "⚠️  $f missing"
done
```

```bash
chmod +x ~/.openclaw/skills/nextjs-best-practices/scripts/check-structure.sh
```

### Priority 3 — Create _meta.json

```json
{
  "name": "nextjs-best-practices",
  "version": "1.0.0",
  "author": "King",
  "pattern": "Tool Wrapper",
  "emoji": "⚡",
  "created": "2026-03-25",
  "requires": {
    "bins": [],
    "modules": [],
    "runtime": ["next@13+", "react@18+"]
  },
  "tags": ["nextjs", "react", "app-router", "server-components", "web", "frontend"]
}
```

### Priority 4 — Create evals/evals.json

```bash
mkdir -p ~/.openclaw/skills/nextjs-best-practices/evals
```

```json
{
  "skill_name": "nextjs-best-practices",
  "pattern": "Tool Wrapper",
  "evals": [
    {
      "id": 1,
      "prompt": "Should my product listing page be a server or client component?",
      "input": "Page fetches products from DB, displays static list, has no user interaction",
      "expected": "Server Component — fetches data server-side, no useState/useEffect needed"
    },
    {
      "id": 2,
      "prompt": "How should I handle data fetching for a user dashboard that needs live updates?",
      "input": "Dashboard with user-specific data that changes frequently",
      "expected": "Server Component with no-store fetch + client component children for interactive parts"
    },
    {
      "id": 3,
      "prompt": "What's the right way to handle form submission in Next.js App Router?",
      "input": "Contact form that saves to database",
      "expected": "Server Action with 'use server', validate input with Zod, return typed response"
    }
  ]
}
```

### Priority 5 — Create README.md

Cover:
- Why Tool Wrapper (reference knowledge pulled on demand, not a process)
- Scope: App Router only, not Pages Router
- How to extend (add more sections for edge cases, middleware, auth)
- Limitations (doesn't cover Next.js Pages Router; doesn't cover deployment)
- Related skills: any React, TypeScript, or web performance skills

## Final Checklist

- [ ] SKILL.md updated: description trigger keywords, pattern label, USE FOR, REQUIRES, Prerequisites, Quick Start, When to Use expanded, Example added, Error Handling table
- [ ] Pattern labeled as **Tool Wrapper**
- [ ] scripts/check-structure.sh created and executable
- [ ] evals/evals.json has ≥ 3 test cases
- [ ] _meta.json created
- [ ] README.md created
- [ ] `openclaw config validate` passes
