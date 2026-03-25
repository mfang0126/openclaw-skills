# HTML Screenshot - Quick Reference (Simplified v2)

## 🎯 核心原则

**只对视觉修改截图，失败时告知用户**

---

## ✅ 何时截图（按渠道区分）

### Telegram（更主动）
**截图**：
- ✅ 任何 CSS 样式变化（颜色、字体、大小、间距、边框、阴影）
- ✅ 任何布局变化（margin、padding、position、display）
- ✅ 加/删/改任何可见元素
- ✅ 改可见文本（即使是小改动）

**不截图**：
- ❌ 注释、格式化、不可见属性

### 浏览器/Terminal（适度）
**截图**：
- ✅ 重要视觉变化（颜色、主要布局、新元素）

**不截图**：
- ❌ 小改动（微调文本、细微间距）
- ❌ 代码重构、注释、格式化

**原因**：Telegram 用户看不到本地文件，必须靠截图；浏览器/终端用户可以自己预览。

---

## 🔄 标准工作流

```javascript
// 1. 修改代码
Edit("file.html", oldText, newText)

// 2. 渠道差异化判断
const channel = runtime.channel

let shouldScreenshot = false

if (channel === "telegram") {
  // Telegram: 更宽松（任何视觉变化）
  shouldScreenshot = (
    修改了任何样式 ||
    修改了布局 ||
    加/删了元素 ||
    改了可见文本
  ) && !(改了注释 || 格式化代码)
  
} else {
  // 浏览器/Terminal: 更严格（只有重要变化）
  shouldScreenshot = (
    改了颜色 ||
    重要布局变化 ||
    加/删元素
  )
}

if (!shouldScreenshot) {
  return "✓ 修改完成"  // 不截图
}

// 3. 截图
const screenshot = `/tmp/preview-${Date.now()}.png`
try {
  exec(`screenshot.sh file.html ${screenshot}`)
} catch (error) {
  // 错误处理：告知用户
  return `❌ 截图失败：${error}\n📁 文件路径：${filePath}`
}

// 4. 根据渠道发送
const channel = runtime.channel

if (channel === "telegram") {
  message({media: screenshot, message: "已修改：[说明]"})
} else if (channel === "webchat") {
  Read({path: screenshot})
} else {
  return `✓ 已修改：[说明]\n📸 Screenshot: ${screenshot}`
}
```

---

## 🎮 用户控制

| 用户说 | 我的反应 |
|--------|----------|
| "看看效果" | 立即截图（即使不是视觉修改） |
| "不用看" | 跳过本次截图 |
| "每次都截图" | 本次会话：任何修改都截图 |
| "关闭截图" | 本次会话：完全禁用截图 |

---

## ❌ 错误处理

**原则：Never fail silently**

```javascript
// 截图失败模板
function handleScreenshotFailure(error, filePath) {
  return `❌ 截图失败：${error}
📁 你可以手动打开文件：${filePath}
🔄 需要我重试吗？`
}

// 使用示例
try {
  screenshot(file)
} catch (e) {
  reply(handleScreenshotFailure(e.message, file))
}
```

---

## 📊 判断示例（按渠道区分）

| 修改内容 | Telegram | 浏览器/Terminal | 理由 |
|---------|----------|----------------|------|
| `color: red → blue` | ✅ 是 | ✅ 是 | 明显视觉变化 |
| `标题：Hello → Hi` | ✅ 是 | ❌ 否 | Telegram 用户看不到，需要截图 |
| `margin: 10px → 12px` | ✅ 是 | ❌ 否 | 微调，Telegram 也截（更主动） |
| `<!-- 注释 -->` | ❌ 否 | ❌ 否 | 所有渠道都不截 |
| `class="btn" → "button"` | ❌ 否 | ❌ 否 | 只是重命名 |
| `<button>新增</button>` | ✅ 是 | ✅ 是 | 新元素，都截 |
| `font-size: 16px → 18px` | ✅ 是 | ✅ 是 | 重要样式变化 |
| `border: 1px → 2px` | ✅ 是 | ❌ 否 | 微调，Telegram 也截 |
| `alt="xxx" → "yyy"` | ❌ 否 | ❌ 否 | 不可见 |
| 格式化代码 | ❌ 否 | ❌ 否 | 无视觉影响 |

**关键差异**：Telegram 对微调也截图（如 margin 10px→12px），浏览器/终端不截（用户自己看）。

---

## 📱 渠道适配（保持不变）

| 渠道 | 方法 | 原因 |
|------|------|------|
| Telegram | `message({media})` | 省 token |
| 浏览器 | `Read({path})` | 内联显示 |
| Terminal | `return path` | 用户自己打开 |

---

## 💡 关键变化（vs v1）

| 维度 | v1（过度） | v2（简化）✅ |
|------|-----------|-------------|
| 触发 | 任何 HTML 修改 | 只有视觉修改 |
| 频率 | 100% | ~60% |
| 错误 | 默默失败 | 明确告知 + 备选方案 |
| 用户控制 | 无 | 可触发/跳过 |

---

**记住：只截图重要的，失败时告诉用户！**
