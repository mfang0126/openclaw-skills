# UPGRADE_PLAN — typescript-advanced-types

> Generated: 2026-03-25 | SOP Version: 1.0

---

## Pattern Classification

**Pattern: Tool Wrapper**

Rationale: This skill loads TypeScript type-system knowledge on demand. It is a reference/knowledge skill — no fixed pipeline, no transformation process. The user queries it to get guidance, patterns, and examples. → "Load knowledge on demand" = Tool Wrapper.

---

## Current State Audit

### Files Present
| File | Present | Notes |
|------|---------|-------|
| SKILL.md | ✅ | Exists, very detailed — but missing SOP sections |
| README.md | ❌ | Missing |
| _meta.json | ❌ | Missing |
| evals/evals.json | ❌ | Missing (no evals/ dir) |
| scripts/ | ❌ | Missing (no scripts — acceptable for Tool Wrapper, but verify) |

**Missing files: 3 required (README.md, _meta.json, evals/evals.json)**

---

## SKILL.md Gaps

| SOP Requirement | Status | Detail |
|----------------|--------|--------|
| `name` + `description` in frontmatter | ✅ | Present |
| Description is **pushy** with trigger keywords | ⚠️ | Description is good but could be more keyword-dense |
| `USE FOR:` section with example phrases | ❌ | Missing |
| `REPLACES:` section | ➖ | N/A (no prior skill to replace) |
| `REQUIRES:` dependencies | ❌ | Missing (no deps listed) |
| Pattern label (e.g. `**Pattern: Tool Wrapper**`) | ❌ | Missing |
| `When to Use` section | ✅ | Present as "When to Use This Skill" |
| `Prerequisites` section | ❌ | Missing |
| `Quick Start` section | ❌ | Missing |
| `Instructions` or `Pipeline` | ✅ | Covered by "Core Concepts" + "Advanced Patterns" |
| At least 1 complete `Example` | ✅ | Many examples present |
| `Error Handling` table | ❌ | "Common Pitfalls" exists but not in table format |
| < 500 lines total | ⚠️ | Likely over 500 lines — needs audit/trim |

---

## Upgrade Tasks

### Priority 1 — SKILL.md Fixes
- [ ] Add `**Pattern: Tool Wrapper**` near top of SKILL.md
- [ ] Add `USE FOR:` section with 5–8 example trigger phrases
- [ ] Add `REQUIRES:` section (e.g., TypeScript compiler, tsconfig)
- [ ] Add `Prerequisites` section (Node.js, TypeScript installed)
- [ ] Add `Quick Start` section — most common one-liner usage
- [ ] Reformat "Common Pitfalls" into `Error Handling` table with columns: Error | Cause | Fix
- [ ] Audit line count — trim to < 500 lines (currently likely 400–600)
- [ ] Make description more keyword-dense (add: "generics, conditional types, mapped types, template literal types, infer, type guards, utility types")

### Priority 2 — Create Missing Files
- [ ] Create `_meta.json` with pattern, tags, version info
- [ ] Create `evals/evals.json` with ≥ 3 type-challenge test cases
- [ ] Create `README.md` with design decisions and limitations

### Priority 3 — Scripts (Optional for Tool Wrapper)
- [ ] Consider a `scripts/lint-types.sh` that runs `tsc --noEmit` to validate types
- [ ] Or skip scripts if purely a reference skill

---

## _meta.json Template

```json
{
  "name": "typescript-advanced-types",
  "version": "1.0.0",
  "author": "King",
  "pattern": "Tool Wrapper",
  "emoji": "🔷",
  "created": "2026-03-25",
  "requires": {
    "bins": ["node", "tsc"],
    "modules": []
  },
  "tags": ["typescript", "types", "generics", "developer-tools", "reference"]
}
```

---

## evals/evals.json Template

```json
{
  "skill_name": "typescript-advanced-types",
  "pattern": "Tool Wrapper",
  "evals": [
    {
      "id": 1,
      "prompt": "How do I create a DeepReadonly type in TypeScript?",
      "input": "nested config object with mutable properties",
      "expected": "Recursive mapped type using readonly modifier on nested objects"
    },
    {
      "id": 2,
      "prompt": "Implement a type-safe event emitter",
      "input": "EventMap with user:created, user:updated events",
      "expected": "TypedEventEmitter class with generic K extends keyof T"
    },
    {
      "id": 3,
      "prompt": "Extract the return type of an async function",
      "input": "async function fetchUser(): Promise<User>",
      "expected": "Awaited<ReturnType<typeof fetchUser>> = User"
    }
  ]
}
```

---

## Summary

| Item | Count |
|------|-------|
| Missing files | 3 (README.md, _meta.json, evals/evals.json) |
| SKILL.md gaps | 6 sections missing or malformed |
| Estimated effort | ~45 min |
