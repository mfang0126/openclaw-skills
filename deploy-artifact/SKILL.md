---
name: deploy-artifact
description: |
  Deploy local files (HTML/PDF/MD/images) to Vercel artifacts project and return a public URL.
  One command, instant shareable link.

  USE FOR:
  - "发布这个文件", "deploy this", "给我个链接"
  - "share this file", "upload to vercel", "host this HTML"
  - "get a public link", "make this accessible"
  - User wants a shareable URL for any local file
  - Sharing reports, dashboards, documents with external parties
  - Deploying generated HTML/charts/visualizations

  REPLACES: Manual Vercel dashboard uploads

  REQUIRES:
  - curl, jq, sha1sum (CLI tools)
  - ~/.vercel-tokens/accounts.json with valid Vercel token
metadata:
  openclaw:
    emoji: "🚀"
    requires:
      bins: ["curl", "jq", "sha1sum"]
---

# Deploy Artifact

**Pattern: Tool Wrapper** (Google ADK) — File → SHA1 Hash → Vercel Files API → Create Deployment → Poll Ready → Return URL

## When to Use

Use when user wants to **share a local file via public URL**. Typical triggers:
- Generated an HTML report/chart and needs to share it
- Created a PDF/document that needs a link
- Built a static page and wants instant hosting
- Any "deploy", "publish", "share link", "上传", "发布" request for local files

**Don't use when:** User wants full app deployment (use `vercel` CLI directly), or needs custom domain setup.

## Prerequisites

1. Vercel token file exists: `~/.vercel-tokens/accounts.json`
2. Token has access to team `team_FnumWtT5mhMnmoKq9OP7gCVm`
3. `artifacts` project exists in Vercel account
4. CLI tools: `curl`, `jq`, `sha1sum` on PATH

## Quick Start

```bash
# Deploy a single file
~/.openclaw/skills/deploy-artifact/scripts/deploy.sh /path/to/file.html

# Deploy multiple files
~/.openclaw/skills/deploy-artifact/scripts/deploy.sh file1.html file2.pdf
```

## Instructions

1. Read Vercel token from `~/.vercel-tokens/accounts.json` (key: `lighttune` or `yuyanceshi`)
2. Calculate SHA1 hash for each input file
3. Upload files to Vercel Files API
4. Create a deployment targeting the `artifacts` project
5. Poll deployment status until ready (timeout: 5 min)
6. Return public URLs

**Configuration (hardcoded):**
- Team ID: `team_FnumWtT5mhMnmoKq9OP7gCVm`
- Project: `artifacts`
- Base URL: `https://artifacts-pi.vercel.app`

## Examples

### Example 1: Deploy an HTML report

**User says:** "帮我把这个报告发布一下，给我个链接"

**Steps:**
```bash
~/.openclaw/skills/deploy-artifact/scripts/deploy.sh ./report.html
```

**Output:**
```json
{
  "success": true,
  "deploymentId": "dpl_abc123",
  "urls": [
    "https://artifacts-pi.vercel.app/report.html"
  ]
}
```

**Reply:** "已部署 ✅ 链接：https://artifacts-pi.vercel.app/report.html"

### Example 2: Deploy multiple files

**User says:** "Deploy these charts and the index page"

```bash
~/.openclaw/skills/deploy-artifact/scripts/deploy.sh index.html chart1.png chart2.png
```

## Supported File Types

| Type | Extensions |
|------|-----------|
| HTML | .html, .htm |
| PDF | .pdf |
| Markdown | .md |
| Text | .txt |
| Images | .png, .jpg, .jpeg, .gif, .webp, .svg |

## Error Handling

| Error | Cause | Solution |
|-------|-------|----------|
| Token file missing | `~/.vercel-tokens/accounts.json` not found | Create file with valid Vercel token |
| Token invalid/expired | 401 from Vercel API | Refresh token in accounts.json |
| File not found | Input path doesn't exist | Check file path |
| Upload failed | Network issue or Vercel API error | Retry; check network |
| Deployment timeout | Deployment takes > 5 min | Check Vercel dashboard with deployment ID |
| File too large | > 100MB | Split file or compress |

## Notes

- Files deploy to production immediately
- Previous deployments remain accessible until new one is ready
- The `artifacts` project must already exist in the Vercel account
