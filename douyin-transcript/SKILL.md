---
name: douyin-transcript
description: |
  当用户分享抖音视频链接并要求转文字、提取文字、转录、听写时，
  执行完整的 下载→提取音频→本地语音识别→存档 Pipeline。

  Triggers（必须同时满足两个条件）:
  1. 抖音链接: v.douyin.com, douyin.com, 抖音链接
  2. 转文字意图: "转文字", "提取文字", "听写", "转录", "transcript",
     "说了什么", "讲了什么", "帮我记录", "speech to text", "文字稿"

  Does NOT trigger:
  - 只有抖音链接但没有转文字意图（仅下载用 douyin-dl skill）
  - YouTube、Bilibili、Instagram 等其他平台（用其他 skill）
  - 用户只问"这个视频讲什么"不提转文字（对话式回答即可）
  - 已有音频/文字文件要翻译（不是 ASR 任务）

  Output: 文字稿 TXT 文件，保存至 ~/.openclaw/shared/video-transcripts/transcripts/
version: 2.0.0
user-invocable: true
compatibility:
  - python>=3.10
  - ffmpeg
  - mlx-qwen3-asr (pip)
metadata:
  author: OpenClaw
  category: media
  tags: [asr, douyin, transcript, 抖音, 转文字, speech-to-text, mlx]
  pattern: Pipeline
  openclaw:
    emoji: "🎙️"
    requires:
      bins: ["ffmpeg", "python3"]
      skills: ["douyin-dl"]
---

# 抖音视频转文字 (Douyin Transcript)

**Pattern: Pipeline** — douyin-dl 下载 → ffmpeg 提音频 → MLX Qwen3-ASR 本地转文字 → 存档

---

## Instructions

### Step 0 — 前置检查

在开始之前，检查：
- `~/.openclaw/config.json` 里有没有 `tikhub_api_token`（douyin-dl 需要）
- `~/mlx-env/bin/python3` 存在
- `ffmpeg` 已安装 (`which ffmpeg`)
- `mlx-qwen3-asr` 已安装：`~/mlx-env/bin/mlx-qwen3-asr --help`

如果有缺失，告知用户并停止。

---

### Step 1 — 下载视频（调用 douyin-dl skill）

从用户消息里提取抖音链接，然后下载视频到转文字专用目录：

```bash
DOUYIN_DL_SCRIPT="$(find ~/.openclaw/skills/douyin-dl/scripts -name '*.py' | head -1)"
VIDEOS_DIR="$HOME/.openclaw/shared/video-transcripts/videos"
mkdir -p "$VIDEOS_DIR"

~/mlx-env/bin/python3 "$DOUYIN_DL_SCRIPT" "<URL>" --download --output-dir "$VIDEOS_DIR"
```

⛔ **Gate**: 下载成功后才继续。如果失败，检查 API token 是否有效。

记录下载到的文件路径（`downloaded_file`）。

---

### Step 2 — 提取音频（ffmpeg）

```bash
AUDIO_FILE="${downloaded_file%.mp4}.wav"
ffmpeg -i "$downloaded_file" -ar 16000 -ac 1 -vn -y "$AUDIO_FILE"
```

参数说明：
- `-ar 16000` — 16kHz 采样率（ASR 最佳格式）
- `-ac 1` — 单声道
- `-vn` — 不要视频流

⛔ **Gate**: ffmpeg 必须成功退出（exit code 0）才继续。

---

### Step 3 — 语音识别（MLX Qwen3-ASR + 热词注入）

运行 transcribe.sh：

```bash
SKILL_DIR="$HOME/.openclaw/skills/douyin-transcript"
bash "$SKILL_DIR/scripts/transcribe.sh" "$downloaded_file"
```

脚本会：
1. 用 ffmpeg 提取 16kHz mono WAV
2. 从 `hotwords.txt` 读取热词，通过 `--context` 注入 ASR 引导识别
3. 调用 `mlx-qwen3-asr`（MLX 原生，Apple Silicon 最优）

> 💡 **热词库**: `~/.openclaw/skills/douyin-transcript/hotwords.txt`
> 用户可以手动编辑此文件，每行一个词，添加专有名词/产品名/人名等，
> 提升 ASR 对这些词的识别准确率。

⛔ **Gate**: 文字文件必须生成且非空才算成功。

---

### Step 4 — 存档与汇报

