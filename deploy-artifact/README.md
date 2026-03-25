# deploy-artifact

> Deploy local files to Vercel and get a public URL. One command, permanent CDN link.

## Install

Already installed at `~/.openclaw/skills/deploy-artifact/`. Requires a Vercel token in `~/.vercel-tokens/accounts.json`.

## Usage

```bash
# Deploy a single file
~/.openclaw/skills/deploy-artifact/scripts/deploy.sh /path/to/file.html

# Deploy multiple files
~/.openclaw/skills/deploy-artifact/scripts/deploy.sh file1.html file2.pdf file3.png
```

## How It Works

**Pattern: Tool Wrapper** (Google ADK)

```
Input (file path)
  → Read Vercel token from ~/.vercel-tokens/accounts.json
  → Calculate SHA1 hash for each file
  → Upload to Vercel Files API
  → Create Deployment (references uploaded files)
  → Poll until deployment status = "READY"
  → Return public URL(s)
```

## Design Decisions

- **Why Vercel artifacts project?** Stable URLs (same file = same path), free CDN, zero infrastructure to maintain, and files persist across deployments.
- **Why SHA1-based upload?** Vercel's Files API is content-addressed — identical files skip re-upload, making repeated deploys fast.
- **Why poll for readiness?** Vercel deployments take 5–30 seconds. Returning the URL before it's ready would cause broken links.

## Token Configuration

Token must exist at: `~/.vercel-tokens/accounts.json`

```json
{
  "lighttune": "your-vercel-token-here",
  "yuyanceshi": "your-other-token-here"
}
```

Get a Vercel token: https://vercel.com/account/tokens

## Output

```json
{
  "success": true,
  "deploymentId": "dpl_xxx",
  "urls": [
    "https://artifacts-pi.vercel.app/file.html",
    "https://artifacts-pi.vercel.app/doc.pdf"
  ]
}
```

## Supported File Types

| Type | Extensions |
|------|-----------|
| Web | `.html`, `.htm` |
| Documents | `.pdf`, `.md`, `.txt` |
| Images | `.png`, `.jpg`, `.jpeg`, `.gif`, `.webp`, `.svg` |

## Limitations

- **Static only**: No server-side rendering, no dynamic APIs
- **Max file size**: ~100MB (Vercel limit; large files may timeout)
- **Project must exist**: The `artifacts` project must already be created in the Vercel account
- **No delete**: Once deployed, files remain accessible (intended for sharing)

## Error Handling

| Error | Response |
|-------|----------|
| Token file missing | Clear error + setup instructions, no silent failure |
| File upload fails | Logged error + exit code 1 |
| Deployment fails | Shows API error response |
| Polling timeout (5 min) | Returns deployment ID for manual checking |

## Related Skills

- `html2img` — Convert HTML to PNG image (alternative to deploying)
- `html-screenshot` — Screenshot HTML for preview before deploying
