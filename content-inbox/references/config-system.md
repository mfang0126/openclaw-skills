# 配置系统详解

## 4 层架构

```
SESSION（临时）→ PROJECT（项目）→ GLOBAL（全局）→ SKILL（默认）
```

### 层级详解

#### 1. SESSION 层（优先级 1）

**位置**：`content-inbox/data/session.json`

**生命周期**：单次对话

**用途**：临时偏好

**示例**：
```json
{
  "temporary_preferences": {
    "douyin": "A",
    "reason": "这次只下载"
  }
}
```

**何时使用**：
- 用户说："这次先别下载"
- 用户说："就这次用 B"
- 任何"这次/just this time"前缀

**清除时机**：
- 会话结束
- 手动清除："清除临时偏好"

---

#### 2. PROJECT 层（优先级 2）

**位置**：`projects/{name}/config.md`

**生命周期**：项目级（长期）

**用途**：项目特定配置

**示例**：
```markdown
# Project: accounting-ai

## Content Processing
- 抖音视频：生成博客草稿（D）
- 小红书：完整分析（C）
```

**何时使用**：
- 用户在项目中说："这个项目都用 D"
- 用户说："For this project, always X"

**继承**：
- 继承 GLOBAL 层配置
- 可覆盖 GLOBAL 配置

---

#### 3. GLOBAL 层（优先级 3）

**位置**：`~/.openclaw/memory.md`

**生命周期**：永久（除非 Decay）

**用途**：全局偏好

**示例**：
```markdown
## Confirmed Preferences
- 抖音视频默认：完整分析（C）
  (confirmed 2026-03-12, used 15x)
```

**何时使用**：
- 用户说："Always do X"
- 用户说："From now on, X"
- 学习机制 3 次确认后

**Decay**：
- 30 天未用 → 降级到 WARM
- 90 天未用 → 归档到 COLD

---

#### 4. SKILL 层（优先级 4）

**位置**：`SKILL.md`

**生命周期**：永久（Skill 默认行为）

**用途**：默认行为

**示例**：
```markdown
## 默认工作流
1. 检测链接 → 下载
2. 询问用户：A/B/C/D
3. 根据选择执行
```

**何时使用**：
- 没有其他层配置时
- 作为兜底默认行为

---

## 冲突解决

### 优先级规则

```
SESSION > PROJECT > GLOBAL > SKILL
```

### 示例

```
SESSION："这次只下载"
PROJECT："accounting-ai 项目生成博客草稿"
GLOBAL："抖音视频默认完整分析"
SKILL："下载后询问用户"

结果：应用 SESSION（这次只下载）
```

### 冲突检测

当检测到冲突时：
1. 应用最高优先级配置
2. 记录冲突到日志
3. 可选：询问用户

---

## 配置管理 API

### Python

```python
from scripts.config_manager import ConfigManager

# 初始化
config = ConfigManager(
    workspace_dir="~/.openclaw/workspace",
    home_dir="~",
    current_project="accounting-ai"
)

# 获取配置
default_action = config.get("douyin_default_action", "ask")

# 设置配置
config.set("douyin_default_action", "full_analysis", layer="global")

# 获取层级信息
info = config.get_layer_info("douyin_default_action")
# {
#   "value": "full_analysis",
#   "source": "GLOBAL",
#   "priority": 3,
#   "confirmed_at": "2026-03-12"
# }

# 切换项目
config.set_project("contact-site")

# 清除 SESSION
config.clear_session()
```

---

## 配置迁移

### 升级流程

```
旧版（无分层）→ 新版（4 层）
```

**迁移脚本**：
```python
# 读取旧配置
old_config = load_old_config()

# 迁移到 GLOBAL 层
for key, value in old_config.items():
    config.set(key, value, layer="global")
```

---

## 调试

### 查看当前配置

```python
# 所有配置（合并后）
all_config = config.get_all_configs()

# 层级信息
layer_info = config.get_layer_info("douyin_default_action")
```

### 日志

配置变更会记录到：
- `content-inbox/data/config.log`

---

## 最佳实践

1. **明确偏好** → 直接写 GLOBAL
2. **项目特定** → 写 PROJECT
3. **临时改变** → 写 SESSION（自动清除）
4. **不要过度配置** → 让学习机制工作

---

## 相关文档

- `learning.md`：学习机制详解
- `workflow.md`：工作流详解
