#!/bin/bash
# Skills Watchdog — Generic Version Checker
# Works with any OpenClaw skills directory. No hardcoded versions.
# First run: builds baseline.json automatically.
# Subsequent runs: compares against baseline.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
BASELINE_FILE="$SKILL_DIR/baseline.json"
SKILLS_DIR="${OPENCLAW_SKILLS_DIR:-$HOME/.openclaw/skills}"
DATE=$(date '+%Y-%m-%d %H:%M')
UPDATES=()
PASSES=()
BASELINE_CREATED=false

echo "=== Skills Watchdog ==="
echo "Date: $DATE"
echo "Skills dir: $SKILLS_DIR"
echo ""

# ── Helper: get skill version ────────────────────────────────────

get_skill_version() {
  local skill_dir="$1"
  local version=""

  # Priority 1: _meta.json (clawhub managed)
  if [ -f "$skill_dir/_meta.json" ]; then
    version=$(python3 -c "import json; print(json.load(open('$skill_dir/_meta.json')).get('version',''))" 2>/dev/null)
  fi

  # Priority 2: version: field in SKILL.md
  if [ -z "$version" ] && [ -f "$skill_dir/SKILL.md" ]; then
    version=$(grep "^version:" "$skill_dir/SKILL.md" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
  fi

  # Priority 3: git commit hash
  if [ -z "$version" ] && [ -d "$skill_dir/.git" ]; then
    version=$(cd "$skill_dir" && git log --format='%h' -1 2>/dev/null)
  fi

  echo "${version:-unknown}"
}

# ── Helper: get remote version ───────────────────────────────────

get_remote_version() {
  local skill_dir="$1"
  local remote_version=""

  # Priority 1: explicit source: URL in SKILL.md (monorepo subdir skills)
  if [ -f "$skill_dir/SKILL.md" ] && grep -q "^source:" "$skill_dir/SKILL.md" 2>/dev/null; then
    local remote_ver=$(python3 -c "
import re, urllib.request
skill_md = open('$skill_dir/SKILL.md').read()
m = re.search(r'^source:\s*(https://github\.com/\S+)', skill_md, re.MULTILINE)
if not m: import sys; sys.exit(0)
url = m.group(1)
parts = url.replace('https://github.com/', '').split('/')
repo = '/'.join(parts[:2])
rest = '/'.join(parts[2:])
rest = re.sub(r'^(tree|blob)/[^/]+/', '', rest)
raw_url = f'https://raw.githubusercontent.com/{repo}/main/{rest}/SKILL.md'
try:
    with urllib.request.urlopen(raw_url, timeout=10) as r:
        content = r.read().decode()
    m2 = re.search(r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+)', content, re.MULTILINE)
    if m2: print(m2.group(1))
except: pass
" 2>/dev/null)
    [ -n "$remote_ver" ] && { echo "$remote_ver"; return; }
  fi

  # Priority 2: standalone git repo
  if [ -d "$skill_dir/.git" ]; then
    local remote_url=$(cd "$skill_dir" && git remote get-url origin 2>/dev/null)
    if [ -n "$remote_url" ]; then
      local repo_path=$(echo "$remote_url" | sed 's|https://github.com/||;s|git@github.com:||;s|\.git$||')
      local subdir=$(cd "$skill_dir" && git config core.sparseCheckoutPath 2>/dev/null || echo "")
      local api_url="https://api.github.com/repos/${repo_path}/commits?per_page=1"
      remote_version=$(curl -s --max-time 10 "$api_url" 2>/dev/null | python3 -c "
import json,sys
try:
    d=json.load(sys.stdin)
    if isinstance(d, list) and d:
        print(d[0]['sha'][:7])
    else:
        print('')
except:
    print('')
" 2>/dev/null)
    fi
  fi

  # SKILL.md with explicit source URL (e.g. self-reflection from openclaw/skills subdir)
  if [ -z "$remote_version" ] && [ -f "$skill_dir/SKILL.md" ]; then
    local remote_ver=$(python3 -c "
import re, subprocess, sys

skill_md = open('$skill_dir/SKILL.md').read()
m = re.search(r'^source:\s*(https://github\.com/\S+)', skill_md, re.MULTILINE)
if not m:
    sys.exit(0)

url = m.group(1)
# parse repo and subpath
# e.g. https://github.com/openclaw/skills/tree/main/skills/hopyky/self-reflection
parts = url.replace('https://github.com/', '').split('/')
repo = '/'.join(parts[:2])
# remove tree/main or blob/main
rest = '/'.join(parts[2:])
rest = re.sub(r'^(tree|blob)/[^/]+/', '', rest)
subpath = rest

raw_url = f'https://raw.githubusercontent.com/{repo}/main/{subpath}/SKILL.md'
import urllib.request
try:
    with urllib.request.urlopen(raw_url, timeout=10) as r:
        content = r.read().decode()
    m2 = re.search(r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+)', content, re.MULTILINE)
    if m2:
        print(m2.group(1))
except:
    pass
" 2>/dev/null)
    [ -n "$remote_ver" ] && remote_version="$remote_ver"
  fi

  echo "$remote_version"
}

# ── Build or load baseline ────────────────────────────────────────

if [ ! -f "$BASELINE_FILE" ]; then
  echo "[ First Run — Building Baseline ]"
  echo "Scanning all skills in $SKILLS_DIR..."
  echo ""

  BASELINE="{}"
  for skill_dir in "$SKILLS_DIR"/*/; do
    [ -d "$skill_dir" ] || continue
    skill=$(basename "$skill_dir")
    version=$(get_skill_version "$skill_dir")
    BASELINE=$(echo "$BASELINE" | python3 -c "
import json,sys
d=json.load(sys.stdin)
d['$skill'] = {'version': '$version', 'baseline_date': '$(date +%Y-%m-%d)'}
print(json.dumps(d, indent=2))
" 2>/dev/null)
    echo "  ✓ $skill: $version"
  done

  echo "$BASELINE" > "$BASELINE_FILE"
  echo ""
  echo "Baseline saved to: $BASELINE_FILE"
  echo "Run again to check for updates."
  BASELINE_CREATED=true
fi

# ── Check for updates ─────────────────────────────────────────────

if [ "$BASELINE_CREATED" = false ]; then
  echo "[ Checking for Updates ]"
  echo ""

  for skill_dir in "$SKILLS_DIR"/*/; do
    [ -d "$skill_dir" ] || continue
    skill=$(basename "$skill_dir")

    current=$(get_skill_version "$skill_dir")
    baseline=$(python3 -c "
import json,sys
try:
    d=json.load(open('$BASELINE_FILE'))
    print(d.get('$skill', {}).get('version', 'new'))
except:
    print('new')
" 2>/dev/null)

    # New skill not in baseline
    if [ "$baseline" = "new" ]; then
      UPDATES+=("$skill: NEW (not in baseline)")
      echo "[NEW]    $skill: $current"
      continue
    fi

    # Check remote if available
    remote=$(get_remote_version "$skill_dir")

    if [ -n "$remote" ] && [ "$remote" != "$current" ] && [ "$remote" != "unknown" ]; then
      UPDATES+=("$skill: $current → $remote (remote has updates)")
      echo "[UPDATE] $skill: local=$current remote=$remote"
    elif [ "$current" != "$baseline" ] && [ "$current" != "unknown" ]; then
      UPDATES+=("$skill: $baseline → $current (local version changed)")
      echo "[CHANGED] $skill: $baseline → $current"
    else
      PASSES+=("$skill")
      echo "[PASS]   $skill: $current"
    fi
  done
fi

# ── CLI Tools ─────────────────────────────────────────────────────

echo ""
echo "[ CLI Tools ]"

check_cli() {
  local name="$1"
  local cmd="$2"
  local baseline_key="cli_$name"

  current_ver=$($cmd 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
  [ -z "$current_ver" ] && { echo "[SKIP]   $name (not installed)"; return; }

  if [ "$BASELINE_CREATED" = false ]; then
    baseline_ver=$(python3 -c "
import json,sys
try:
    d=json.load(open('$BASELINE_FILE'))
    print(d.get('$baseline_key', {}).get('version', 'new'))
except:
    print('new')
" 2>/dev/null)

    if [ "$baseline_ver" = "new" ] || [ "$baseline_ver" = "$current_ver" ]; then
      PASSES+=("$name")
      echo "[PASS]   $name: v$current_ver"
    else
      UPDATES+=("$name: v$baseline_ver → v$current_ver")
      echo "[UPDATE] $name: v$current_ver (baseline: v$baseline_ver)"
    fi
  else
    python3 -c "
import json
d=json.load(open('$BASELINE_FILE'))
d['$baseline_key'] = {'version': '$current_ver', 'baseline_date': '$(date +%Y-%m-%d)'}
open('$BASELINE_FILE','w').write(json.dumps(d, indent=2))
" 2>/dev/null
    echo "  ✓ $name: v$current_ver"
  fi
}

check_cli "tavily" "tvly --version"
check_cli "firecrawl" "firecrawl --version"

# ── Summary ───────────────────────────────────────────────────────

if [ "$BASELINE_CREATED" = false ]; then
  echo ""
  echo "════════════════════════════"
  echo "✅ PASS: ${#PASSES[@]}"
  echo "⚠️  UPDATES/NEW: ${#UPDATES[@]}"

  if [ ${#UPDATES[@]} -gt 0 ]; then
    echo ""
    for u in "${UPDATES[@]}"; do
      echo "  • $u"
    done
    echo ""
    echo "To update baseline after reviewing: rm $BASELINE_FILE && run again"
    exit 1
  else
    echo ""
    echo "All skills up to date."
    exit 0
  fi
fi
