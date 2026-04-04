#!/bin/bash
# xhs-publisher 首次安装向导
# 用法: bash setup.sh

set -e

SKILL_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SKILL_DIR/config.json"
STATE_FILE="$SKILL_DIR/state.json"

echo "📕 xhs-publisher 安装向导"
echo "========================"
echo ""

# 1. 创建 config.json
if [ -f "$CONFIG_FILE" ]; then
  echo "✅ config.json 已存在，跳过创建"
else
  echo "📝 第 1 步：创建配置文件"
  echo ""

  read -p "小红书账号名（对应 cookie 文件名）: " ACCOUNT
  read -p "social-auto-upload 安装路径（如 ~/Projects/social-auto-upload）: " SAU_DIR

  # Expand ~
  SAU_DIR="${SAU_DIR/#\~/$HOME}"

  # Validate sau dir
  if [ ! -d "$SAU_DIR" ]; then
    echo "❌ 路径不存在: $SAU_DIR"
    echo "   请先安装 social-auto-upload: https://github.com/dreammis/social-auto-upload"
    exit 1
  fi

  # Validate sau command
  if ! command -v sau &> /dev/null && [ ! -f "$SAU_DIR/.venv/bin/sau" ]; then
    echo "⚠️ 未找到 sau 命令，请先安装: cd $SAU_DIR && uv pip install -e ."
    exit 1
  fi

  cat > "$CONFIG_FILE" << EOF
{
  "account": "$ACCOUNT",
  "sauDir": "$SAU_DIR",
  "limits": {
    "maxPerDay": 5,
    "minIntervalMinutes": 120,
    "randomOffsetMinutes": 30
  }
}
EOF

  echo "✅ config.json 已创建"
fi

echo ""

# 2. 创建 state.json
if [ -f "$STATE_FILE" ]; then
  echo "✅ state.json 已存在，跳过创建"
else
  echo '{"posts":[]}' > "$STATE_FILE"
  echo "✅ state.json 已创建"
fi

echo ""

# 3. 检查 cookie
echo "🍪 第 2 步：检查登录状态"
source "$SAU_DIR/.venv/bin/activate"
ACCOUNT=$(python3 -c "import json; print(json.load(open('$CONFIG_FILE'))['account'])")

if sau xiaohongshu check --account "$ACCOUNT" 2>&1 | grep -q "valid"; then
  echo "✅ 账号 $ACCOUNT cookie 有效"
else
  echo "⚠️ 账号 $ACCOUNT cookie 无效或已过期"
  echo "   请运行以下命令登录："
  echo "   sau xiaohongshu login --account $ACCOUNT"
fi

echo ""
echo "========================"
echo "✅ 安装完成！"
echo ""
echo "配置文件: $CONFIG_FILE"
echo "状态文件: $STATE_FILE"
echo ""
echo "使用方法：告诉 AI '发小红书'，AI 会自动读取配置并执行发布流程。"
