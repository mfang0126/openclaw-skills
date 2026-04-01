---
user-invocable: false
name: python-code-review
description: "Reviews Python code for type safety, async patterns, error handling, and common mistakes. Use when: reviewing .py files, checking type hints, async/await usage, exception handling, code review python, check my code, review this function."
requires:
  bins: ["python3"]
  modules: []
---

# Python Code Review

**Pattern: Reviewer** (Google ADK) — Checks existing Python code against defined standards; outputs structured findings report.

## USE FOR

- "review this Python file"
- "check my async code"
- "are my type hints correct?"
- "review exception handling"
- "code review 一下" / "帮我 review 这段代码"
- Before merging a Python PR

## When to Use

- Any `.py` file is submitted for review
- User asks about type hints, async patterns, error handling, or PEP8
- Before merging Python code changes

**Don't use when:** Reviewing non-Python code (JavaScript, Go, Rust — use language-specific review skills). Also skip for trivial scripts under 20 lines.

## Prerequisites

- Python 3.10+ recommended (for `T | None` union syntax)
- Provide the code to review (paste inline or give file path)

## Quick Start

```
Paste your Python code and say:
"review this"          → full review across all categories
"check types only"     → type safety pass only
"check async patterns" → async/await pass only
"check error handling" → exception handling pass only
```

## Review Flow

```
1. Receive code (paste or file path)
2. Load relevant references based on what's in the code:
   - Has async def?   → load references/async-patterns.md
   - Has try/except?  → load references/error-handling.md
   - Has type hints?  → load references/type-safety.md
3. Run through checklist categories
4. Output findings table: Severity | Location | Issue | Fix
5. Summary: X issues found (Y critical, Z warnings)
```

## Quick Reference

| Issue Type | Reference |
|------------|-----------|
| Indentation, line length, whitespace, naming | [references/pep8-style.md](references/pep8-style.md) |
| Missing/wrong type hints, Any usage | [references/type-safety.md](references/type-safety.md) |
| Blocking calls in async, missing await | [references/async-patterns.md](references/async-patterns.md) |
| Bare except, missing context, logging | [references/error-handling.md](references/error-handling.md) |
| Mutable defaults, print statements | [references/common-mistakes.md](references/common-mistakes.md) |

## Review Checklist

### PEP8 Style
- [ ] 4-space indentation (no tabs)
- [ ] Line length ≤79 characters (≤72 for docstrings/comments)
- [ ] Two blank lines around top-level definitions, one within classes
- [ ] Imports grouped: stdlib → third-party → local (blank line between groups)
- [ ] No whitespace inside brackets or before colons/commas
- [ ] Naming: `snake_case` for functions/variables, `CamelCase` for classes, `UPPER_CASE` for constants
- [ ] Inline comments separated by at least two spaces

### Type Safety
- [ ] Type hints on all function parameters and return types
- [ ] No `Any` unless necessary (with comment explaining why)
- [ ] Proper `T | None` syntax (Python 3.10+)

### Async Patterns
- [ ] No blocking calls (`time.sleep`, `requests`) in async functions
- [ ] Proper `await` on all coroutines

### Error Handling
- [ ] No bare `except:` clauses
- [ ] Specific exception types with context
- [ ] `raise ... from` to preserve stack traces

### Common Mistakes
- [ ] No mutable default arguments
- [ ] Using `logger` not `print()` for output
- [ ] f-strings preferred over `.format()` or `%`

## Valid Patterns (Do NOT Flag)

These patterns are intentional and correct - do not report as issues:

- **Type annotation vs type assertion** - Annotations declare types but are not runtime assertions; don't confuse with missing validation
- **Using `Any` when interacting with untyped libraries** - Required when external libraries lack type stubs
- **Empty `__init__.py` files** - Valid for package structure, no code required
- **`noqa` comments** - Valid when linter rule doesn't apply to specific case
- **Using `cast()` after runtime type check** - Correct pattern to inform type checker of narrowed type

## Context-Sensitive Rules

Only flag these issues when the specific conditions apply:

| Issue | Flag ONLY IF |
|-------|--------------|
| Generic exception handling | Specific exception types are available and meaningful |
| Unused variables | Variable lacks `_` prefix AND isn't used in f-strings, logging, or debugging |

## When to Load References

- Reviewing code formatting/style → pep8-style.md
- Reviewing function signatures → type-safety.md
- Reviewing `async def` functions → async-patterns.md
- Reviewing try/except blocks → error-handling.md
- General Python review → common-mistakes.md

## Review Questions

1. Does the code follow PEP8 formatting (indentation, line length, whitespace)?
2. Are imports properly grouped (stdlib → third-party → local)?
3. Do names follow conventions (snake_case, CamelCase, UPPER_CASE)?
4. Are all function signatures fully typed?
5. Are async functions truly non-blocking?
6. Do exceptions include meaningful context?
7. Are there any mutable default arguments?

## Example Review

**Input code:**
```python
def fetch_data(url, params={}):
    try:
        import requests
        r = requests.get(url, params=params)
        return r.json()
    except:
        print("error")
        return None
```

**Review output:**

| Severity | Location | Issue | Fix |
|----------|----------|-------|-----|
| 🔴 Critical | `params={}` | Mutable default argument — shared across calls | Use `params=None` and set inside: `if params is None: params = {}` |
| 🔴 Critical | `except:` | Bare except catches everything including `KeyboardInterrupt` | Use `except requests.RequestException as e:` |
| 🟡 Warning | `fetch_data` | Missing type hints on parameters and return type | `def fetch_data(url: str, params: dict | None = None) -> dict | None:` |
| 🟡 Warning | `print("error")` | Use logger, not print | `logger.error("fetch failed: %s", e)` |
| 🔵 Info | Import inside function | `import requests` inside function body runs on every call | Move to top of module |

**Summary: 4 issues (2 critical, 1 warning, 1 info)**

## Error Handling for Review Process

| Situation | Response |
|-----------|----------|
| No code provided | Ask user to paste code or specify file path |
| File path given but not found | Ask user to paste inline |
| Python 2 syntax detected | Note: skill optimized for Python 3.10+; results may vary |
| Code is already correct | Report "No issues found" — do not invent problems |

## Before Submitting Findings

Load and follow [review-verification-protocol](../review-verification-protocol/SKILL.md) before reporting any issue.
