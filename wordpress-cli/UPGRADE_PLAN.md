# UPGRADE_PLAN — wordpress-cli

> Generated: 2026-03-25 | SOP Version: 1.0

---

## Pattern Classification

**Pattern: Pipeline**

Rationale: This skill follows a strict sequential process: read Markdown file → convert to HTML → inject inline CSS → POST to WordPress REST API → return result URL. Fixed format input (Markdown) → fixed format output (WordPress post). → Pipeline.

---

## Current State Audit

### Files Present
| File | Present | Notes |
|------|---------|-------|
| SKILL.md | ✅ | Exists — detailed, well-written |
| publish.js | ✅ | Core Node.js publish script |
| wp-publish | ✅ | CLI wrapper shell script |
| README.md | ❌ | Missing |
| _meta.json | ❌ | Missing |
| evals/evals.json | ❌ | Missing (no evals/ dir) |
| scripts/ | ❌ | Missing — scripts are in root instead of `scripts/` |

**Missing files: 3 required (README.md, _meta.json, evals/evals.json)**
**Structural issue: `publish.js` and `wp-publish` should be in `scripts/` per SOP**

---

## SKILL.md Gaps

| SOP Requirement | Status | Detail |
|----------------|--------|--------|
| `name` + `description` in frontmatter | ✅ | Present with name, description, version, author |
| Description is **pushy** with trigger keywords | ❌ | Description is technical, not keyword-dense for triggers. Missing: "publish, post, upload, send to blog, WordPress, 发布" |
| `USE FOR:` section with example phrases | ❌ | Missing |
| `REPLACES:` section | ➖ | N/A |
| `REQUIRES:` dependencies | ⚠️ | Dependencies implied (Node.js, wp-publish) but no formal `REQUIRES:` section |
| Pattern label | ❌ | No `**Pattern: Pipeline**` label |
| `When to Use` section | ❌ | Missing (content jumps straight to features) |
| `Prerequisites` section | ❌ | Missing — Node.js install not documented |
| `Quick Start` section | ⚠️ | "基础用法" covers this but not labeled `Quick Start` |
| `Instructions` / `Pipeline` section | ⚠️ | "用法" section exists but steps aren't numbered pipeline format |
| At least 1 complete `Example` | ✅ | "示例" section with input/output |
| `Error Handling` table | ✅ | "故障排除" section exists but not in table format |
| < 500 lines total | ✅ | Well under 500 lines |

---

## Hardcoded Credentials Issue

⚠️ **Security concern**: SKILL.md shows credentials hardcoded in `publish.js`:
```javascript
const WP_URL = 'mingfang.tech';      // hardcoded domain
const WP_USER = 'your-email@example.com';
const WP_PASS = 'your-app-password';
```
This is a personal skill but credentials should be env-var based for safety. Plan should include env-var migration.

---

## Upgrade Tasks

### Priority 1 — SKILL.md Fixes
- [ ] Add `**Pattern: Pipeline**` label near top
- [ ] Rewrite description frontmatter to be keyword-dense: add "publish, post, upload, 发布, WordPress, blog, article, markdown to wordpress"
- [ ] Add `USE FOR:` section with 5+ natural trigger phrases in both English and Chinese
- [ ] Add `When to Use` section
- [ ] Add formal `REQUIRES:` section: Node.js, wp-publish executable
- [ ] Add `Prerequisites` section: Node.js install, configure credentials
- [ ] Rename "基础用法" → `Quick Start` (or add explicit Quick Start above it)
- [ ] Reformat "故障排除" into SOP-standard `Error Handling` table with columns: Error | Cause | Fix
- [ ] Add explicit Pipeline section showing: Markdown → parse → HTML → CSS inject → POST → return URL

### Priority 2 — Security Fix
- [ ] Migrate credentials from hardcoded in `publish.js` to environment variables or a `.env` file
- [ ] Document how to set: `WP_URL`, `WP_USER`, `WP_PASS` as env vars
- [ ] Add `.env.example` template

### Priority 3 — Create Missing Files
- [ ] Create `_meta.json` with pattern, tags, version
- [ ] Create `evals/evals.json` with ≥ 3 test cases
- [ ] Create `README.md` with design decisions, REST API details, limitations
- [ ] Move `publish.js` and `wp-publish` into `scripts/` directory (or document why they're in root)
- [ ] Verify `wp-publish` is executable: `chmod +x`

---

## _meta.json Template

```json
{
  "name": "wordpress-cli",
  "version": "1.0.0",
  "author": "DeveloperFang",
  "pattern": "Pipeline",
  "emoji": "📝",
  "created": "2026-02-12",
  "requires": {
    "bins": ["node"],
    "modules": []
  },
  "tags": ["wordpress", "publishing", "markdown", "blog", "cms", "cli"]
}
```

---

## USE FOR Section (to add to SKILL.md)

```markdown
## USE FOR

Say things like:
- "把这篇文章发到 WordPress"
- "Publish ~/articles/my-post.md to my blog"
- "Post this as a draft to WordPress"
- "发布为草稿"
- "更新 WordPress 文章 ID 217"
- "Upload this markdown to my blog"
- "Send this to WordPress and publish it"
```

---

## Error Handling Table (reformatted from 故障排除)

| Error | Cause | Fix |
|-------|-------|-----|
| 发布失败 | 网络/认证问题 | Check network; verify app password |
| `401 Unauthorized` | Wrong credentials | Regenerate WordPress app password |
| `403 Forbidden` | REST API disabled | Enable REST API in WordPress settings |
| 格式不对 | Bad Markdown syntax | Check table syntax `\| col \|`, use standard triple backtick |
| `node: command not found` | Node.js not installed | Install Node.js from nodejs.org |
| Script not executable | Missing chmod | `chmod +x ~/.openclaw/skills/wordpress-cli/wp-publish` |

---

## evals/evals.json Template

```json
{
  "skill_name": "wordpress-cli",
  "pattern": "Pipeline",
  "evals": [
    {
      "id": 1,
      "prompt": "把这篇 Markdown 文章发布到 WordPress",
      "input": "article.md with H1, table, code block",
      "expected": "Draft created at WordPress, returns post URL"
    },
    {
      "id": 2,
      "prompt": "Publish ~/articles/review.md directly (not draft)",
      "input": "review.md, status: publish",
      "expected": "Post published, returns live URL"
    },
    {
      "id": 3,
      "prompt": "Post with custom title",
      "input": "article.md draft '自定义标题'",
      "expected": "Draft created with title '自定义标题' overriding H1"
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
| Security issues | 1 (hardcoded credentials in publish.js) |
| Structural issues | 1 (scripts in root, not scripts/ dir) |
| Estimated effort | ~45 min |
