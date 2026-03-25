# wordpress-cli

> Publish Markdown articles directly to WordPress via REST API. Handles Markdown → HTML conversion, inline CSS styling, draft/publish modes, and title extraction automatically.

## Pattern: Pipeline

Fixed sequential stages: read Markdown → convert to HTML → inject inline CSS → POST to WordPress REST API → return post URL.

## ⚠️ Security Warning: Hardcoded Credentials

**`publish.js` currently has credentials partially hardcoded:**

```javascript
const WP_URL = 'mingfang.tech';           // hardcoded domain
const WP_USER = 'mfang0126@gmail.com';    // hardcoded username
const WP_PASS = process.env.WP_PASS || 'X5YpiLJQAAbZyayYYfEXyw7O';  // falls back to hardcoded
```

The `WP_PASS` has a hardcoded fallback — if `WP_PASS` env var is not set, the real password is used directly from source. This is a security risk if the file is ever shared or checked into version control.

**Recommended fix — migrate to full env vars:**

```bash
# Set in your shell profile (~/.zshrc or ~/.bashrc)
export WP_URL="mingfang.tech"
export WP_USER="mfang0126@gmail.com"
export WP_PASS="X5YpiLJQAAbZyayYYfEXyw7O"
```

Then update `publish.js`:
```javascript
const WP_URL = process.env.WP_URL || 'mingfang.tech';
const WP_USER = process.env.WP_USER;
const WP_PASS = process.env.WP_PASS;
if (!WP_USER || !WP_PASS) { throw new Error('WP_USER and WP_PASS env vars required'); }
```

Or create a `.env` file (add to `.gitignore`):
```
WP_URL=mingfang.tech
WP_USER=mfang0126@gmail.com
WP_PASS=X5YpiLJQAAbZyayYYfEXyw7O
```

## Install

```bash
# Requires Node.js
node --version

# Make CLI executable
chmod +x ~/.openclaw/skills/wordpress-cli/wp-publish
```

## Usage

```bash
# Publish as draft
wp-publish article.md

# Publish directly (live)
wp-publish article.md publish

# Publish with custom title
wp-publish article.md draft "My Custom Title"
```

Or just tell the agent:

> "把这篇文章发到 WordPress"
> "Publish ~/articles/my-post.md to my blog"
> "Post as draft to WordPress"

## Design Decisions

- **Inline CSS**: WordPress themes often strip external stylesheets. Injecting `<style>` inside `<!-- wp:html -->` blocks preserves styling reliably across themes.
- **Node.js, not Python**: Uses built-in `https` module — zero dependencies beyond Node.js itself.
- **Auto-extract title**: Reads H1 from Markdown as the post title; override with third CLI argument.
- **Auto-extract excerpt**: First `> **bold text**` blockquote becomes the excerpt for WordPress SEO/preview.
- **Markdown is basic**: Custom regex parser handles headers, bold, italic, tables, code blocks, lists, blockquotes. No remark/unified dependency.

## Scripts Location

`publish.js` and `wp-publish` are in the skill root (not `scripts/`). This is a structural deviation from SOP — they function correctly from the root but could be moved to `scripts/` in a future cleanup.

## Limitations

- Credential migration to env vars not yet complete — see ⚠️ above.
- Markdown parser is custom regex — complex nested Markdown (e.g., lists inside tables) may not render perfectly.
- No image upload support — images must be hosted elsewhere and referenced by URL.
- No tag/category assignment from CLI (post is created untagged).
- Requires WordPress REST API enabled (default on modern WordPress installs).

## Getting WordPress App Password

1. Log into WordPress admin
2. Users → Your Profile → Application Passwords
3. Add new application password → copy the generated password
4. Set as `WP_PASS` env var (see ⚠️ above)

## Related Skills

- `content-inbox` — Orchestrates content publishing workflow
