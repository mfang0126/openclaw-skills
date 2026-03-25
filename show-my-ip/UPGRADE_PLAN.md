# UPGRADE_PLAN: show-my-ip

> Generated: 2026-03-25 | SOP Version: 1.0

## Pattern Classification

**Pattern: Tool Wrapper**
Rationale: Wraps a single external service (`ifconfig.me`) via `curl`. One-shot invocation with a fixed-format output. Simple Tool Wrapper — the skill abstracts the implementation detail of *how* to get the IP.

## Current State

| File | Status |
|------|--------|
| SKILL.md | ✅ Exists (minimal but functional) |
| README.md | ❌ Missing |
| _meta.json | ⚠️ Exists but wrong format (clawhub publish metadata, not SOP format) |
| evals/evals.json | ❌ Missing |
| scripts/get-ip.sh | ✅ Exists |
| .clawhub/origin.json | ✅ (clawhub publish artifact — not SOP required) |

**Missing files: 2** (README.md, evals/evals.json)
**Broken files: 1** (_meta.json needs SOP format)

## SKILL.md Issues

| Check | Status | Notes |
|-------|--------|-------|
| `name` + `description` in frontmatter | ✅ | Present |
| Description is pushy with trigger keywords | ✅ | Trigger phrases included |
| `USE FOR:` section | ❌ | Missing from body (only frontmatter) |
| `REPLACES:` | ➖ | N/A |
| `REQUIRES:` | ❌ | `curl` not in frontmatter |
| Pattern label | ❌ | Missing — add "**Pattern: Tool Wrapper**" |
| `When to Use` section | ✅ | 4 clear use cases listed |
| `Prerequisites` section | ⚠️ | Listed as `Requirements` (minor naming inconsistency) |
| `Quick Start` | ✅ | Usage + output example present |
| `Instructions` | ✅ | Script usage documented |
| At least 1 complete `Example` | ✅ | Output example present |
| `Error Handling` table | ❌ | Missing — no error cases documented |
| < 500 lines | ✅ | Very short (~30 lines) |

## Action Plan

### Priority 1 — Fix SKILL.md

1. Add `**Pattern: Tool Wrapper**` near top of body
2. Add `REQUIRES:` to frontmatter: `curl`
3. Add `USE FOR:` section in body with trigger phrases:
   - "what's my IP?"
   - "show public IP"
   - "what IP am I coming from?"
   - "check if VPN is active"
   - "what's my server's outbound IP?"
4. Rename `Requirements` to `Prerequisites` (SOP naming)
5. Add `Error Handling` table:

| Error | Cause | Fix |
|-------|-------|-----|
| `curl: command not found` | curl not installed | `brew install curl` or `apt install curl` |
| Empty output | No internet access | Check network; verify `curl ifconfig.me` works |
| IPv6 only returned | IPv4 not available | Normal on IPv6-only networks; IPv4 may show as `::` |
| Timeout | `ifconfig.me` unreachable | Try `curl icanhazip.com` as fallback |
| `000` HTTP code | DNS resolution failed | Check DNS settings |

### Priority 2 — Fix _meta.json

Current `_meta.json` is clawhub publish metadata, not SOP format. Replace:
```json
{
  "name": "show-my-ip",
  "version": "1.0.0",
  "author": "King",
  "pattern": "Tool Wrapper",
  "emoji": "🌐",
  "created": "2026-03-25",
  "requires": { "bins": ["curl"], "modules": [] },
  "tags": ["network", "ip", "utility", "debug"]
}
```

### Priority 3 — Create Missing Files

#### `evals/evals.json`
Minimum 3 test cases:
1. `"what's my IP?"` → expects script to run, output contains "IPv4:" with valid IP pattern
2. `"am I on a VPN?"` → expects IP lookup + context note about VPN verification
3. `"show my server's outbound IP for firewall rules"` → expects IP output with copy-friendly format

#### `README.md`
- How it works: delegates to `scripts/get-ip.sh` which calls `ifconfig.me`
- Why `ifconfig.me`: reliable, returns plain-text IP, supports IPv4 and IPv6 queries
- Design decisions: intentionally minimal — one job, done well
- Fallback services: `icanhazip.com`, `api.ipify.org`, `checkip.amazonaws.com`
- Limitations: requires internet access; IP reflects server location (behind NAT may show router IP)
- Related skills: none (standalone utility)

### Priority 4 — Enhance Script (Optional)

Current `scripts/get-ip.sh` should be verified for:
- `set -e` / error handling
- Fallback to secondary service if `ifconfig.me` is down
- Timeout flag: `curl --max-time 10`
- Graceful "No internet" message vs raw curl error

## Estimated Effort

| Task | Effort |
|------|--------|
| Fix SKILL.md | ~15 min |
| Fix _meta.json | ~5 min |
| Write README.md | ~15 min |
| Write evals.json | ~10 min |
| Enhance get-ip.sh (optional) | ~15 min |
| Total | ~60 min |

## Notes

This is the simplest skill of the 6 reviewed. The core functionality works. Upgrade is mostly compliance — adding missing metadata and documentation to meet SOP standards.
