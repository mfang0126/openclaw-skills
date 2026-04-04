# 发布流程

## Step 1: 检查前提条件

1. 从 config.json 读取 account 和 sauDir
2. 激活虚拟环境并检查 session：
   ```bash
   source <sauDir>/.venv/bin/activate && sau xiaohongshu check --account <account>
   ```
   - `valid` → 继续
   - `invalid` → 告诉用户需要重新登录，提供登录命令

3. 读取 skill 根目录下的 `state.json`，检查今日已发数量和上次发帖时间
   - 频率限制规则详见 [`knowledge/safety-policy.md`](knowledge/safety-policy.md)
   - If 今日已发 ≥ 5 → 检查是否进入**超发模式**（见 safety-policy.md）
   - If 距上次发帖 < 2 小时 → 拒绝，说明原因
   - If 当前时间在 00:00-06:00 → 拒绝，说明原因

## Step 2: 生成草稿

根据用户提供的内容生成草稿。风格要求详见 [`knowledge/content-guidelines.md`](knowledge/content-guidelines.md)。

- **图文笔记**：标题（≤20字）+ 正文（小红书风格，emoji + 分段）+ 标签（3-8个）+ 图片
- **视频笔记**：标题 + 简介 + 标签 + 视频文件

## Step 3: 人审确认（强制）

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
- 用户取消 → 停止，不执行任何操作

## Step 4: 安全发帖

使用 `scripts/publish.py` 包装脚本执行发帖。命令格式详见 [`knowledge/cli-contract.md`](knowledge/cli-contract.md)。

**图文笔记：**
```bash
python3 ./scripts/publish.py \
  --account <从 config.json 读取> \
  --sau-dir <从 config.json 读取> \
  --type note \
  --title "<标题>" \
  --note "<正文>" \
  --tags <标签1>,<标签2> \
  --images <图片路径> \
  --headed
```

**视频笔记：**
```bash
python3 ./scripts/publish.py \
  --account <从 config.json 读取> \
  --sau-dir <从 config.json 读取> \
  --type video \
  --title "<标题>" \
  --desc "<简介>" \
  --tags <标签1>,<标签2> \
  --file <视频路径> \
  --headed
```

**总耗时预期：** 3-6 分钟（包含预热和行为模拟延迟）。

## Step 5: 更新状态

将本次发帖记录追加到 skill 根目录下的 `state.json`。状态格式见 [`knowledge/safety-policy.md`](knowledge/safety-policy.md)。

## Step 6: 报告结果

告诉用户发布结果：
- **成功** → 报告标题、类型、发布时间
- **失败** → 参考 [`knowledge/troubleshooting.md`](knowledge/troubleshooting.md) 排查，提供解决方案

---

## Examples

### Example 1: 发布图文笔记

**用户输入：** "帮我发一篇小红书笔记，关于 AI 工具推荐"

**AI 执行：**
1. 从 config.json 读取 account 和 sauDir
2. 检查 session → valid ✅
3. 检查频率 → 今日 0 篇 ✅
4. 生成草稿 → 发给用户确认
5. 用户确认 → `publish.py` 执行（含预热）→ 成功
6. 更新 state.json → 报告成功

### Example 2: 频率限制触发

**用户输入：** "再发一篇"（今日已发 5 篇）

**AI 执行：**
1. 检查频率 → 今日已发 5 篇 ❌
2. 进入超发模式 → 发出风险警告 → 等待用户确认
3. 用户确认 → 执行 / 用户取消 → 停止

### Example 3: 检查账号状态

**用户输入：** "小红书账号还能用吗"

**AI 执行：**
1. 从 config.json 读取 account
2. `sau xiaohongshu check --account <account>`
3. 报告结果
