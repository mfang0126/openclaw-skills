#!/bin/bash
# 新环境一键还原：sync 我们的 skill 到 managed + 安装外部依赖
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
MANAGED_DIR="$HOME/.openclaw/skills"
mkdir -p "$MANAGED_DIR"

echo "=== Syncing our skills to managed ==="
for dir in "$REPO_DIR"/*/; do
  [ -f "$dir/SKILL.md" ] || continue
  skill=$(basename "$dir")
  rsync -a --exclude='state.json' --exclude='config.json' --exclude='.DS_Store' \
    "$dir" "$MANAGED_DIR/$skill/"
  echo "  ✅ $skill"
done

echo ""
echo "=== Installing external skills from ClawHub ==="
for slug in ffmpeg-cli grok-search mermaid-architect seo show-my-ip snap tailscale ui-ux-pro-max-2 vercel; do
  echo "  📦 $slug"
  openclaw skills install "$slug" 2>/dev/null || echo "    ⚠️ failed or already installed"
done

echo ""
echo "Done. Restart OpenClaw session to pick up changes."
echo "Note: 手动第三方 skill (mastra, nano-banana-2 等) 需要单独安装，见 EXTERNAL.md"
