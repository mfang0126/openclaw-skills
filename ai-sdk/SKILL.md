---
user-invocable: false
name: ai-sdk
description: |
  Answer questions about the Vercel AI SDK and help build AI-powered features.

  USE FOR:
  - "AI SDK", "Vercel AI SDK", "how do I use generateText", "add AI to my app"
  - "build an AI agent", "chatbot", "RAG system", "streaming AI responses"
  - "tool calling", "structured output", "embeddings", "useChat hook"
  - "generateText", "streamText", "ToolLoopAgent", "embed", "AI provider setup"
  - "OpenAI integration", "Anthropic setup", "Google AI", "AI SDK 错误"
  - Any question about building AI features with the Vercel AI SDK

  REPLACES: Searching outdated docs; always reads live source code/docs instead

  REQUIRES:
  - Node.js project with `ai` package installed
  - Provider package (e.g., `@ai-sdk/openai`, `@ai-sdk/anthropic`) as needed
---


**Pattern: Tool Wrapper** (Google ADK)

## When to Use
Use when a developer asks how to use the **Vercel AI SDK** — building agents, chatbots, RAG systems, or any AI-powered feature. Works with any supported provider (OpenAI, Anthropic, Google, etc.).

**Don't use when:** The user is asking about a different AI SDK (e.g., LangChain, LlamaIndex) — those have separate docs. This skill is Vercel AI SDK specific.

## Quick Start
```bash
# Install the AI SDK
pnpm add ai @ai-sdk/openai

# Check local docs (ai@6.0.34+)
grep -r "generateText" node_modules/ai/docs/
grep -r "ToolLoopAgent" node_modules/ai/src/
```

## Prerequisites

Before searching docs, check if `node_modules/ai/docs/` exists. If not, install **only** the `ai` package using the project's package manager (e.g., `pnpm add ai`).

Do not install other packages at this stage. Provider packages (e.g., `@ai-sdk/openai`) and client packages (e.g., `@ai-sdk/react`) should be installed later when needed based on user requirements.

## Critical: Do Not Trust Internal Knowledge

Everything you know about the AI SDK is outdated or wrong. Your training data contains obsolete APIs, deprecated patterns, and incorrect usage.

**When working with the AI SDK:**

1. Ensure `ai` package is installed (see Prerequisites)
2. Search `node_modules/ai/docs/` and `node_modules/ai/src/` for current APIs
3. If not found locally, search ai-sdk.dev documentation (instructions below)
4. Never rely on memory - always verify against source code or docs
5. **`useChat` has changed significantly** - check [Common Errors](references/common-errors.md) before writing client code
6. When deciding which model and provider to use (e.g. OpenAI, Anthropic, Gemini), use the Vercel AI Gateway provider unless the user specifies otherwise. See [AI Gateway Reference](references/ai-gateway.md) for usage details.
7. **Always fetch current model IDs** - Never use model IDs from memory. Before writing code that uses a model, run `curl -s https://ai-gateway.vercel.sh/v1/models | jq -r '[.data[] | select(.id | startswith("provider/")) | .id] | reverse | .[]'` (replacing `provider` with the relevant provider like `anthropic`, `openai`, or `google`) to get the full list with newest models first. Use the model with the highest version number (e.g., `claude-sonnet-4-5` over `claude-sonnet-4` over `claude-3-5-sonnet`).
8. Run typecheck after changes to ensure code is correct
9. **Be minimal** - Only specify options that differ from defaults. When unsure of defaults, check docs or source rather than guessing or over-specifying.

If you cannot find documentation to support your answer, state that explicitly.

## Finding Documentation

### ai@6.0.34+

Search bundled docs and source in `node_modules/ai/`:

- **Docs**: `grep "query" node_modules/ai/docs/`
- **Source**: `grep "query" node_modules/ai/src/`

Provider packages include docs at `node_modules/@ai-sdk/<provider>/docs/`.

### Earlier versions

1. Search: `https://ai-sdk.dev/api/search-docs?q=your_query`
2. Fetch `.md` URLs from results (e.g., `https://ai-sdk.dev/docs/agents/building-agents.md`)

## When Typecheck Fails

**Before searching source code**, grep [Common Errors](references/common-errors.md) for the failing property or function name. Many type errors are caused by deprecated APIs documented there.

If not found in common-errors.md:

1. Search `node_modules/ai/src/` and `node_modules/ai/docs/`
2. Search ai-sdk.dev (for earlier versions or if not found locally)

## Building and Consuming Agents

### Creating Agents

Always use the `ToolLoopAgent` pattern. Search `node_modules/ai/docs/` for current agent creation APIs.

**File conventions**: See [type-safe-agents.md](references/type-safe-agents.md) for where to save agents and tools.

**Type Safety**: When consuming agents with `useChat`, always use `InferAgentUIMessage<typeof agent>` for type-safe tool results. See [reference](references/type-safe-agents.md).

### Consuming Agents (Framework-Specific)

Before implementing agent consumption:

1. Check `package.json` to detect the project's framework/stack
2. Search documentation for the framework's quickstart guide
3. Follow the framework-specific patterns for streaming, API routes, and client integration

## Examples

### Example 1: Generate Text with AI SDK
**User says:** "How do I use generateText to call Claude?"
**Steps:**
1. Check local docs: `grep -r "generateText" node_modules/ai/docs/`
2. Get current model ID: `curl -s https://ai-gateway.vercel.sh/v1/models | jq -r '[.data[] | select(.id | startswith("anthropic/")) | .id] | reverse | .[]' | head -5`
3. Write the code based on docs:
```typescript
import { generateText } from 'ai';
import { gateway } from '@ai-sdk/gateway';

const { text } = await generateText({
  model: gateway('anthropic/claude-sonnet-4-5'),
  prompt: 'Write a haiku about coding',
});
console.log(text);
```
**Output:** Working TypeScript code with current model ID
**Reply:** "Here's how to use generateText with Claude via the AI Gateway..."

## Error Handling

| Error | Cause | Solution |
|-------|-------|----------|
| `Property 'parameters' does not exist` | `parameters` renamed to `inputSchema` in newer versions | Check [Common Errors](references/common-errors.md); use `inputSchema` |
| `useChat` type errors | `useChat` API changed significantly | Read [Common Errors](references/common-errors.md) before writing client code |
| `Model not found` | Using a stale/incorrect model ID | Fetch live model list from AI Gateway API |
| `Cannot find module 'ai'` | Package not installed | Run `pnpm add ai` (or npm/yarn equivalent) |
| `Rate limit exceeded` | Too many requests to provider | Implement exponential backoff; check provider quotas |
| TypeScript typecheck fails | Outdated API usage | Search `node_modules/ai/src/` for current signatures |

## References

- [Common Errors](references/common-errors.md) - Renamed parameters reference (parameters → inputSchema, etc.)
- [AI Gateway](references/ai-gateway.md) - Gateway setup and usage
- [Type-Safe Agents with useChat](references/type-safe-agents.md) - End-to-end type safety with InferAgentUIMessage
- [DevTools](references/devtools.md) - Set up local debugging and observability (development only)
