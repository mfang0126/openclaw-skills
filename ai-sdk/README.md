# ai-sdk

> Live-sourced AI SDK assistant. Never trusts training data — always reads from `node_modules/ai/docs/` or ai-sdk.dev first.

**Pattern: Tool Wrapper** (Google ADK)

## How It Works

The AI SDK evolves rapidly. This skill enforces a "docs-first" workflow:

```
Developer question
  → Check node_modules/ai/ version
  → [≥6.0.34] grep node_modules/ai/docs/ for current API
  → [older] fetch ai-sdk.dev/api/search-docs?q=...
  → Verify model IDs via curl to AI Gateway
  → Write minimal, type-safe code
  → Run typecheck to confirm
```

**Never generate code from memory.** All APIs, parameter names, and model IDs must be sourced live.

## Version Detection

```bash
# Check installed version
node -e "console.log(require('./node_modules/ai/package.json').version)"

# ai@6.0.34+ → use local docs
ls node_modules/ai/docs/

# Earlier → search online
curl "https://ai-sdk.dev/api/search-docs?q=generateText"
```

## Getting Current Model IDs

```bash
# List all Anthropic models (newest first)
curl -s https://ai-gateway.vercel.sh/v1/models \
  | jq -r '[.data[] | select(.id | startswith("anthropic/")) | .id] | reverse | .[]'
```

Always pick the highest version number available.

## Design Decisions

- **No memory trust**: Training data contains stale API shapes — `parameters` renamed to `inputSchema`, `useChat` redesigned, new agent patterns added every few months
- **Vercel AI Gateway default**: Normalizes provider differences; one API key; model IDs fetched at runtime
- **ToolLoopAgent pattern**: Recommended over manual tool loops — search docs for current signature
- **Minimal options**: Only specify options that differ from defaults; over-specifying causes type errors
- **Typecheck as gate**: Always run `tsc --noEmit` or equivalent after changes

## Common Error Quick-Check

Before digging into source, check `references/common-errors.md` for:
- `parameters` → `inputSchema` rename
- `useChat` breaking changes
- Provider package import changes

## Limitations

- Cannot generate correct code without internet access or `node_modules/ai/` present
- Model ID list changes frequently — cached lists go stale within weeks
- `references/` docs inside the skill are supplementary; always prefer the live `node_modules/ai/docs/` version
- Framework-specific patterns (Next.js, SvelteKit, etc.) vary — must detect from `package.json`

## Related Skills

- `browser-routing` — If building a web UI for AI features, consult routing first
- `agent-browser` — Browser automation that pairs well with AI SDK streaming apps
