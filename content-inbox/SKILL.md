---
name: content-inbox
description: |
  统一内容管理系统。自动处理抖音/小红书/公众号链接，下载后询问用户如何处理。

  USE FOR:
  - 消息包含 v.douyin.com → 立即触发，不要等待
  - 消息包含 xiaohongshu.com → 立即触发
  - "下载这个", "处理这个链接", "analyze this", "save this video"
  - 消息包含 mp.weixin.qq.com → 触发公众号处理
  - "帮我存下来", "下载一下", "抖音链接", "小红书"

  REQUIRES: python3; douyin-downloader skill; video-analyzer skill
metadata:
  openclaw:
    emoji: "📥"
    requires:
      bins: ["python3"]
---

# Content Inbox

**Pattern: Pipeline** (Google ADK) — 检测链接 → 后台下载 → 询问用户 → 执行动作 → 学习偏好

## When to Use

Use when the user shares a social media link (Douyin, Xiaohongshu, WeChat) or asks to download/process content from these platforms. Triggers automatically — no explicit "download" command needed.

**Don't use when:** The link is from YouTube, Bilibili, Instagram, or other platforms not in scope. For those, use the platform-specific skill.

## Prerequisites

- `python3` installed
- `douyin-downloader` skill configured (TikHub API token in `~/.openclaw/config.json`)
- `video-analyzer` skill available for transcription/analysis
- `~/.openclaw/workspace` directory exists

## Quick Start

```bash
# Detect platform from URL and trigger download pipeline
# (Handled automatically — just share a link)

# Manual test: trigger douyin download
python3 ~/.openclaw/skills/douyin-dl/scripts/douyin_download.py "https://v.douyin.com/xxxxx/" --download
```

## 触发条件

**自动触发（不等待用户指令）：**
- 消息包含 `v.douyin.com` 或 `douyin.com`
- 消息包含 `xiaohongshu.com`
- 消息包含 `mp.weixin.qq.com`
- 用户说："下载这个"、"处理这个链接"

## 工作流（具体步骤）

### 1. 检测链接类型

```python
if "v.douyin.com" in message or "douyin.com" in message:
    platform = "douyin"
elif "xiaohongshu.com" in message:
    platform = "xiaohongshu"
elif "mp.weixin.qq.com" in message:
    platform = "wechat"
```

### 2. 下载视频（后台执行）

```python
# 派 SubAgent 后台下载
sessions_spawn(
    runtime="subagent",
    task=f"用 douyin-downloader 下载：{url}",
    label="下载抖音视频"
)
# 立即回复用户（不等待下载完成）
reply("✅ 开始下载...")
```

### 3. 检查配置，决定是否询问

```python
from scripts.config_manager import ConfigManager
config = ConfigManager(workspace_dir="~/.openclaw/workspace", home_dir="~")
default_action = config.get("douyin_default_action", "ask")
if default_action == "ask":
    ask_user("要怎么处理？A/B/C/D")
else:
    execute_action(default_action)
```

### 4. 询问用户（如果没有默认动作）

```
✅ 已下载：{标题}
- 作者：{author}
- 时长：{duration}

要怎么处理？
A. 仅下载（已完成）
B. 转写文字（~5 分钟）
C. 完整分析（转写+验证+素材化，~20 分钟）
D. 生成博客草稿（~30 分钟）
```

### 5. 根据用户选择执行

- **A. 仅下载** → 完成
- **B. 转写文字** → `sessions_spawn(task="用 video-analyzer 转写：{video_path}")`
- **C. 完整分析** → `sessions_spawn(task="用 video-analyzer 完整分析：{video_path}")`
- **D. 博客草稿** → `sessions_spawn(task="用 video-analyzer 生成博客草稿：{video_path}")`

## Examples

### Example 1: 用户分享抖音链接

**User says:** `https://v.douyin.com/iABCxyz/`（无其他说明）

**Steps:**
1. 检测到 `v.douyin.com` → 立即触发
2. 后台调用 douyin-downloader 下载视频
3. 回复用户并展示选项

**Output:**
```
✅ 开始下载...

已下载：《如何用AI写出高质量文章》
- 作者：@tech_creator
- 时长：3:42

要怎么处理？
A. 仅下载（已完成）
B. 转写文字（~5 分钟）
C. 完整分析（~20 分钟）
D. 生成博客草稿（~30 分钟）
```

**Reply:** "已下载完成！选 A-D 告诉我下一步怎么处理。"

### Example 2: 用户明确要求转写

**User says:** "帮我转写一下这个 https://v.douyin.com/iXYZ123/"

**Steps:**
1. 检测链接 → 下载 → 自动选择选项 B

**Reply:** "✅ 开始转写... 预计 5 分钟，完成后通知你。"

## 4 层配置系统

| 层级 | 位置 | 用途 |
|------|------|------|
| SESSION | `data/session.json` | 临时偏好（本次会话） |
| PROJECT | `projects/{name}/config.md` | 项目特定配置 |
| GLOBAL | `~/.openclaw/memory.md` | 全局偏好 |
| SKILL | `SKILL.md` | 默认行为 |

## Non-blocking 原则

长时间操作必须后台运行：
```python
# ✅ 正确
sessions_spawn(task="处理视频", runtime="subagent")
# 主会话立即回复

# ❌ 错误
# 在主会话中直接执行（阻塞用户对话）
```

## Error Handling

| Error | Cause | Solution |
|-------|-------|----------|
| 下载失败（首次） | 链接失效 / 网络问题 | 自动重试 1 次；失败则告知用户 |
| TikHub API 超时 | API 服务繁忙 | 切换到 Playwright 下载模式 |
| Playwright 也失败 | 平台反爬升级 | 告知用户稍后重试，提供手动下载建议 |
| python3 未找到 | 环境未配置 | 确认 `python3` 在 PATH 中 |
| TikHub token 缺失 | 未配置 API token | 在 `~/.openclaw/config.json` 添加 `tikhub_api_token` |

下载失败回复模板：
```
❌ 下载失败：{错误原因}
要重试吗？（回复"重试"或提供新链接）
```

## 快捷方式

用户可以直接说：
- "快速下载" = A
- "转写一下" = B
- "深度分析" = C
- "写博客" = D

## 相关 Skills

- **douyin-dl**：抖音视频下载（TikHub API）
- **video-analyzer**：视频内容分析（转写、验证、素材化）

## 详细文档

- `references/config-system.md`：配置系统详解
- `references/learning.md`：学习机制详解
