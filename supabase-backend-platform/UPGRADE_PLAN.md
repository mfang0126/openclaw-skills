# UPGRADE_PLAN — supabase-backend-platform

**Pattern**: Tool Wrapper (Reference)
**Reason**: Loads Supabase API/SDK knowledge on demand — covering database, auth, storage, realtime, edge functions. Agent consults it when building Supabase-based backends. No pipeline steps, no code generation workflow — pure knowledge injection.

---

## Gap Analysis (vs SOP Checklist)

| SOP Requirement | Status | Notes |
|-----------------|--------|-------|
| SKILL.md exists & < 500 lines | ❌ **Far exceeds 500 lines** | ~800+ lines; entire reference is inlined |
| Description is pushy with trigger keywords | ⚠️ Adequate but could be pushier | Lists frameworks but misses "auth", "RLS", "realtime", "storage bucket", "Postgres", "Supabase" as explicit triggers |
| Pattern labeled in SKILL.md | ❌ Missing | No `**Pattern: Tool Wrapper**` label |
| scripts/ with working executables | ❌ Missing | No scripts/ directory |
| evals/evals.json ≥ 3 test cases | ❌ Missing | No evals/ directory |
| _meta.json | ❌ Missing | Not present |
| README.md | ❌ Missing | Not present |
| All scripts tested & passing | N/A | Reference-only skill |
| No GUI dependency | ✅ OK | Documentation skill, headless |
| SKILL.md frontmatter has duplicate progressive_disclosure | ⚠️ Structural issue | Both YAML frontmatter AND body have `progressive_disclosure` blocks — redundant/confusing |

**Missing files: 4** (_meta.json, README.md, scripts/, evals/evals.json)
**Additional issues: 3** (Pattern label, SKILL.md massively oversized, duplicate progressive_disclosure)

---

## Upgrade Actions

### P0 — Quick Fixes

1. **Add Pattern label** to top of SKILL.md body:
   ```markdown
   **Pattern: Tool Wrapper**
   ```

2. **Fix duplicate progressive_disclosure** — remove the redundant block inside the body (keep only the frontmatter version, or remove both if not used by the loader).

3. **Improve description** to be pushier with explicit trigger keywords:
   ```
   Supabase backend platform skill. Use when user mentions: Supabase, Postgres database,
   authentication/auth, RLS, row level security, storage buckets, realtime subscriptions,
   edge functions, supabase-js, createClient, signInWithPassword, .from().select(),
   or building full-stack apps with Next.js/React/Vue requiring integrated backend services.
   ```

4. **Create `_meta.json`**:
   ```json
   {
     "name": "supabase-backend-platform",
     "version": "1.0.0",
     "author": "Ming",
     "pattern": "Tool Wrapper",
     "emoji": "🐘",
     "created": "2026-03-25",
     "requires": { "bins": ["node"], "modules": ["@supabase/supabase-js"] },
     "tags": ["supabase", "postgres", "auth", "realtime", "storage", "backend", "nextjs"]
   }
   ```

### P1 — SKILL.md Architecture Refactor (Critical)

5. **Split SKILL.md into focused reference files** — target < 500 lines for SKILL.md itself:
   - Create `references/` directory structure:
     ```
     references/
     ├── database.md        # PostgREST, advanced queries, RPC
     ├── auth.md            # Email/password, OAuth, magic links, phone, state mgmt
     ├── rls.md             # RLS fundamentals, patterns, helper functions
     ├── storage.md         # Upload, download, transforms, storage RLS
     ├── realtime.md        # DB changes, presence, broadcast
     ├── edge-functions.md  # Deno runtime, examples, invocation
     ├── nextjs.md          # App Router, middleware, server/client components, actions
     ├── typescript.md      # Type generation, typed queries
     ├── cli.md             # Local dev, migrations, CLI commands
     └── production.md      # Security, optimization, monitoring, backup
     ```
   - SKILL.md keeps: fundamentals, quick start, client init, decision tree pointing to refs
   - Add section: "When to read which reference file"

### P2 — Critical Missing Files

6. **Create `evals/evals.json`** with ≥ 3 test cases:
   - Eval 1: "Set up Supabase auth with GitHub OAuth in my Next.js app"
   - Eval 2: "Write a RLS policy so users can only read their own rows"
   - Eval 3: "How do I subscribe to realtime updates on the posts table?"

7. **Create `README.md`** covering:
   - What's in each reference file
   - Design decision: why content was split vs inlined
   - Framework compatibility matrix (Next.js App Router vs Pages, React, Vue)
   - Limitations: no offline support, requires Supabase project setup
   - Version tracked: supabase-js v2, Next.js App Router patterns

---

## Summary

| Category | Count |
|----------|-------|
| Missing required files | 4 |
| SKILL.md issues | 3 |
| Total actions | 7 |
