# python-code-review

> AI-powered Python code review against PEP8, type safety, async patterns, and error handling standards.

**Pattern: Reviewer** (Google ADK)

## How It Works

The skill loads relevant reference files based on what's in the code, runs a structured checklist, and outputs a severity-tagged findings table:

```
Code input (paste or file path)
    │
    ├── Detect what's present:
    │   - async def → load references/async-patterns.md
    │   - try/except → load references/error-handling.md
    │   - type hints → load references/type-safety.md
    │   - general → load references/common-mistakes.md + pep8-style.md
    │
    ├── Run checklist categories
    │
    ├── Output findings: Severity | Location | Issue | Fix
    │
    └── Summary: X issues (Y critical, Z warnings)
```

## Why Reference Files?

References are modular — PEP8 rules, async patterns, and type rules can be updated independently without changing SKILL.md. Each reference covers one domain in depth.

| Reference | Covers |
|-----------|--------|
| `references/pep8-style.md` | Indentation, line length, naming, imports |
| `references/type-safety.md` | Type hints, Any usage, union syntax |
| `references/async-patterns.md` | Blocking calls, missing await, async context managers |
| `references/error-handling.md` | Bare except, stack traces, logging |
| `references/common-mistakes.md` | Mutable defaults, print statements, f-strings |

## Output Format

Findings are severity-tagged:

| Severity | Icon | Meaning |
|----------|------|---------|
| Critical | 🔴 | Bug or major code quality issue — must fix |
| Warning | 🟡 | Style violation or potential problem — should fix |
| Info | 🔵 | Minor suggestion — consider fixing |

## Limitations

- AI review, not a linter — use `mypy` and `flake8` for machine-precise checks
- Optimized for Python 3.10+ (`T | None` syntax, `match` statements)
- Cannot execute the code — static analysis only

## Pairing with Static Analysis

For maximum coverage, pair with:
```bash
mypy your_file.py --strict
flake8 your_file.py --max-line-length=79
```

## Related Skills

- `review-verification-protocol` — Verification checklist before submitting findings
