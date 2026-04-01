---
name: xhs-publisher
description: |
  安全地通过 sau CLI 发布小红书笔记和视频。内置反 bot 检测策略：频率控制、时段限制、人审门控。

  USE FOR:
  - "发小红书", "发笔记", "发布小红书", "xhs post", "xhs publish"
  - "帮我发一篇小红书笔记", "upload note to xiaohongshu"
  - "发个视频到小红书", "upload video to xiaohongshu"
  - "检查小红书账号状态", "xhs session check"

  NOT FOR:
  - 搜索/读取小红书内容（用 xiaohongshu-mcp）
  - 抓取小红书数据
  - 多账号批量操作
metadata: {"clawdbot":{"emoji":"📕","requires":{"bins":["sau"]}}}
---

# 小红书安全发帖 Skill

## When to Use

触发条件：
- 用户要求发小红书笔记/视频
- 用户要求检查小红书账号状态
- 用户提到小红书发布/上传

不适用：
- 搜索小红书内容
- 抓取数据
- 多账号批量操作

## Prerequisites

环境要求：
- `sau` CLI 已安装且可用
- 小红书账号已登录（cookie 有效）
- 虚拟环境已激活：`source ~/Projects/social-auto-upload/.venv/bin/activate`

检查：
```bash
source ~/Projects/social-auto-upload/.venv/bin/activate && sau xiaohongshu check --account myaccount
```

## Anti-Bot 安全策略（强制执行，不可跳过）

### 频率限制

| 规则 | 限制 |
|------|------|
| 每日最大发帖数 | 2 篇 |
| 两篇最小间隔 | 4 小时 |
| 禁止发帖时段 | 00:00 - 06:00 |
| 发布时间随机偏移 | ±15 分钟 |

### 人审门控（Inversion — 发帖前必须确认）

1. AI 生成草稿（标题 + 正文 + 标签）
2. 发给用户预览
3. 用户明确说"发"/"确认"/"ok"才执行
4. 用户说改 → 修改后再确认
5. 用户说取消 → 停止，不执行任何操作

**门控规则：不经过用户确认，绝不调用 sau upload 命令。**

### 行为模拟

发帖流程中插入随机延迟：
- 发帖前：等待 30-90 秒
- 发帖后：等待 60-120 秒再关闭浏览器

### 状态追踪

状态文件：`~/.openclaw/workspace-claude/skills/xhs-publisher/state.json`

```json
{
  "posts": [
    {"date": "2026-04-01", "time": "10:30", "type": "note", "title": "..."}
  ]
}
```

每次发帖后更新此文件。检查频率限制时读取此文件。

## Instructions

### Step 1: 检查前提条件

1. 激活虚拟环境并检查 session：
   ```bash
   source ~/Projects/social-auto-upload/.venv/bin/activate && sau xiaohongshu check --account myaccount
   ```
   - If `valid` → proceed
   - If `invalid` → 告诉用户需要重新登录，提供登录命令

2. 读取 `state.json`，检查今日已发数量和上次发帖时间
   - If 今日已发 ≥ 2 → 拒绝，说明原因
   - If 距上次发帖 < 4 小时 → 拒绝，说明原因
   - If 当前时间在 00:00-06:00 → 拒绝，说明原因

### Step 2: 生成草稿

根据用户提供的内容：
- 图文笔记：生成标题（≤20字吸引眼球）+ 正文（小红书风格，emoji + 分段）+ 标签（3-8个）
- 视频笔记：生成标题 + 简介 + 标签

**内容风格要求：**
- 标题不超过 20 字
- 正文自然分段，适当使用 emoji
- 标签随机排列，不要固定顺序
- 避免过度营销语气

### Step 3: 人审确认（强制）

将草稿发给用户，格式：
```
📝 草稿预览：
━━━━━━━━━━
标题：XXX
正文：XXX
标签：#xxx #xxx #xxx
━━━━━━━━━━

确认发布？或告诉我需要修改的地方。
```

- 等待用户确认
- 用户确认后进入 Step 4
- 用户要求修改 → 修改后重新确认
- 用户取消 → 停止

### Step 4: 安全发帖（使用包装脚本）

使用 `scripts/publish.py` 包装脚本执行发帖，自动包含人类节奏延迟：

**图文笔记：**
```bash
python3 ~/.openclaw/workspace-claude/skills/xhs-publisher/scripts/publish.py \
  --type note \
  --title "<标题>" \
  --note "<正文>" \
  --tags <标签1>,<标签2> \
  --images <图片路径> \
  --headed
```

**视频笔记：**
```bash
python3 ~/.openclaw/workspace-claude/skills/xhs-publisher/scripts/publish.py \
  --type video \
  --title "<标题>" \
  --desc "<简介>" \
  --tags <标签1>,<标签2> \
  --file <视频路径> \
  --headed
```

**包装脚本自动执行：**
1. 预热（浏览 3-5 篇笔记 + 点赞 1-2 篇，约 2-3 分钟）
2. 发帖前延迟 15-30 秒（模拟打开 App 浏览）
3. 犹豫延迟 5-15 秒（模拟"要不要发"的思考）
4. 调用 sau 执行发布
5. 发帖后延迟 10-25 秒（检查是否发布成功）
6. 顺手刷推荐页 15-40 秒

**总耗时预期：** 3-6 分钟（vs 之前的 18 秒）

**可选参数：**
- `--skip-warmup` — 跳过预热（仅测试时使用）
- `--schedule "YYYY-MM-DD HH:MM"` — 定时发布
- `--headless` — 无头模式（默认有头）

### Step 5: 更新状态

将本次发帖记录追加到 `state.json`

### Step 6: 报告结果

告诉用户发布结果。如果失败，检查 `references/troubleshooting.md`。

## Examples

### Example 1: 发布图文笔记

**用户输入：** "帮我发一篇小红书笔记，关于 AI 工具推荐"

**AI 执行：**
1. 检查 session → valid ✅
2. 检查频率 → 今日 0 篇 ✅
3. 生成草稿 → 发给用户确认
4. 用户确认 → 随机延迟 → `sau xiaohongshu upload-note`
5. 更新 state.json → 报告成功

### Example 2: 频率限制触发

**用户输入：** "再发一篇"（今日已发 2 篇）

**AI 执行：**
1. 检查频率 → 今日已发 2 篇 ❌
2. 回复："今日已达上限（2篇），明天再发。"

### Example 3: 检查账号状态

**用户输入：** "小红书账号还能用吗"

**AI 执行：**
1. `sau xiaohongshu check --account myaccount`
2. 报告结果

## Error Handling

| 错误 | 原因 | 解决方案 |
|------|------|---------|
| `cookie 失效` | session 过期 | `sau xiaohongshu login --account myaccount` 重新登录 |
| `invalid` | cookie 无效 | 同上 |
| 浏览器启动失败 | chromium 驱动问题 | `patchright install chromium` |
| 上传超时 | 网络问题 | 检查网络，重试一次 |
| 二维码登录失败 | 二维码过期 | 重新执行 login，用新二维码扫码 |
| 图片路径不存在 | 文件被移动 | 确认图片路径 |

## References

- CLI 命令详细参数：`references/cli-contract.md`
- 故障排查：`references/troubleshooting.md`
- sau 项目自带 skill：`~/Projects/social-auto-upload/skills/xiaohongshu-upload/`
