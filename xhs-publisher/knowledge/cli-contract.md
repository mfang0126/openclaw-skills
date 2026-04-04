# CLI 契约

本 skill 使用两层 CLI：底层 `sau`（social-auto-upload）和上层 `publish.py` 包装脚本。

---

## sau 命令

### 登录

```bash
sau xiaohongshu login --account <account>
```

- 必填参数：`--account`
- 作用：启动小红书登录流程，生成或刷新 cookie
- 如果生成本地二维码图片，agent 应优先把图片展示/发送给用户扫码，而不是只回传路径
- `--account` 传的是用户自定义的 `account_name`，一个名称对应一个账号文件

### 校验 cookie

```bash
sau xiaohongshu check --account <account>
```

- 必填参数：`--account`
- 预期输出：`valid`（可用）或 `invalid`（缺失/失效）

### 上传视频

```bash
sau xiaohongshu upload-video \
  --account <account> \
  --file <video-path> \
  --title "<title>" \
  [--desc "<description>"] \
  [--tags tag1,tag2] \
  [--schedule "YYYY-MM-DD HH:MM"] \
  [--thumbnail <image-path>] \
  [--debug] \
  [--headless | --headed]
```

- 必填参数：`--account`、`--file`、`--title`
- 可选参数：`--desc`、`--tags`、`--schedule`、`--thumbnail`、`--debug`、`--headless`、`--headed`
- 每次命令只支持一个视频文件

### 上传图文

```bash
sau xiaohongshu upload-note \
  --account <account> \
  --images <image-1> [image-2 ...] \
  --title "<title>" \
  [--note "<content>"] \
  [--tags tag1,tag2] \
  [--schedule "YYYY-MM-DD HH:MM"] \
  [--debug] \
  [--headless | --headed]
```

- 必填参数：`--account`、`--images`、`--title`
- 可选参数：`--note`、`--tags`、`--schedule`、`--debug`、`--headless`、`--headed`
- 支持多张图片

### 发布策略

- 不传 `--schedule` → 立即发布
- 传 `--schedule` → 定时发布，时间格式：`YYYY-MM-DD HH:MM`

---

## publish.py 包装脚本

路径：skill 根目录下的 `scripts/publish.py`

包装脚本在调用 sau 之前自动执行人类行为模拟（预热、延迟、刷推荐页），详见 [`knowledge/safety-policy.md`](safety-policy.md)。

### 图文笔记

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

### 视频笔记

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

### 参数说明

| 参数 | 必填 | 说明 |
|------|------|------|
| `--account` | ✅ | 账号名称（从 config.json 读取） |
| `--sau-dir` | ✅ | social-auto-upload 安装路径（从 config.json 读取） |
| `--type` | ✅ | 笔记类型：`note` 或 `video` |
| `--title` | ✅ | 标题 |
| `--note` | 图文时 | 图文正文 |
| `--desc` | 视频时 | 视频简介 |
| `--tags` | 否 | 标签，逗号分隔 |
| `--images` | 图文时 | 图片路径，支持多张，空格分隔（如 `--images img1.png img2.png img3.png`） |
| `--file` | 视频时 | 视频文件路径 |
| `--headed` | 否 | 有头模式（可见浏览器） |
| `--headless` | 否 | 无头模式（默认） |
| `--schedule` | 否 | 定时发布，格式 `YYYY-MM-DD HH:MM` |
| `--skip-warmup` | 否 | 跳过预热（仅测试用） |

### 自动执行的行为模拟

1. 预热（浏览 3-5 篇笔记 + 点赞 1-2 篇，约 2-3 分钟）
2. 发帖前延迟 15-30 秒（模拟打开 App 浏览）
3. 犹豫延迟 5-15 秒（模拟"要不要发"的思考）
4. 调用 sau 执行发布
5. 发帖后延迟 10-25 秒（检查是否发布成功）
6. 顺手刷推荐页 15-40 秒
