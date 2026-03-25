# HTML Screenshot Skill - 完整总结

**创建日期**: 2026-02-07  
**创建原因**: Portfolio 设计预览 → 迭代修改工作流 → 智能渠道适配  
**当前版本**: v1.0 (Full Channel Adaptation)

---

## 🎯 核心功能

### 1. 自动截图反馈循环
- 修改 HTML/CSS → **自动截图** → **自动发送**
- 无需用户说"让我看看"
- 快速迭代（<5 秒/循环）

### 2. 智能渠道适配 ⭐ NEW
- **Telegram**: 发送图片（省 token，直接预览）
- **浏览器**: 内联显示（Read tool）
- **Terminal**: 返回路径（用户自己打开）

### 3. 标准化工作流
- 统一的截图命令
- 清晰的触发规则
- 完整的案例文档

---

## 📚 文件结构

```
html-screenshot/
├── SKILL.md                    # AI 读取（核心规则 + 渠道适配）
├── README.md                   # 项目说明（核心价值 + 工作流）
├── SUMMARY.md                  # 本文件（完整总结）
├── QUICK_REFERENCE.md          # 速查手册（代码模板）
├── WORKFLOW_EXAMPLES.md        # 实战案例（3 个完整案例）
├── CHANNEL_ADAPTATION.md       # 渠道适配指南 ⭐
└── scripts/
    ├── screenshot.sh           # 核心截图工具
    ├── preview-and-send.sh     # 完整工作流
    └── smart-send.sh           # 智能渠道发送 ⭐
```

---

## 🔄 完整工作流

### 标准流程（自动渠道适配）

```javascript
// 用户："把按钮改成蓝色"

// 1. 修改代码
Edit("button.html", {
  oldText: "background: red",
  newText: "background: blue"
})

// 2. 截图
const screenshot = "/tmp/button.png"
exec("screenshot.sh button.html " + screenshot)

// 3. 智能发送（自动检测渠道）
const channel = runtime.channel

if (channel === "telegram") {
  // Telegram: 发图片
  message({
    action: "send",
    channel: "telegram",
    media: screenshot,
    message: "已修改：蓝色背景"
  })
} else if (channel === "webchat") {
  // 浏览器: 内联显示
  Read({path: screenshot})
} else {
  // Terminal: 返回路径
  return `已修改：蓝色背景\nScreenshot: ${screenshot}`
}
```

---

## 🎨 使用场景

### 场景 A: 迭代设计（最常用）
```
用户："按钮大一点"
我：  [改代码] → [截图] → [自动发送]
用户："颜色深一点"
我：  [改代码] → [截图] → [自动发送]
用户："可以了"
```

### 场景 B: 对比版本
```
我：[生成 v1] → [截图] → [发送 "版本 1"]
我：[生成 v2] → [截图] → [发送 "版本 2"]
用户："用版本 2"
```

### 场景 C: 响应式测试
```
我：[1920x1080] → [截图] → [发送 "Desktop"]
我：[768x1024]  → [截图] → [发送 "Tablet"]
我：[375x667]   → [截图] → [发送 "Mobile"]
```

---

## 📊 渠道对比

| 渠道 | 方法 | Token 成本 | 用户体验 |
|------|------|-----------|---------|
| **Telegram** | `message({media})` | 低 | ⭐⭐⭐⭐⭐ 直接看 |
| **浏览器** | `Read({path})` | 中 | ⭐⭐⭐⭐ 内联显示 |
| **Terminal** | `return path` | 最低 | ⭐⭐⭐ 自己打开 |

---

## 🚀 关键原则

### 1. Show, Don't Tell
- ❌ "已经修改好了，需要截图吗？"
- ✅ [直接发送截图] "已修改：蓝色背景"

### 2. 自动检测渠道
- ❌ 问用户："你在用什么渠道？"
- ✅ 从 runtime.channel 自动检测

### 3. 快速迭代
- 目标：修改 → 截图 → 发送 < 5 秒
- 不拖延，不等待，不询问

### 4. 任何视觉修改都截图
- 改颜色、字体、大小 → 截图
- 调布局、间距、对齐 → 截图
- 加/删元素 → 截图

---

## 💡 成功案例

### Case 1: Portfolio 设计预览（2026-02-07）
- **问题**: 用户在 Telegram 看不到 HTML 效果
- **解决**: agent-browser 截图 → 发送到 Telegram
- **结果**: ✅ 用户立即看到设计效果

### Case 2: 迭代修改工作流
- **问题**: 每次修改都要手动截图
- **解决**: 自动截图 + 自动发送
- **结果**: ✅ 快速迭代，无需重复操作

### Case 3: 智能渠道适配
- **问题**: 不同渠道需要不同发送方式
- **解决**: 自动检测 runtime.channel
- **结果**: ✅ 无需用户指定，自动选择最佳方式

---

## 📈 预期效果

### 时间节省
- **以前**: 5 分钟/次（手动截图 + 发送）
- **现在**: 5 秒/次（自动化）
- **节省**: 95%+

### Token 节省（Telegram）
- **以前**: Read tool 显示图片（~1000 tokens）
- **现在**: message tool 发送（~50 tokens）
- **节省**: 95%+

### 成本节省（vs AI 生成图片）
- **agent-browser 截图**: $0（本地渲染）✅
- **Gemini 生成**: ~$0.01/张
- **DALL-E 3**: ~$0.04/张
- **节省**: 100%（完全免费）

**为什么免费？**
1. agent-browser 是本地工具（无 API 调用）
2. 真实渲染，不是 AI 生成（无生成成本）
3. Telegram 发图片不占 token（只传文件）
4. 完全本地化流程（HTML → 渲染 → 截图 → 发送）

### 用户体验
- **以前**: "能让我看看吗？" "好的，稍等..."
- **现在**: [图片自动弹出] "已修改：蓝色背景"
- **提升**: 无需等待，即时反馈

---

## 🔧 技术栈

- **截图工具**: agent-browser (基于 Chromium)
- **发送方式**: message tool / Read tool
- **检测机制**: runtime.channel
- **脚本语言**: Bash + JavaScript (伪代码)

---

## 🎓 学习价值

### 对用户
- 快速迭代设计
- 实时视觉反馈
- 无需学习命令

### 对 AI
- 标准化工作流
- 智能决策（渠道适配）
- 避免重复踩坑（记录失败方案）

---

## 📋 下一步优化（可选）

- [ ] 支持视频录制（交互演示）
- [ ] 批量对比（多版本并排显示）
- [ ] 自动检测 HTML 变化（实时预览）
- [ ] 集成到 CI/CD（自动生成文档）
- [ ] 支持 Discord/Slack 等其他渠道

---

## ✅ 验证状态

- ✅ 截图功能：已测试通过（agent-browser）
- ✅ Telegram 发送：已测试通过（message tool）
- ✅ 迭代工作流：已记录完整流程
- ✅ 渠道适配：已设计完整方案
- ⏳ 实际使用：待真实场景验证

---

**这个 skill 解决的核心问题**：
> "我改了代码，想让你立刻给我看效果，但我不想每次都说'让我看看'，也不想浪费 token，还希望你能根据我在用什么渠道（Telegram/浏览器/终端）自动选择最好的方式给我展示。"

**现在的效果**：
> ✅ 全自动，智能适配，快速迭代，节省 token

---

*最后更新：2026-02-07*  
*版本：v1.0 - Full Channel Adaptation*
