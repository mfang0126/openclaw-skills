#!/bin/bash
# html2img — HTML/Markdown → PNG (headless, auto-crop)
# Usage: html2img <input.html|input.md> [output.png]
set -e

INPUT="$1"
OUTPUT="${2:-${1%.*}.png}"

[ -z "$INPUT" ] || [ ! -f "$INPUT" ] && echo "Usage: html2img <file.html|file.md> [output.png]" && exit 1

INPUT="$(cd "$(dirname "$INPUT")" && pwd)/$(basename "$INPUT")"
EXT="${INPUT##*.}"

# If Markdown, convert to styled HTML
if [ "$EXT" = "md" ]; then
  TMPHTML=$(mktemp /tmp/html2img-XXXXXX.html)
  python3 -c "
import re, sys
with open(sys.argv[1]) as f: md = f.read()
html = md
html = re.sub(r'^### (.+)$', r'<h3>\1</h3>', html, flags=re.M)
html = re.sub(r'^## (.+)$', r'<h2>\1</h2>', html, flags=re.M)
html = re.sub(r'^# (.+)$', r'<h1>\1</h1>', html, flags=re.M)
html = re.sub(r'\*\*(.+?)\*\*', r'<strong>\1</strong>', html)
html = re.sub(r'^\- \[x\] (.+)$', r'<li>✅ \1</li>', html, flags=re.M)
html = re.sub(r'^\- \[ \] (.+)$', r'<li>⬜ \1</li>', html, flags=re.M)
html = re.sub(r'^\- (.+)$', r'<li>\1</li>', html, flags=re.M)
html = re.sub(r'\n\n', '</p><p>', html)
page = '''<!DOCTYPE html><html><head><meta charset=\"UTF-8\"><style>
*{margin:0;padding:0;box-sizing:border-box}
body{background:#0d1117;color:#e6edf3;font-family:-apple-system,sans-serif;padding:20px;display:inline-block;max-width:700px}
h1{font-size:1.4em;margin:0.5em 0;color:#58a6ff}h2{font-size:1.2em;margin:0.5em 0;color:#58a6ff}
h3{font-size:1em;margin:0.4em 0;color:#79c0ff}p{margin:0.4em 0;line-height:1.5;font-size:13px}
li{margin:0.2em 0 0.2em 1.5em;font-size:13px;list-style:none}strong{color:#f0f6fc}
code{background:#161b22;padding:2px 5px;border-radius:3px;font-size:12px}
</style></head><body><p>''' + html + '''</p></body></html>'''
with open(sys.argv[2], 'w') as f: f.write(page)
" "$INPUT" "$TMPHTML"
  INPUT="$TMPHTML"
fi

# Start temp server
PORT=$((RANDOM % 10000 + 50000))
python3 -m http.server $PORT -d "$(dirname "$INPUT")" &>/dev/null &
SERVER_PID=$!
trap "kill $SERVER_PID 2>/dev/null; rm -f ${TMPHTML:-}" EXIT
sleep 0.3

# Find playwright-core
PW_CORE=""
for p in \
  "$HOME/Code/ccl/language-arts/node_modules/.pnpm/playwright-core@"*/node_modules/playwright-core \
  "$HOME/node_modules/playwright-core" \
  "/usr/local/lib/node_modules/playwright-core"; do
  resolved=$(ls -d $p 2>/dev/null | tail -1)
  [ -n "$resolved" ] && PW_CORE="$resolved" && break
done
[ -z "$PW_CORE" ] && echo "Error: playwright-core not found" && exit 1

# Headless screenshot with auto-fit
FNAME=$(basename "$INPUT")
node -e "
const { chromium } = require('$PW_CORE');
(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();
  await page.goto('http://localhost:$PORT/$FNAME');
  await page.waitForLoadState('networkidle');
  const size = await page.evaluate(() => {
    document.body.style.display = 'inline-block';
    return { w: document.body.scrollWidth, h: document.body.scrollHeight };
  });
  await page.setViewportSize({ width: size.w, height: size.h });
  await page.screenshot({ path: '$OUTPUT' });
  await browser.close();
})().catch(e => { console.error(e.message); process.exit(1); });
" 2>&1

echo "$OUTPUT"
