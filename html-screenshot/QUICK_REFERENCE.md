# HTML Screenshot - Quick Reference

## 🎯 核心原则

**修改 HTML = 自动截图 + 自动发送**

## 🔄 标准工作流（智能渠道适配）

```javascript
// 1. 修改 HTML/CSS
Edit("file.html", oldText, newText)

// 2. 立即截图（不等用户说）
const screenshot = "/tmp/preview.png"
exec("screenshot.sh file.html " + screenshot)

// 3. 根据渠道自动选择发送方式
const channel = runtime.channel  // 从 runtime 获取

if (channel === "telegram") {
  // Telegram: 发送图片（省 token）
  message({
    action: "send",
    channel: "telegram",
    media: screenshot,
    message: "已修改：[简短说明]"
  })
} else if (channel === "webchat") {
  // 浏览器: 内联显示
  Read({path: screenshot})
  // 可选：添加文字说明
} else {
  // Terminal: 返回路径
  return `已修改：[说明]\nScreenshot: ${screenshot}`
}
```

## ⚡ 快捷命令

```bash
# 基础截图
screenshot.sh <html_file> <output.png>

# 自定义尺寸
screenshot.sh <html_file> <output.png> 1920x1080

# 完整页面
screenshot.sh <html_file> <output.png> --full-page
```

## 🚫 避免的模式

```
❌ "已经修改好了，需要截图吗？"
❌ 等用户说"让我看看"
❌ 只说修改了什么，不发截图
```

## ✅ 正确的模式

```
✅ [修改] → [自动截图] → [立即发送]
✅ 带简短说明："已修改：蓝色背景"
✅ 快速迭代：<5 秒完成循环
```

## 📋 触发场景

**任何视觉修改都要截图**：
- 改颜色、字体、大小
- 调布局、间距、对齐
- 加/删元素
- 响应式调整

**关键词提示**：
- "改一下..."
- "调整..."
- "换个颜色"
- "大一点/小一点"
- "加个..."

## 🎨 消息格式

```javascript
// 简短版
message({media: "/tmp/v1.png", message: "已修改：圆角 12px"})

// 详细版（多个改动）
message({media: "/tmp/v2.png", message: "已修改：\n• 背景色 → 蓝色\n• 按钮加大\n• 添加阴影"})
```

## 📂 文件管理

```bash
# 时间戳命名（避免覆盖）
/tmp/preview-$(date +%Y%m%d-%H%M%S).png

# 版本命名（对比场景）
/tmp/design-v1.png
/tmp/design-v2.png
```

## 📱 渠道快速决策

| 渠道 | 检测方式 | 发送方法 | 原因 |
|------|----------|----------|------|
| **Telegram** | `channel=telegram` | `message({media})` | 省 token，直接预览 |
| **浏览器** | `channel=webchat` | `Read({path})` | 内联显示，无需下载 |
| **Terminal** | 其他 | `return path` | 终端习惯，自己打开 |

**自动检测**：
```javascript
const channel = runtime.channel
// 根据 channel 值选择上表中的方法
```

---

**记住：**
1. **修改后立即发截图，不要等用户问！**
2. **根据渠道自动选择最佳方式**
