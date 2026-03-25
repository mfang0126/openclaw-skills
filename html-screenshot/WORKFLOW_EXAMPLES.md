# HTML Screenshot Workflow Examples

记录实际使用案例，方便以后参考。

---

## Case 1: Portfolio 设计预览 (2026-02-07)

### 场景
用户想在 Telegram 看到 Portfolio 技术模块的 HTML 渲染效果。

### 问题
- 无法直接截图（权限限制）
- 尝试了多种方法失败
- 最终找到 agent-browser 解决

### 完整流程

#### Step 1: 生成 HTML 设计文件
```bash
# 生成完整的 HTML 预览页面
cat > portfolio-tech-modules-preview.html << 'EOF'
<!DOCTYPE html>
<html>
...完整 HTML 代码...
</html>
EOF
```

#### Step 2: 截图（使用 agent-browser）
```bash
# 方法 1: 直接命令
agent-browser goto "file:///path/to/portfolio-tech-modules-preview.html"
sleep 2
agent-browser screenshot /tmp/preview.png

# 方法 2: 使用 skill 脚本
~/.openclaw/skills/html-screenshot/scripts/screenshot.sh \
  portfolio-tech-modules-preview.html \
  /tmp/preview.png
```

#### Step 3: 发送到 Telegram
```javascript
// 使用 message tool
message({
  action: "send",
  channel: "telegram",
  target: "6883367773",
  message: "HTML 预览效果",
  media: "/tmp/preview.png"
})
```

### 失败的方法（记录下来避免重复）

❌ **OpenClaw browser tool**
- 错误：需要 Chrome extension 连接
- 原因：profile="openclaw" 需要浏览器实例

❌ **macOS screencapture**
- 错误：需要辅助功能权限
- 原因：安全限制

❌ **Puppeteer**
- 错误：未安装
- 解决：可以用 npx 临时安装，但 agent-browser 更简单

✅ **agent-browser**
- 成功：CLI 工具，无需额外配置
- 优点：轻量级、已安装、命令简单

### 关键学习

1. **agent-browser 是最简单的截图方案**
   - 已安装，开箱即用
   - 支持本地文件和 URL
   - 输出 PNG 格式

2. **file:// URL 需要绝对路径**
   - 相对路径会失败
   - 需要转换：`file://$(pwd)/file.html`

3. **Telegram 发图片用 media 参数**
   - 不是 filePath，是 media
   - 支持本地路径

4. **工作流可以自动化**
   - 生成 HTML → 截图 → 发送
   - 可以封装成一个函数

---

## Case 2: 迭代修改工作流 ⭐ (核心场景)

### 场景
用户让你修改 HTML 的某个部分，期望**自动看到修改后的效果**。

### 完整循环

#### Round 1: 初始版本
```javascript
// 用户："帮我做一个按钮"
// 1. 生成 HTML
Write("button.html", "<button>Click Me</button>")

// 2. 自动截图
exec("~/.openclaw/skills/html-screenshot/scripts/screenshot.sh button.html /tmp/v1.png")

// 3. 自动发送
message({action: "send", media: "/tmp/v1.png", message: "初始版本"})
```

#### Round 2: 用户要求修改
```javascript
// 用户："把按钮改成蓝色，加大一点"
// 1. 修改 HTML
Edit("button.html", 
  oldText: "<button>Click Me</button>",
  newText: "<button style='background: #0066cc; padding: 16px 32px; font-size: 18px;'>Click Me</button>"
)

// 2. 自动截图（不用用户说）
exec("~/.openclaw/skills/html-screenshot/scripts/screenshot.sh button.html /tmp/v2.png")

// 3. 自动发送
message({action: "send", media: "/tmp/v2.png", message: "已修改：蓝色背景 + 加大尺寸"})
```

