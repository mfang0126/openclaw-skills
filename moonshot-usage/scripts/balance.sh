#!/bin/bash
# Check Moonshot AI API balance
# Requires MOONSHOT_API_KEY in environment

API_KEY="${MOONSHOT_API_KEY:-$(jq -r '.env.MOONSHOT_API_KEY // empty' ~/.openclaw/openclaw.json 2>/dev/null)}"

if [[ -z "$API_KEY" ]]; then
  echo "Error: MOONSHOT_API_KEY not found"
  echo "Set it in ~/.openclaw/openclaw.json or export MOONSHOT_API_KEY=xxx"
  exit 1
fi

RESPONSE=$(curl -s https://api.moonshot.ai/v1/users/me/balance \
  -H "Authorization: Bearer $API_KEY")

if echo "$RESPONSE" | jq -e '.data' > /dev/null 2>&1; then
  AVAILABLE=$(echo "$RESPONSE" | jq -r '.data.available_balance')
  CASH=$(echo "$RESPONSE" | jq -r '.data.cash_balance')
  VOUCHER=$(echo "$RESPONSE" | jq -r '.data.voucher_balance')

  echo "Available: \$${AVAILABLE}"
  echo "Cash: \$${CASH}"
  echo "Voucher: \$${VOUCHER}"
else
  echo "Error: Failed to fetch balance"
  echo "$RESPONSE"
  exit 1
fi
