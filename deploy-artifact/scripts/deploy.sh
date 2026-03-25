#!/bin/bash

# Centralized artifact deploy script
# Usage:
#   deploy.sh              → deploy all files in ARTIFACTS/
#   deploy.sh --all        → same as above
#   deploy.sh <file> ...   → copy file(s) to ARTIFACTS/, update manifest, deploy all

set -e

# ── Config ────────────────────────────────────────────────────────────────────
ARTIFACTS_DIR="$HOME/.openclaw/workspace/ARTIFACTS"
TOKEN_FILE="$HOME/.vercel-tokens/accounts.json"
TEAM_ID="team_FnumWtT5mhMnmoKq9OP7gCVm"
PROJECT_NAME="artifacts"
BASE_URL="https://artifacts-pi.vercel.app"

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# ── Read token ────────────────────────────────────────────────────────────────
if [ ! -f "$TOKEN_FILE" ]; then
    echo -e "${RED}Error: Token file not found at $TOKEN_FILE${NC}" >&2
    exit 1
fi
TOKEN=$(jq -r '.lighttune // .yuyanceshi' "$TOKEN_FILE" 2>/dev/null)
if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
    echo -e "${RED}Error: Could not read token from $TOKEN_FILE${NC}" >&2
    exit 1
fi

# ── Handle new file args ───────────────────────────────────────────────────────
if [ $# -gt 0 ] && [ "$1" != "--all" ]; then
    echo -e "${CYAN}Adding file(s) to ARTIFACTS/...${NC}"
    mkdir -p "$ARTIFACTS_DIR"

    for filepath in "$@"; do
        if [ ! -f "$filepath" ]; then
            echo -e "${RED}Error: File not found: $filepath${NC}" >&2
            exit 1
        fi
        filename=$(basename "$filepath")
        cp "$filepath" "$ARTIFACTS_DIR/$filename"
        echo -e "  Copied: $filename"

        # Check if already in manifest
        if [ -f "$ARTIFACTS_DIR/manifest.json" ]; then
            exists=$(jq --arg f "$filename" 'map(select(.file == $f)) | length' "$ARTIFACTS_DIR/manifest.json")
        else
            exists=0
        fi

        if [ "$exists" = "0" ]; then
            echo -e "  ${YELLOW}Adding to manifest...${NC}"
            echo -n "  Title [$filename]: "; read -r title
            title="${title:-$filename}"
            echo -n "  Description: "; read -r desc
            echo -n "  Category [Other]: "; read -r category
            category="${category:-Other}"
            echo -n "  Badge: "; read -r badge
            echo -n "  Icon [📄]: "; read -r icon
            icon="${icon:-📄}"

            if [ ! -f "$ARTIFACTS_DIR/manifest.json" ]; then
                echo "[]" > "$ARTIFACTS_DIR/manifest.json"
            fi

            tmp=$(mktemp)
            jq --arg file "$filename" \
               --arg title "$title" \
               --arg desc "$desc" \
               --arg category "$category" \
               --arg badge "$badge" \
               --arg icon "$icon" \
               '. + [{"file":$file,"title":$title,"desc":$desc,"category":$category,"badge":$badge,"icon":$icon}]' \
               "$ARTIFACTS_DIR/manifest.json" > "$tmp" && mv "$tmp" "$ARTIFACTS_DIR/manifest.json"
            echo -e "  ${GREEN}Added to manifest${NC}"
        else
            echo -e "  Already in manifest — skipping prompt"
        fi
    done
fi

# ── Generate index.html from manifest ─────────────────────────────────────────
echo -e "\n${CYAN}Generating index.html from manifest...${NC}"

ARTIFACTS_DIR="$ARTIFACTS_DIR" python3 << 'PYEOF'
import json, os, sys

artifacts_dir = os.environ["ARTIFACTS_DIR"]
manifest_path = os.path.join(artifacts_dir, "manifest.json")

if not os.path.exists(manifest_path):
    print("No manifest.json found — skipping index generation")
    sys.exit(0)

with open(manifest_path) as f:
    items = json.load(f)

# Group by category
categories = {}
for item in items:
    cat = item.get("category", "Other")
    if cat not in categories:
        categories[cat] = []
    categories[cat].append(item)

# Generate cards HTML
sections_html = ""
for cat, files in categories.items():
    cards = ""
    for fi in files:
        cards += f'''
    <a class="card" href="/{fi['file']}">
      <div class="card-icon">{fi.get('icon','📄')}</div>
      <div class="card-body">
        <div class="card-title">{fi['title']}</div>
        <div class="card-desc">{fi.get('desc','')}</div>
      </div>
      <div class="card-badge">{fi.get('badge','')}</div>
      <div class="card-arrow">→</div>
    </a>'''
    sections_html += f'''
  <div class="section-label">{cat}</div>
  <div class="grid">{cards}
  </div>'''

html = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Artifacts</title>
  <script>
  (function(){{
    var now = new Date();
    var mm = String(now.getMonth()+1).padStart(2,'0');
    var dd = String(now.getDate()).padStart(2,'0');
    var today = mm + dd;
    var stored = sessionStorage.getItem('doc_auth');
    if (stored !== today) {{
      document.addEventListener('DOMContentLoaded', function(){{
        document.body.style.display = 'none';
        var overlay = document.createElement('div');
        overlay.style.cssText = 'position:fixed;inset:0;background:#0d1117;display:flex;align-items:center;justify-content:center;z-index:99999;font-family:Inter,sans-serif;';
        overlay.innerHTML = '<div style="background:#161b22;border:1px solid #30363d;border-radius:12px;padding:2rem 2.5rem;text-align:center;min-width:300px"><div style="font-size:1.5rem;margin-bottom:0.5rem">🔒</div><div style="color:#e6edf3;font-size:1.1rem;font-weight:600;margin-bottom:0.25rem">Access Required</div><div style="color:#8b949e;font-size:0.85rem;margin-bottom:1.5rem">Enter today\\'s password (MMDD)</div><input id="pwd-input" type="password" maxlength="4" style="width:100%;padding:0.6rem 1rem;background:#0d1117;border:1px solid #30363d;border-radius:6px;color:#e6edf3;font-size:1.4rem;letter-spacing:0.4em;text-align:center;outline:none;box-sizing:border-box" placeholder="····" /><div id="pwd-err" style="color:#f85149;font-size:0.8rem;margin-top:0.5rem;height:1em"></div><button onclick="checkPwd()" style="margin-top:1rem;width:100%;padding:0.65rem;background:#4f8ef7;border:none;border-radius:6px;color:#fff;font-size:0.95rem;font-weight:600;cursor:pointer">Enter</button></div>';
        document.body.parentNode.insertBefore(overlay, document.body);
        document.body.parentNode.style.display = 'block';
        setTimeout(function(){{ document.getElementById('pwd-input').focus(); }}, 100);
        document.getElementById('pwd-input').addEventListener('keydown', function(e){{ if(e.key==='Enter') checkPwd(); }});
        window.checkPwd = function(){{
          var val = document.getElementById('pwd-input').value;
          if(val === today){{ sessionStorage.setItem('doc_auth', today); overlay.remove(); document.body.style.display = ''; }}
          else {{ document.getElementById('pwd-err').textContent = 'Incorrect. Try again.'; document.getElementById('pwd-input').value = ''; document.getElementById('pwd-input').focus(); }}
        }};
      }});
    }}
  }})();
  </script>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <style>
    * {{ box-sizing: border-box; margin: 0; padding: 0; }}
    body {{ background: #0d1117; color: #e6edf3; font-family: Inter, sans-serif; min-height: 100vh; padding: 2rem; }}
    .header {{ max-width: 800px; margin: 0 auto 2rem; padding-bottom: 1.5rem; border-bottom: 1px solid #21262d; }}
    .header h1 {{ font-size: 1.5rem; font-weight: 700; }}
    .header p {{ color: #8b949e; font-size: 0.9rem; margin-top: 0.4rem; }}
    .section-label {{ max-width: 800px; margin: 1.5rem auto 0.75rem; font-size: 0.75rem; font-weight: 600; color: #6e7681; text-transform: uppercase; letter-spacing: 0.06em; }}
    .grid {{ max-width: 800px; margin: 0 auto; display: grid; gap: 1rem; }}
    .card {{ background: #161b22; border: 1px solid #30363d; border-radius: 10px; padding: 1.25rem 1.5rem; display: flex; align-items: center; gap: 1rem; text-decoration: none; transition: border-color 0.15s; }}
    .card:hover {{ border-color: #4f8ef7; background: #1a2332; }}
    .card-icon {{ font-size: 1.8rem; flex-shrink: 0; }}
    .card-body {{ flex: 1; }}
    .card-title {{ font-size: 1rem; font-weight: 600; color: #e6edf3; }}
    .card-desc {{ font-size: 0.82rem; color: #8b949e; margin-top: 0.25rem; }}
    .card-badge {{ background: #1f6feb22; color: #4f8ef7; border: 1px solid #1f6feb55; border-radius: 4px; font-size: 0.72rem; padding: 0.15rem 0.5rem; font-weight: 500; white-space: nowrap; }}
    .card-arrow {{ color: #4f8ef7; font-size: 1.2rem; flex-shrink: 0; }}
  </style>
</head>
<body>
  <div class="header">
    <h1>📁 Artifacts</h1>
    <p>Internal documents &amp; guides — password: today's date (MMDD)</p>
  </div>
  {sections_html}
</body>
</html>"""

out_path = os.path.join(artifacts_dir, "index.html")
with open(out_path, "w") as f:
    f.write(html)
print(f"index.html generated ({len(html)} bytes)")
PYEOF

# ── Collect all files to deploy ────────────────────────────────────────────────
echo -e "\n${CYAN}Collecting files from ARTIFACTS/...${NC}"
ALL_FILES=()
while IFS= read -r line; do
    ALL_FILES+=("$line")
done < <(find "$ARTIFACTS_DIR" -maxdepth 1 -type f | sort)

if [ ${#ALL_FILES[@]} -eq 0 ]; then
    echo -e "${RED}No files found in $ARTIFACTS_DIR${NC}" >&2
    exit 1
fi

echo -e "  Found ${#ALL_FILES[@]} files:"
for f in "${ALL_FILES[@]}"; do
    echo -e "    → $(basename "$f")"
done

# ── Upload all files ───────────────────────────────────────────────────────────
echo -e "\n${YELLOW}Uploading files...${NC}"

declare -a FILENAMES
declare -a SHAS
declare -a SIZES

for filepath in "${ALL_FILES[@]}"; do
    filename=$(basename "$filepath")
    sha=$(shasum -a 1 "$filepath" | cut -d' ' -f1)
    size=$(stat -f%z "$filepath" 2>/dev/null || stat -c%s "$filepath" 2>/dev/null)

    echo -e "  Uploading: $filename ($size bytes)"

    upload_response=$(curl -s -X POST "https://api.vercel.com/v2/files" \
        -H "Authorization: Bearer $TOKEN" \
        -H "x-vercel-digest: $sha" \
        -H "Content-Type: application/octet-stream" \
        --data-binary "@$filepath" 2>&1)

    if echo "$upload_response" | grep -q '"error"'; then
        echo -e "${RED}    Upload failed: $upload_response${NC}" >&2
        exit 1
    fi

    echo -e "    ${GREEN}✓${NC}"

    FILENAMES+=("$filename")
    SHAS+=("$sha")
    SIZES+=("$size")
done

# ── Create deployment ──────────────────────────────────────────────────────────
echo -e "\n${YELLOW}Creating deployment...${NC}"

files_json="["
for i in "${!FILENAMES[@]}"; do
    [ $i -gt 0 ] && files_json+=","
    files_json+="{\"file\":\"${FILENAMES[$i]}\",\"sha\":\"${SHAS[$i]}\",\"size\":${SIZES[$i]}}"
done
files_json+="]"

deployment_body="{\"name\":\"$PROJECT_NAME\",\"files\":$files_json,\"projectSettings\":{\"framework\":null},\"target\":\"production\"}"

deployment_response=$(curl -s -X POST "https://api.vercel.com/v13/deployments?teamId=$TEAM_ID" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "$deployment_body" 2>&1)

if echo "$deployment_response" | grep -q '"error"'; then
    echo -e "${RED}Deployment creation failed:${NC}" >&2
    echo "$deployment_response" | jq '.' >&2
    exit 1
fi

deployment_id=$(echo "$deployment_response" | jq -r '.id')
if [ -z "$deployment_id" ] || [ "$deployment_id" = "null" ]; then
    echo -e "${RED}Error: Could not extract deployment ID${NC}" >&2
    echo "$deployment_response" | jq '.' >&2
    exit 1
fi

echo -e "  Deployment ID: $deployment_id"

# ── Poll until ready ───────────────────────────────────────────────────────────
echo -e "\n${YELLOW}Waiting for deployment to be ready...${NC}"

max_attempts=60
attempt=0
delay=5

while [ $attempt -lt $max_attempts ]; do
    status_response=$(curl -s "https://api.vercel.com/v13/deployments/$deployment_id?teamId=$TEAM_ID" \
        -H "Authorization: Bearer $TOKEN" 2>&1)
    state=$(echo "$status_response" | jq -r '.readyState')

    if [ "$state" = "READY" ]; then
        echo -e "${GREEN}Deployment ready!${NC}"
        break
    elif [ "$state" = "ERROR" ]; then
        echo -e "${RED}Deployment failed${NC}" >&2
        echo "$status_response" | jq '.' >&2
        exit 1
    fi

    attempt=$((attempt + 1))
    echo "  Attempt $attempt/$max_attempts: state=$state, waiting ${delay}s..."
    sleep $delay
done

# ── Output results ─────────────────────────────────────────────────────────────
echo -e "\n${GREEN}═══ Deployed URLs ═══${NC}"
echo -e "  ${GREEN}→ $BASE_URL${NC}  (index)"
for name in "${FILENAMES[@]}"; do
    [[ "$name" == "index.html" ]] && continue
    echo -e "  ${GREEN}→ $BASE_URL/$name${NC}"
done

urls_json="[\"$BASE_URL\""
for name in "${FILENAMES[@]}"; do
    [[ "$name" == "index.html" ]] && continue
    urls_json+=",\"$BASE_URL/$name\""
done
urls_json+="]"

echo ""
echo "{"
echo "  \"success\": true,"
echo "  \"deploymentId\": \"$deployment_id\","
echo "  \"urls\": $urls_json"
echo "}"
