# moonshot-usage

> Check your Moonshot AI (Kimi) API account balance on demand.

## Install

Already installed at `~/.openclaw/skills/moonshot-usage/`. Requires `curl` and `MOONSHOT_API_KEY`.

## Usage

```bash
~/.openclaw/skills/moonshot-usage/scripts/balance.sh
```

Output:
```
Available: $13.99
Cash:      $13.99
Voucher:   $0.00
```

## How It Works

**Pattern: Tool Wrapper** (Google ADK)

```
User asks "check moonshot balance"
  → Load MOONSHOT_API_KEY from environment
  → GET https://api.moonshot.ai/v1/users/me/balance
  → Parse JSON: available_balance, cash_balance, voucher_balance
  → Format and display to user
```

## Design Decisions

- **Tool Wrapper (not Pipeline)**: Single on-demand API call, no multi-step processing
- **Auth via env var**: `MOONSHOT_API_KEY` loaded from openclaw.json — no hardcoded keys
- **Read-only**: Only queries balance, never modifies account state

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

## Authentication

API key must be set in `~/.openclaw/openclaw.json`:
```json
{
  "env": {
    "MOONSHOT_API_KEY": "sk-..."
  }
}
```

## Limitations

- Read-only: shows current balance only, no usage history or per-model breakdown
- Requires active internet connection to `api.moonshot.ai`
- Balance is in USD equivalent; actual currency depends on account region

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/balance.sh` | Query and display Moonshot balance |

## Related Skills

- Any other API credit/balance check skills
