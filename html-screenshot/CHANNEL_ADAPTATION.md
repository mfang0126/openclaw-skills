# Channel Adaptation Guide

**核心理念**：根据用户所在渠道，自动选择最优的截图发送方式。

---

## 🎯 为什么需要渠道适配？

**痛点**：不同渠道，用户体验差异大
- **Telegram**：发图片最直观，且不占用 token 显示
- **浏览器**：内联显示更方便，无需下载
- **Terminal**：只要路径，用户自己打开

**解决方案**：自动检测渠道，选择最佳方式

---

## 📋 渠道对比

| 渠道 | 最佳方式 | 原因 | Token 成本 |
|------|----------|------|-----------|
| **Telegram** | 发送图片文件 | 直接预览，省 token | 低（~50 tokens）⭐ |
| **浏览器/Web** | Read tool 显示 | 内联预览，无需切换 | 中（~1000 tokens） |
| **Terminal** | 返回文件路径 | 终端用户习惯 `open` | 最低（纯文本） |

## 💰 成本优势（vs AI 生成）

**agent-browser 截图 vs AI 图片生成**：

| 维度 | agent-browser | Gemini 生成 | DALL-E 3 |
|------|---------------|-------------|----------|
| **成本** | **$0** ✅ | ~$0.01/张 | ~$0.04/张 |
| **准确度** | 100%（真实渲染） | 80%（AI 想象） | 70%（AI 想象） |
| **速度** | 快（<5s） | 中（~30s） | 慢（~60s） |

**为什么完全免费？**
1. **本地工具**：agent-browser 使用本地 Chromium，无 API 调用
2. **真实渲染**：不是 AI 生成，是浏览器真实渲染
3. **无流量成本**：截图保存在本地，不上传云端
4. **Telegram 发送优化**：message tool 发送文件，不编码图片到消息（省 token）

**实际对比**（100 次迭代修改）：
- agent-browser: $0
- Gemini: $1
- DALL-E 3: $4

**关键洞察**：设计迭代需要频繁截图，用 AI 生成会很贵且不准确。agent-browser 完全免费且 100% 准确。

---

## 🔧 实现方式

### 方法 1: 手动判断（明确知道渠道）

```javascript
// 用户在 Telegram
function sendScreenshotToTelegram(screenshotPath, message) {
  message({
    action: "send",
    channel: "telegram",
    target: "6883367773",
    media: screenshotPath,
    message: message
  })
}

// 用户在浏览器
function showScreenshotInBrowser(screenshotPath) {
  Read({path: screenshotPath})
}

// 用户在 Terminal
function returnScreenshotPath(screenshotPath) {
  return `Screenshot saved: ${screenshotPath}\nOpen with: open ${screenshotPath}`
}
```

### 方法 2: 智能检测（自动适配）

```javascript
// 从 runtime context 获取 channel
// Runtime 示例: channel=telegram

function smartSendScreenshot(screenshotPath, message) {
  const channel = getRuntimeChannel() // 从 runtime 获取
  
  switch(channel) {
    case 'telegram':
      // Telegram: 发送图片
      message({
        action: "send",
        channel: "telegram",
        media: screenshotPath,
        message: message
      })
      break
      
    case 'webchat':
    case 'browser':
      // 浏览器: 使用 Read tool
      Read({path: screenshotPath})
      break
      
    default:
      // Terminal 或其他: 返回路径
      return `Screenshot: ${screenshotPath}`
  }
}
```

### 方法 3: 简化版（伪代码）

```python
# 截图后自动发送
def screenshot_and_send(html_file, change_description):
    # 1. 截图
    screenshot_path = screenshot(html_file)
    
    # 2. 检测渠道
    channel = get_current_channel()
    
    # 3. 智能发送
    if channel == "telegram":
        send_to_telegram(screenshot_path, f"已修改：{change_description}")
    elif channel == "webchat":
        show_inline(screenshot_path)
    else:
        print(f"Screenshot: {screenshot_path}")
```

---

## 🎨 实际案例

### 案例 1: Telegram 用户修改按钮

