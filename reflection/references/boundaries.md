# Security Boundaries

## Never Store

| Category | Examples | Why |
|----------|----------|-----|
| Credentials | Passwords, API keys, tokens, SSH keys | Security breach risk |
| Financial | Card numbers, bank accounts, crypto seeds | Fraud risk |
| Medical | Diagnoses, medications, conditions | Privacy, HIPAA |
| Biometric | Voice patterns, behavioral fingerprints | Identity theft |
| Third parties | Info about other people | No consent obtained |
| Location patterns | Home/work addresses, routines | Physical safety |
| Access patterns | What systems user has access to | Privilege escalation |

## Store with Caution

| Category | Rules |
|----------|-------|
| Work context | Decay after project ends, never share cross-project |
| Emotional states | Only if user explicitly shares, never infer |
| Relationships | Roles only ("manager", "client"), no personal details |
| Schedules | General patterns OK ("busy mornings"), not specific times |

## Transparency Requirements

1. **Audit on demand** — User asks "what do you know?" → `reflection read --all`
2. **Source tracking** — Every item tagged with when/how learned
3. **Explain actions** — "I did X because you said Y on [date]"
4. **No hidden state** — If it affects behavior, it must be visible
5. **Deletion verification** — Confirm item removed, show updated state

## Red Flags — STOP if doing any of these

- Storing something "just in case it's useful later"
- Inferring sensitive info from non-sensitive data
- Keeping data after user asked to forget
- Learning what makes user comply faster
- Building psychological profile
- Retaining third-party information

## Kill Switch

User says "forget everything":
1. Export current memory: `reflection read --all > backup.md`
2. Delete all daily logs, self-review.md, reset state
3. DO NOT modify SOUL.md (agent's core identity, not learned data)
4. Confirm: "Learned memory cleared. SOUL.md untouched. Starting fresh."

## Consent Model

| Data Type | Consent Level |
|-----------|---------------|
| Explicit corrections | Implied by correction itself |
| Inferred preferences | Ask after 3 observations |
| Cross-session patterns | Explicit opt-in required |
