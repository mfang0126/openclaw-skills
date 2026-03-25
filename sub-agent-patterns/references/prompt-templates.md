# Prompt Templates for Sub-Agent Delegation

> Copy-paste ready templates for common delegation patterns.

## Prompt Templates

### Audit/Validation Pattern

```markdown
Deep audit these [N] [items]. For each:

1. Read the [source file] from [path]
2. Verify [versions/data] with [command or API]
3. Check official [docs/source] for accuracy
4. Score 1-10 and note any issues
5. FIX issues found directly in the file

Items to audit:
- [item-1]
- [item-2]
- [item-3]

For each item, create a summary with:
- Score and status (PASS/NEEDS_UPDATE)
- Issues found
- Fixes applied
- Files modified

Working directory: [absolute path]
```

### Bulk Update Pattern

```markdown
Update these [N] [items] to [new standard/format]. For each:

1. Read the current file at [path pattern]
2. Identify what needs changing
3. Apply the update following this pattern:
   [show example of correct format]
4. Verify the change is valid
5. Report what was changed

Items to update:
- [item-1]
- [item-2]
- [item-3]

Output format:
| Item | Status | Changes Made |
|------|--------|--------------|

Working directory: [absolute path]
```

### Research/Comparison Pattern

```markdown
Research these [N] [options/frameworks/tools]. For each:

1. Check official documentation at [URL pattern or search]
2. Find current version and recent changes
3. Identify key features relevant to [use case]
4. Note any gotchas, limitations, or known issues
5. Rate suitability for [specific need] (1-10)

Options to research:
- [option-1]
- [option-2]
- [option-3]

Output format:
## [Option Name]
- **Version**: X.Y.Z
- **Key Features**: ...
- **Limitations**: ...
- **Suitability Score**: X/10
- **Recommendation**: ...
```

---
