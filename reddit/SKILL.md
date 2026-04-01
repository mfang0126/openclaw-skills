---
name: reddit
description: Search Reddit, read posts and comments, browse subreddits. Covers full Reddit read access — search, posts, comments, subreddit info. Triggers on any Reddit mention or when user wants to check community discussions.
user-invocable: true
triggers: ["reddit", "search reddit", "reddit search", "r/", "reddit cli", "reddit discussion", "reddit community", "check reddit", "搜reddit", "reddit上", "reddit 说"]
metadata: {"clawdbot":{"emoji":"🔍","requires":{"bins":["node"],"env":["REDDIT_SESSION"]},"primaryEnv":"REDDIT_SESSION"}}
---

## USE FOR
- "search reddit for..." / "搜 Reddit" / "reddit 上怎么说"
- "what does r/AI_Agents think about..."
- "check reddit discussions on..."
- "read this reddit post" / "看看这个帖子"
- 验证内容选题、社区需求、技术讨论

## When to Use
- User mentions Reddit or asks about community discussions
- Need to validate ideas against real user feedback
- Reading full post content + comments (web_fetch can't do this)

**Don't use when:** User just wants general web search — prefer Brave/Grok.

## Prerequisites
- `REDDIT_SESSION` env var set (reddit_session cookie)
- Optional: `TOKEN_V2` for authenticated requests
- Check: `node {baseDir}/scripts/reddit-cli.js check`

## Commands

```bash
# Search Reddit
node {baseDir}/scripts/reddit-cli.js search "<query>" [--sub <subreddit>]

# Get posts from a subreddit
node {baseDir}/scripts/reddit-cli.js posts <subreddit> [limit] [sort]

# Read full post + comments
node {baseDir}/scripts/reddit-cli.js post <url-or-id>

# Subreddit info
node {baseDir}/scripts/reddit-cli.js info <subreddit>

# Check if cookies work
node {baseDir}/scripts/reddit-cli.js check
```

### Sort options
`hot` (default), `new`, `top`, `rising`, `relevance`

### Examples
```bash
# Search for AI agent discussions
node {baseDir}/scripts/reddit-cli.js search "subagent management" --sub AI_Agents

# Get top 5 posts from LocalLLaMA
node {baseDir}/scripts/reddit-cli.js posts LocalLLaMA 5 top

# Read a specific post
node {baseDir}/scripts/reddit-cli.js post 1rkotlf

# Check subreddit stats
node {baseDir}/scripts/reddit-cli.js info ClaudeAI
```

## Error Handling
| Error | Cause | Solution |
|-------|-------|----------|
| `REDDIT_SESSION not found` | Cookie not set | Export env var from browser cookies |
| `401/403` | Cookie expired | Get new cookie from DevTools → reddit.com |
| Empty results | Query too specific | Broaden search terms |
| Rate limit | Too many requests | Wait 1-2 min between batches |

## Notes
- Read-only — cannot post/comment/vote (by design, safety)
- Cookie auth lasts ~13 months for reddit_session
- Respects Reddit rate limits automatically
- Returns structured output with scores, comment counts, URLs