1. 确认文字文件已生成到 `~/.openclaw/shared/video-transcripts/transcripts/`
2. 读取文字文件前 200 字，向用户展示预览
3. 告知完整文件路径

**回复格式示例：**
```
✅ 转文字完成！

📄 文件：~/.openclaw/shared/video-transcripts/transcripts/2026-04-03-闲田的作品.txt

📝 内容预览：
为什么说现在是最不对称的创业时机？因为...（前200字）

⏱️ 耗时：约 45 秒
```

---

## 热词库说明

热词文件路径：`~/.openclaw/skills/douyin-transcript/hotwords.txt`

- 每行一个词
- 支持中英文混合
- 常见科技/AI 词汇已预置（如 Claude Code、OpenClaw、MCP、LoRA 等）
- 用户可以随时编辑，添加视频里出现的专有名词，提升识别准确率
- 例如：遇到某个品牌名老是识别错，直接加进去即可

---

## Examples

### 成功案例 1：标准抖音短链
**Input**: "帮我把这个视频转成文字 https://v.douyin.com/FUF8RnRuBH4/"
**步骤**:
1. 提取链接 → `https://v.douyin.com/FUF8RnRuBH4/`
2. douyin-dl 下载 → `~/.openclaw/shared/video-transcripts/videos/douyin_7351234567890.mp4`
3. ffmpeg 提取 → `.wav`（16kHz mono）
4. MLX Qwen3-ASR 转录（带热词注入）→ `2026-04-03-闲田的作品.txt`
**Output**: 显示文字预览 + 文件路径

---

### 成功案例 2：带完整文本的分享
**Input**:
```
6.94 复制打开抖音，看看【闲田的作品】⚡️ 为什么说现在是"最不对称"的创业时机？
https://v.douyin.com/FUF8RnRuBH4/
```
**步骤**: 同上。提取 `v.douyin.com` 链接即可。
**Output**: 转文字成功

---

### Edge Case：只有链接，没有转文字意图
**Input**: "https://v.douyin.com/FUF8RnRuBH4/"
**Action**: 不触发此 skill。由 douyin-dl 处理（提供下载选项）。
如果用户随后说"帮我转文字"，才触发此 skill。

---

### Edge Case：视频很长（>10分钟）
**Input**: "这个1小时的视频帮我转文字 https://v.douyin.com/xxx/"
**Action**: 正常执行，但提醒用户：
- MLX Qwen3-ASR 支持长音频，但耗时较长
- 1小时视频大约需要 5-15 分钟
- 文字文件会自动分段

---

## Output Format

```
~/.openclaw/shared/video-transcripts/
├── videos/
│   └── douyin_{modal_id}.mp4
└── transcripts/
    └── YYYY-MM-DD-{video-title}.txt
```

文字文件内容示例：
```
为什么说现在是最不对称的创业时机？

因为在过去，如果你想做一款产品，你需要一个团队...
（连续正文，无时间戳）
```

---

## Troubleshooting

| 症状 | 原因 | 解决方法 |
|------|------|---------|
| `tikhub_api_token` 缺失 | 未配置 TikHub token | 在 `~/.openclaw/config.json` 添加 token |
| `No video URL found` | 视频是直播或图集 | 抖音直播/图集不支持，告知用户 |
| ffmpeg 失败 | 视频文件损坏 | 重新下载，或检查磁盘空间 |
| `mlx-qwen3-asr: command not found` | 包未安装 | `~/mlx-env/bin/pip install mlx-qwen3-asr` |
| ASR 输出乱码/全是英文 | 模型加载失败 | 检查 mlx-env 是否完好，重新安装 mlx-qwen3-asr |
| 文字文件为空 | 音频静音或纯音乐 | 确认视频有人声；纯音乐视频 ASR 效果差 |
| 转文字速度慢 | 首次加载模型 | 正常现象；1分钟视频约 30-60 秒，后续更快 |
| 某专有名词识别错 | 热词库未包含 | 编辑 `hotwords.txt` 添加该词 |

---

## References
- ASR 配置说明 → `{skillDir}/references/asr-setup.md`
- 热词库 → `{skillDir}/hotwords.txt`
- 现有视频/文字档案 → `~/.openclaw/shared/video-transcripts/README.md`
- 下载 skill 详情 → `~/.openclaw/skills/douyin-dl/SKILL.md`
