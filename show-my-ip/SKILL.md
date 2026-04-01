---
user-invocable: false
name: show-my-ip
source: clawhub.ai/show-my-ip (v1.0.0) — show-my-ip
description: "Show the current public IP address of the server. Use when asked: what's my IP, show public IP, what IP am I coming from, check VPN, server outbound IP, firewall allowlist IP."
requires:
  bins: ["curl"]
  modules: []
---

# Show My IP

**Pattern: Tool Wrapper** (Google ADK) — Wraps `ifconfig.me` via `curl`. One-shot invocation, fixed-format output.

## USE FOR

- "what's my IP?"
- "show my public IP address"
- "what IP am I coming from?"
- "check if VPN is active" (compare expected vs actual IP)
- "what's my server's outbound IP for firewall rules?"
- "am I behind a proxy?"

Quickly check the public IP address of the machine running your agent. Useful for debugging network issues, verifying VPN connections, confirming server identity, or setting up firewall rules.

## Usage

```bash
bash scripts/get-ip.sh
```

## Output

Returns the public **IPv4** address (and **IPv6** if available) by querying `ifconfig.me`.

Example output:
```
=== Public IP ===
IPv4: 203.0.113.42
IPv6: 2001:db8::1
```

## When to Use

- User asks "what's my IP?" or "show my public IP"
- Verifying outbound IP for allowlisting
- Checking if a VPN or proxy is active
- Confirming server network identity

**Don't use when:** User needs internal/LAN IP (use `ifconfig` or `ip addr`), or needs DNS resolution (use `dig` or `nslookup`).

## Prerequisites

- `curl` (pre-installed on most systems; `brew install curl` or `apt install curl` if missing)
- Internet access

## Error Handling

| Error | Cause | Fix |
|-------|-------|-----|
| `curl: command not found` | curl not installed | `brew install curl` or `apt install curl` |
| Empty output | No internet access | Check network; verify `curl ifconfig.me` works manually |
| Timeout / no response | `ifconfig.me` unreachable | Try fallback: `curl icanhazip.com` or `curl api.ipify.org` |
| IPv6 address returned | IPv4 not available on network | Normal on IPv6-only networks |
| `000` HTTP code | DNS resolution failed | Check DNS settings (`ping 8.8.8.8`) |
