#!/bin/bash
# verify-bundled.sh — 对比 bundled 目录和 checksum 基线
# 用法: bash ~/.openclaw/skills/verify-bundled.sh

BASELINE="$HOME/.openclaw/skills/bundled-baseline.sha256"
BUNDLED_DIR="/opt/homebrew/lib/node_modules/openclaw/skills"

if [ ! -f "$BASELINE" ]; then
  echo "❌ 基线文件不存在: $BASELINE"
  echo "生成命令: cd $BUNDLED_DIR && find . -name 'SKILL.md' -type f | sort | while read f; do shasum -a 256 \"\$f\"; done > $BASELINE"
  exit 1
fi

if [ ! -d "$BUNDLED_DIR" ]; then
  echo "❌ bundled 目录不存在: $BUNDLED_DIR"
  exit 1
fi

cd "$BUNDLED_DIR"

echo "━━━ Bundled 文件验证 ━━━"
echo ""

# Check baseline files
MISSING=0
CHANGED=0
OK=0
EXTRA=0

while IFS= read -r line; do
  hash=$(echo "$line" | awk '{print $1}')
  file=$(echo "$line" | awk '{print $2}')
  
  if [ ! -f "$file" ]; then
    echo "❌ 缺失: $file"
    MISSING=$((MISSING + 1))
    continue
  fi
  
  current=$(shasum -a 256 "$file" | awk '{print $1}')
  if [ "$current" != "$hash" ]; then
    echo "❌ 变更: $file"
    CHANGED=$((CHANGED + 1))
  else
    OK=$((OK + 1))
  fi
done < "$BASELINE"

# Check for extra files not in baseline
while IFS= read -r file; do
  relpath="./$(echo "$file" | sed 's|^\./||')"
  if ! grep -q "  $relpath$" "$BASELINE" 2>/dev/null; then
    echo "⚠️ 新增: $relpath"
    EXTRA=$((EXTRA + 1))
  fi
done < <(find . -name "SKILL.md" -type f | sort)

echo ""
echo "━━━ 结果 ━━━"
echo "✅ 一致: $OK"
echo "❌ 变更: $CHANGED"
echo "❌ 缺失: $MISSING"
echo "⚠️ 新增: $EXTRA"

if [ $CHANGED -eq 0 ] && [ $MISSING -eq 0 ]; then
  echo ""
  echo "✅ 全部通过"
fi
