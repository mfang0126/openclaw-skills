#!/bin/bash
# html2img — HTML → PNG (headless, no GUI needed)
# Usage: html2img <input.html> [output.png]
set -e

INPUT="$1"
OUTPUT="${2:-${1%.html}.png}"

[ -z "$INPUT" ] || [ ! -f "$INPUT" ] && echo "Usage: html2img <file.html> [output.png]" && exit 1

INPUT="$(cd "$(dirname "$INPUT")" && pwd)/$(basename "$INPUT")"

PORT=$((RANDOM % 10000 + 50000))
python3 -m http.server $PORT -d "$(dirname "$INPUT")" &>/dev/null &
SERVER_PID=$!
trap "kill $SERVER_PID 2>/dev/null" EXIT
sleep 0.3

PW_CORE="$HOME/Code/ccl/language-arts/node_modules/.pnpm/playwright-core@1.58.2/node_modules/playwright-core"

node -e "
const { chromium } = require('$PW_CORE');
(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();
  await page.goto('http://localhost:$PORT/$(basename "$INPUT")');
  await page.waitForLoadState('networkidle');
  const size = await page.evaluate(() => {
    document.body.style.display = 'inline-block';
    return { w: document.body.scrollWidth, h: document.body.scrollHeight };
  });
  await page.setViewportSize({ width: size.w, height: size.h });
  await page.screenshot({ path: '$OUTPUT' });
  await browser.close();
  console.log('$OUTPUT');
})().catch(e => { console.error(e.message); process.exit(1); });
" 2>&1
