# skills-watchdog Setup Guide

## Install

```bash
cp -r skills-watchdog ~/.openclaw/skills/
```

---

## First Run

```bash
bash ~/.openclaw/skills/skills-watchdog/scripts/check.sh
```

First run automatically scans all skills in `~/.openclaw/skills/` and saves a baseline. No configuration needed.

Expected output:
```
=== Skills Watchdog ===
[ First Run — Building Baseline ]
  ✓ skill-a: v1.2.0
  ✓ skill-b: abc1234
  ...
Baseline saved. Run again to check for updates.
```

---

## Check for Updates

Run again after first run:
```bash
bash ~/.openclaw/skills/skills-watchdog/scripts/check.sh
```

Output:
```
[PASS]   skill-a: v1.2.0
[UPDATE] skill-b: abc1234 → def5678 (remote has updates)
```

---

## Automate with Cron

Set up a daily check using your agent's cron system. Example (OpenClaw):

```bash
openclaw cron add \
  --name "skills-watchdog" \
  --cron "0 9 * * *" \
  --tz "Your/Timezone" \
  --system-event "Run skills-watchdog: bash ~/.openclaw/skills/skills-watchdog/scripts/check.sh — if any UPDATE found, notify me with the list of updates." \
  --session main
```

Replace `Your/Timezone` with your IANA timezone (e.g. `America/New_York`, `Asia/Shanghai`, `Australia/Sydney`).

---

## Enable GitHub Tracking for a Skill

For skills sourced from a GitHub subdir (e.g. a monorepo), add to that skill's `SKILL.md`:

```yaml
source: https://github.com/owner/repo/tree/main/path/to/skill
```

skills-watchdog will fetch the remote version and compare with local.

---

## Reset Baseline

After updating skills, reset to set the new versions as baseline:

```bash
rm ~/.openclaw/skills/skills-watchdog/baseline.json
bash ~/.openclaw/skills/skills-watchdog/scripts/check.sh
```

---

## Notes

- `baseline.json` is auto-generated and gitignored — it's your local state, not shared
- No API keys required
- Works with any OpenClaw skills directory