```javascript
// 用户："把按钮改成蓝色"
// Runtime: channel=telegram

// 1. 修改 HTML
Edit("button.html", {
  oldText: "background: red",
  newText: "background: blue"
})

// 2. 截图
exec("screenshot.sh button.html /tmp/button-blue.png")

// 3. 自动发送到 Telegram（检测到 channel=telegram）
message({
  action: "send",
  channel: "telegram",
  media: "/tmp/button-blue.png",
  message: "已修改：蓝色背景"
})
```

### 案例 2: 浏览器用户修改布局

```javascript
// 用户："调整一下间距"
// Runtime: channel=webchat

// 1. 修改 CSS
Edit("layout.html", {
  oldText: "gap: 16px",
  newText: "gap: 24px"
})

// 2. 截图
exec("screenshot.sh layout.html /tmp/layout-updated.png")

// 3. 在浏览器内联显示（检测到 channel=webchat）
Read({path: "/tmp/layout-updated.png"})
// 回复："已修改：间距调整为 24px"
```

### 案例 3: Terminal 用户调试代码

```javascript
// 用户："改一下颜色看看"
// Runtime: channel=terminal (or no channel)

// 1. 修改代码
Edit("style.css", {
  oldText: "color: #333",
  newText: "color: #0066cc"
})

// 2. 截图
exec("screenshot.sh test.html /tmp/color-test.png")

// 3. 返回路径（检测到 terminal）
return `✓ 已修改：颜色改为蓝色
Screenshot: /tmp/color-test.png
Open with: open /tmp/color-test.png`
```

---

## 🚀 标准工作流模板

```javascript
// 通用模板：修改 → 截图 → 智能发送
function modifyAndPreview(file, modification, description) {
  // 1. 修改文件
  applyModification(file, modification)
  
  // 2. 生成截图
  const screenshot = takeScreenshot(file)
  
  // 3. 根据渠道自动发送
  const channel = runtime.channel // 从 runtime 获取
  
  if (channel === "telegram") {
    // Telegram: 发图片（省 token）
    sendToTelegram(screenshot, `已修改：${description}`)
  } else if (channel === "webchat") {
    // 浏览器: 内联显示
    showInline(screenshot)
    reply(`已修改：${description}`)
  } else {
    // Terminal: 返回路径
    reply(`已修改：${description}\nScreenshot: ${screenshot}`)
  }
}
```

---

## 📊 优先级决策树

```
修改了视觉代码？
  ↓ 是
截图
  ↓
检测渠道
  ├─ Telegram? → 发送图片（message tool）
  ├─ 浏览器?   → 内联显示（Read tool）
  └─ Terminal? → 返回路径（文本）
```

---

## 💡 最佳实践

### 1. 始终检测渠道
```javascript
// ✅ 好
const channel = runtime.channel
if (channel === "telegram") { /* Telegram 逻辑 */ }

// ❌ 不好
// 假设用户在 Telegram（可能不准确）
```

### 2. Telegram 优先发图
```javascript
// ✅ 好（Telegram）
message({media: screenshot})  // 省 token

// ❌ 不好（Telegram）
Read({path: screenshot})      // 浪费 token
```

### 3. 浏览器用 Read
```javascript
// ✅ 好（浏览器）
Read({path: screenshot})      // 内联显示

// ❌ 不好（浏览器）
return screenshot             // 用户看到路径，无法预览
```

### 4. Terminal 只给路径
```javascript
// ✅ 好（Terminal）
return `Screenshot: ${path}`  // 用户自己打开

// ❌ 不好（Terminal）
Read({path: screenshot})      // Terminal 无法显示图片
```

---

## 🔍 Runtime Context 检测

**如何获取当前渠道？**

OpenClaw 在 runtime 里提供 `channel` 参数：
```
Runtime: channel=telegram | channel=webchat | channel=...
```

**在 SKILL.md 里使用**：
```markdown
Check runtime context for `channel` parameter:
- channel=telegram → Use message tool
- channel=webchat → Use Read tool
- Others → Return path
```

---

## 📝 总结

| 场景 | 渠道 | 方法 | 代码 |
|------|------|------|------|
| 用户在手机 | Telegram | 发图片 | `message({media})` |
| 用户在浏览器 | webchat | 内联显示 | `Read({path})` |
| 用户在终端 | terminal | 返回路径 | `return path` |

**关键**：自动检测，无需用户指定！

---

*最后更新：2026-02-07*
