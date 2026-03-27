---
name: moonshot-usage
description: Check Moonshot AI API balance and usage. Use when user asks for "moonshot balance", "moonshot usage", "查 moonshot 余额", "kimi balance", "how much moonshot credit left", "moonshot 还有多少钱", or "check kimi api balance".
---

# Moonshot Usage

**Pattern: Tool Wrapper** (Google ADK) — Trigger → Call API → Parse → Display

## USE FOR
- "check my moonshot balance"
- "how much moonshot credit do I have left?"
- "moonshot usage"
- "kimi balance"
- "查 moonshot 余额"
- "moonshot 还有多少钱"
- "how much credit left on moonshot?"

## REPLACES
- N/A

## REQUIRES
- `MOONSHOT_API_KEY` environment variable (set in `~/.openclaw/openclaw.json`)
- `curl` available on PATH

## When to Use

Use when user asks about Moonshot AI API credit, balance, spending, or usage.

Trigger keywords: moonshot balance, moonshot usage, kimi balance, 余额, credit left, moonshot credit.

**Don't use when:** User asks about Claude/OpenAI/other provider billing — this is Moonshot-specific only.

## Prerequisites

- Moonshot API key configured in openclaw.json
- Internet access to `api.moonshot.ai`
- `curl` installed: `which curl`

Check your Moonshot AI API account balance.

## Quick Start

```bash
moonshot-balance
```

Output:
```
Available: $13.99
Cash: $13.99
Voucher: $0.00
```

## How it works

Calls Moonshot API: `GET https://api.moonshot.ai/v1/users/me/balance`

Requires `MOONSHOT_API_KEY` environment variable (already in `~/.openclaw/openclaw.json`).

## Script

```bash
scripts/balance.sh
```

## API Response

```json
{
  "code": 0,
  "data": {
    "available_balance": 13.99557,
    "voucher_balance": 0,
    "cash_balance": 13.99557
  }
}
```

## Instructions

1. Load `MOONSHOT_API_KEY` from environment
2. Call `GET https://api.moonshot.ai/v1/users/me/balance`
3. Parse JSON: `data.available_balance`, `data.cash_balance`, `data.voucher_balance`
4. Format and display to user

## Examples

### Example 1: Check balance

**User says:** "查一下我的 Moonshot 余额"

```bash
scripts/balance.sh
```

**Output:**
```
Available: $13.99
Cash: $13.99
Voucher: $0.00
```

**Reply:** "你的 Moonshot 余额还有 $13.99（现金）。"

### Example 2: API call directly

**User says:** "How much moonshot credit do I have left?"

```bash
curl -s https://api.moonshot.ai/v1/users/me/balance \
  -H "Authorization: Bearer $MOONSHOT_API_KEY" | \
  jq '{available: .data.available_balance, cash: .data.cash_balance, voucher: .data.voucher_balance}'
```

**Output:**
```json
{
  "available": 13.99557,
  "cash": 13.99557,
  "voucher": 0
}
```

## Error Handling

| Error | Cause | Fix |
|-------|-------|-----|
| `401 Unauthorized` | Invalid or missing API key | Check `MOONSHOT_API_KEY` in openclaw.json |
| `curl: command not found` | curl not installed | `brew install curl` or `apt install curl` |
| Empty response | Network issue | Check internet connection, retry |
| `code != 0` in response | API error | Check Moonshot status page |

---

## References

### Official Documentation
- **Moonshot AI Platform** — https://platform.moonshot.cn
- **Moonshot API Documentation** — https://platform.moonshot.cn/docs
