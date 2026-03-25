# show-my-ip

> Show the current public IP address of the machine running your agent.

**Pattern: Tool Wrapper** (Google ADK)

## How It Works

Delegates to `scripts/get-ip.sh` which queries `ifconfig.me` via `curl`:

```
User: "what's my IP?"
    │
    └── bash scripts/get-ip.sh
            │
            ├── curl -4 ifconfig.me → IPv4 address
            └── curl -6 ifconfig.me → IPv6 address (if available)
```

Output:
```
=== Public IP ===
IPv4: 203.0.113.42
IPv6: 2001:db8::1
```

## Why `ifconfig.me`?

Reliable, returns plain-text IP (no JSON parsing needed), supports both IPv4 (`-4`) and IPv6 (`-6`) queries explicitly, and has been stable for years.

## Fallback Services

If `ifconfig.me` is unreachable:

```bash
curl icanhazip.com           # plain text, very reliable
curl api.ipify.org           # JSON or plain text
curl checkip.amazonaws.com   # AWS-hosted, very stable
```

## Design Decisions

**Intentionally minimal** — one job, done reliably. No JSON parsing, no API keys, no dependencies beyond `curl` (which ships with every OS).

## Limitations

- Requires internet access
- IP reflects the **server's** outbound IP — behind NAT, this shows the router's IP, not the individual machine
- On IPv6-only networks, IPv4 may not be returned

## Related Skills

Standalone utility — no skill dependencies.
