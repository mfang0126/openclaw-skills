---
name: skills-watchdog
description: |
  Automatically checks all installed OpenClaw skills for updates. Compares local versions against upstream sources (GitHub, clawhub, CLI tools). Notifies when updates are available.
  
  Trigger manually: "check skills version" / "skill updates?" / "检查 skill 版本"
  Runs automatically: daily cron, Discord notification on updates found.
  
  Works with any OpenClaw skills directory. Zero config — first run builds the baseline automatically.
user-invocable: true
metadata: {"clawdbot":{"emoji":"👁️"}}
---

# Skills Watchdog

Monitors all your installed skills for version updates. Zero configuration required.

**Design pattern:** Google ADK Reviewer — checklist (baseline.json) is separate from execution (check.sh).

---

## How It Works

1. **First run** → scans all skills in your skills directory, saves versions to `baseline.json`
2. **Every run after** → compares current versions against baseline, reports changes
3. **Updates found** → send Discord notification (when running via cron)

---

## Baseline

Stored in `{skillDir}/baseline.json` — auto-generated on first run. Do not edit manually.

To reset baseline (after you've updated skills):
```bash
rm {skillDir}/baseline.json
bash {skillDir}/scripts/check.sh
```

---

## Supported Source Types

| Source type | Detection method | What's checked |
|-------------|-----------------|----------------|
| **Standalone GitHub repo** | `.git` with remote | Latest commit hash |
| **Monorepo subdir** (e.g. openclaw/skills) | `source:` field in SKILL.md | Version in remote SKILL.md |
| **clawhub / local** | `_meta.json` or `version:` in SKILL.md | Version number |
| **CLI tools** | `tool --version` | Semantic version |

To enable tracking for a skill from a monorepo, add to its SKILL.md:
```yaml
source: https://github.com/owner/repo/tree/main/path/to/skill
```
---

## Usage

### Run manually
```bash
bash {skillDir}/scripts/check.sh
```

### Example output
```
=== Skills Watchdog ===
Date: YYYY-MM-DD HH:MM

[ First Run — Building Baseline ]
  ✓ skill-a: v1.2.0
  ✓ skill-b: abc1234
  ...
Baseline saved. Run again to check for updates.

# Second run:
[PASS]   skill-a: v1.2.0
[UPDATE] skill-b: abc1234 → def5678 (remote has updates)
[NEW]    skill-c: v0.1.0 (not in baseline)
```

### When updates are found
Notify the user. Suggested actions per skill type:
- **Git-tracked skill**: `cd {skillDir} && git pull`
- **Clawhub skill**: `npx clawhub install <skill-name>`
- **CLI tool**: check the tool's official install page

### Cron setup
Add a daily job via your agent's cron system. When updates are found, send a notification to your preferred channel.

### Reset baseline
After updating skills:
```bash
rm {skillDir}/baseline.json
bash {skillDir}/scripts/check.sh
```