#### Round 3: 继续优化
```javascript
// 用户："圆角再大一点"
// 1. 修改
Edit("button.html", 
  oldText: "padding: 16px 32px",
  newText: "padding: 16px 32px; border-radius: 12px"
)

// 2. 自动截图
exec("screenshot.sh button.html /tmp/v3.png")

// 3. 自动发送
message({action: "send", media: "/tmp/v3.png", message: "已添加圆角"})
```

### 关键点

1. **不要等用户说"让我看看"**
   - ❌ 修改完说："已经改好了，需要我截图吗？"
   - ✅ 修改完自动截图并发送

2. **每次修改都截图**
   - 即使是小改动（颜色、间距）
   - 用户需要视觉确认

3. **简短说明修改内容**
   - 不只发图，加一句话说明改了什么
   - 例："已修改：蓝色背景 + 加大尺寸"

4. **保持快速迭代**
   - 修改 → 截图 → 发送，整个流程 <5 秒
   - 不拖延，不问多余问题

### 实际对话示例

```
用户：帮我做一个卡片，白色背景，有阴影
我：  [生成 HTML] → [自动截图] → [发送图片："卡片初版"]

用户：阴影再淡一点
我：  [修改代码] → [自动截图] → [发送图片："已调整阴影"]

用户：可以了
我：  ✓ 完成
```

**无需的对话**：
```
❌ 我：已经修改好了，需要我截图给你看吗？
❌ 用户：是的，截图给我看看
❌ 我：[截图] [发送]
```

---

## Case 3: 设计对比（预期场景）

### 场景
用户想对比两个设计版本。

### 流程

```bash
# 截图两个版本
screenshot.sh design-v1.html /tmp/v1.png
screenshot.sh design-v2.html /tmp/v2.png

# 发送对比
message(action="send", message="版本 1", media="/tmp/v1.png")
message(action="send", message="版本 2", media="/tmp/v2.png")
```

---

## Case 3: 响应式测试（预期场景）

### 场景
用户想看不同屏幕尺寸的效果。

### 流程

```bash
# Desktop
screenshot.sh design.html /tmp/desktop.png 1920x1080

# Tablet
screenshot.sh design.html /tmp/tablet.png 768x1024

# Mobile
screenshot.sh design.html /tmp/mobile.png 375x667

# 发送所有截图
for img in /tmp/{desktop,tablet,mobile}.png; do
  message(action="send", media="$img")
done
```

---

## 最佳实践

### 1. 始终使用绝对路径
```bash
# ❌ 错误
screenshot.sh ./file.html output.png

# ✅ 正确
screenshot.sh "$(pwd)/file.html" output.png
```

### 2. 清理临时文件
```bash
# 截图后删除临时文件
screenshot.sh design.html /tmp/preview.png
# ... 发送后 ...
rm /tmp/preview.png
```

### 3. 使用有意义的文件名
```bash
# ❌ 不好
/tmp/screenshot.png

# ✅ 更好
/tmp/portfolio-design-$(date +%Y%m%d-%H%M%S).png
```

### 4. 等待页面加载
```bash
agent-browser goto "file://..."
sleep 1  # 等待渲染完成
agent-browser screenshot output.png
```

---

## 工具对比

| 工具 | 优点 | 缺点 | 推荐场景 |
|------|------|------|----------|
| **agent-browser** | 简单、快速、已安装 | 功能有限 | 日常截图 ⭐ |
| **OpenClaw browser** | 强大、可交互 | 需要 extension | 复杂自动化 |
| **Puppeteer** | 灵活、可编程 | 需要安装 | 高级场景 |
| **Gemini 生成图** | 无需真实渲染 | 不够准确 | 概念设计 |

---

## 下次遇到类似问题

1. **首选 agent-browser**：快速、可靠
2. **文件路径转绝对路径**：避免错误
3. **截图后立即发送**：用户能立即看到
4. **保留截图路径**：方便调试

---

*最后更新：2026-02-07*
*Case 1 验证通过 ✅*
