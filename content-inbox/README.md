# Content Inbox - 统一内容管理

## 🎯 这是什么？

Content Inbox 是一个智能内容管理系统，帮助你：
1. **统一管理**所有外部内容（抖音、小红书、公众号等）
2. **自动学习**你的处理偏好（越用越懂你）
3. **灵活配置**（临时偏好 + 项目配置 + 全局偏好）
4. **Non-blocking**（后台处理，主对话不阻塞）

---

## 🚀 快速开始

### 1. 发送链接

```
https://v.douyin.com/xxx/
```

### 2. 选择处理方式

```
Agent：✅ 已下载
       要怎么处理？
       A. 仅下载
       B. 转写文字（~5 分钟）
       C. 完整分析（转写+验证+素材化，~20 分钟）
       D. 生成博客草稿（~30 分钟）

User：C
```

### 3. 等待完成

```
Agent：✅ 开始完整分析...
       ⏳ 预计需要 20 分钟，完成后通知你

[20 分钟后]

Agent：✅ 分析完成！
       📄 素材文件：content-inbox/douyin/media/2026-03-12/标题.md
       
       核心发现：
       - ✅ 观点 1：已被 [研究 A] 证实
       - ⚠️ 观点 2：存在争议
       - ❌ 观点 3：与 [数据 B] 矛盾
```

---

## 📚 处理选项

| 选项 | 包含内容 | 耗时 | 成本 |
|------|---------|------|------|
| **A. 仅下载** | 视频 + 元数据 | ~1 分钟 | $0.001 |
| **B. 转写文字** | A + Whisper 转写 | ~5 分钟 | 免费 |
| **C. 完整分析** | B + 验证 + 素材化 | ~20 分钟 | 免费 |
| **D. 博客草稿** | C + PMSL 框架草稿 | ~30 分钟 | 免费 |

---

## 🧠 智能学习

### 第一次发链接

```
User：https://v.douyin.com/xxx/
Agent：[询问] 要怎么处理？
User：C
```

### 第三次发链接

```
User：https://v.douyin.com/yyy/
Agent：[预测] 完整分析？
User：[回车确认]
```

### 第五次发链接

```
User：https://v.douyin.com/zzz/
Agent：[自动执行] ✅ 开始完整分析...
       [不询问]
```

---

## 🎛️ 配置层级

### 4 层结构

```
SESSION（临时）→ PROJECT（项目）→ GLOBAL（全局）→ SKILL（默认）
```

**示例：**

```
SESSION："这次只下载"
PROJECT："accounting-ai 项目生成博客草稿"
GLOBAL："抖音视频默认完整分析"
SKILL："下载后询问用户"
```

**冲突解决**：SESSION > PROJECT > GLOBAL > SKILL

---

## 📁 目录结构

```
content-inbox/
├── douyin/
│   ├── queue.jsonl           # 待处理队列
│   ├── processing.json        # 处理中
│   ├── completed.jsonl        # 已完成
│   ├── failed.jsonl           # 失败记录
│   └── media/
│       └── 2026-03-12/
│           ├── 标题.mp4
│           └── 标题.md
├── xiaohongshu/
├── wechat/
└── README.md
```

---

## 🔧 配置文件

### 全局偏好（~/.openclaw/memory.md）

```markdown
## Confirmed Preferences
- 抖音视频默认：完整分析（C）
  (confirmed 2026-03-12, used 15x)
```

### 项目配置（projects/accounting-ai/config.md）

```markdown
# Project: accounting-ai

## Content Processing
- 抖音视频：生成博客草稿（D）
- 小红书：完整分析（C）
```

### 临时偏好（data/session.json）

```json
{
  "temporary_preferences": {
    "douyin": "A",
    "reason": "这次只下载"
  }
}
```

---

## 📊 统计命令

| 命令 | 动作 |
|------|------|
| "内容库状态" | 显示各平台的队列、已完成数量 |
| "我的偏好" | 显示 GLOBAL 和当前 PROJECT 的配置 |
| "清空队列" | 清空所有待处理项 |
| "重新处理 X" | 重新处理某个链接 |

---

## 🔗 相关 Skills

- **video-analyzer**：视频内容分析（转写、验证、素材化）
- **platform-bridge**：平台适配器（抖音、小红书、公众号）

---

## 🛠️ 技术细节

### 配置管理

```python
from scripts.config_manager import ConfigManager

config = ConfigManager(
    workspace_dir="~/.openclaw/workspace",
    home_dir="~",
    current_project="accounting-ai"
)

# 获取配置
default_action = config.get("douyin_default_action", "ask")

# 设置配置
config.set("douyin_default_action", "full_analysis", layer="global")
```

### 偏好学习

```python
from scripts.preference_learner import PreferenceLearner

learner = PreferenceLearner(
    corrections_file="data/corrections.json",
    memory_file="~/.openclaw/memory.md"
)

# 检测明确偏好
result = learner.detect_explicit_preference("Always use full analysis")

# 记录纠正
learner.record_correction(
    key="douyin_default_action",
    value="full_analysis",
    context="抖音视频处理"
)
```

---

## 📈 性能目标

| 指标 | 目标 |
|------|------|
| 自动化率 | > 70% |
| 用户打扰率 | < 30% |
| 学习准确率 | > 90% |
| Non-blocking 合规率 | 100% |

---

## 🚧 开发进度

- [x] SKILL.md（技能规范）
- [x] 配置管理器（4 层）
- [x] 偏好学习器（3 次确认）
- [ ] 平台适配器（platform-bridge）
- [ ] 视频分析器（video-analyzer）
- [ ] 测试和优化

---

## 📝 更新日志

### 2026-03-12
- ✅ 创建 3 个 Skills 的基础结构
- ✅ 实现 4 层配置系统
- ✅ 实现偏好学习机制
- ✅ 创建模板文件
