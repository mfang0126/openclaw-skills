# ASR 配置指南

> 给 `douyin-transcript` skill 的转文字工具参考文档。
>
> **唯一 ASR 引擎**: `mlx-qwen3-asr`（MLX 原生，Apple Silicon 最优，本地运行，中文效果最佳）

---

## MLX Qwen3-ASR

### 模型信息

| 项目 | 值 |
|------|-----|
| HuggingFace ID | `Qwen/Qwen3-ASR-1.7B` |
| 本地缓存路径 | `~/.cache/huggingface/hub/models--Qwen--Qwen3-ASR-1.7B` |
| Python 环境 | `~/mlx-env/bin/python3` |
| CLI 命令 | `~/mlx-env/bin/mlx-qwen3-asr` |
| 安装包 | `mlx-qwen3-asr` (PyPI) |
| 框架 | Apple MLX（不依赖 PyTorch，原生 Apple Silicon） |
| 支持语言 | 中文（普通话+方言）、英文等 30+ 语言 |
| 参数量 | 1.7B |

### 安装

```bash
~/mlx-env/bin/pip install mlx-qwen3-asr
```

### CLI 用法

```bash
# 基本用法（中文）
~/mlx-env/bin/mlx-qwen3-asr \
  --model Qwen/Qwen3-ASR-1.7B \
  --language Chinese \
  --output-dir ./output/ \
  --output-format txt \
  audio.wav

# 带热词注入（推荐，提升专有名词识别率）
HOTWORDS=$(cat ~/.openclaw/skills/douyin-transcript/hotwords.txt | tr '\n' ' ')
~/mlx-env/bin/mlx-qwen3-asr \
  --model Qwen/Qwen3-ASR-1.7B \
  --language Chinese \
  --context "$HOTWORDS" \
  --output-dir ./output/ \
  --output-format txt \
  audio.wav
```

### 热词库

文件路径：`~/.openclaw/skills/douyin-transcript/hotwords.txt`

- 每行一个词（中英文均可）
- 通过 `--context` 参数注入到 ASR，引导模型正确识别专有名词
- **用户可以手动编辑**，添加视频中常见的品牌名、人名、技术术语等
- 示例词：`Claude Code`, `OpenClaw`, `MCP`, `LoRA`, `LangGraph` 等

```bash
# 查看当前热词
cat ~/.openclaw/skills/douyin-transcript/hotwords.txt

# 添加新词
echo "新词" >> ~/.openclaw/skills/douyin-transcript/hotwords.txt
```

### 音频预处理（最佳格式）

```bash
# ffmpeg 提取 16kHz mono WAV（ASR 最佳输入格式）
ffmpeg -i input.mp4 -ar 16000 -ac 1 -vn output.wav
```

参数说明：
- `-ar 16000` — 16kHz 采样率
- `-ac 1` — 单声道（mono）
- `-vn` — 不要视频流

### 性能参考（Apple Silicon）

| 视频时长 | 预计转录时间 |
|---------|------------|
| 1 分钟  | 约 20-40 秒 |
| 10 分钟 | 约 3-8 分钟 |
| 1 小时  | 约 20-50 分钟 |

> MLX 原生推理比 PyTorch/MPS 快约 2-4 倍。

### 常见错误

| 错误 | 原因 | 解决方法 |
|------|------|---------|
| `mlx-qwen3-asr: command not found` | 包未安装 | `~/mlx-env/bin/pip install mlx-qwen3-asr` |
| 转录结果全是英文 | language 参数未指定 | 确认脚本传入了 `--language Chinese` |
| 转录结果乱码 | 音频采样率不匹配 | 确认 ffmpeg 使用了 `-ar 16000` |
| 文字文件为空 | 音频无人声 | 确认视频有人声；纯音乐 ASR 效果差 |
| 某专有名词识别错 | 不在热词库中 | 编辑 `hotwords.txt` 添加该词 |
| 模型首次加载慢 | 从 HuggingFace cache 读取 1.7B 模型 | 正常现象，后续更快 |

---

## 常见问题

### Q: 第一次运行很慢，是正常的吗？

正常。首次运行需要加载 1.7B 模型，约 20-40 秒。后续运行更快（内存/磁盘缓存）。

### Q: 视频有背景音乐，会影响识别吗？

Qwen3-ASR 对人声+背景音乐混合场景有优化，一般不影响。但如果背景音乐非常响，可能降低准确率。

### Q: 能识别方言吗？

支持普通话及多种中文方言。模型会自动检测，无需手动指定方言。

### Q: 某个词总是识别错怎么办？

把这个词添加到热词文件：
```bash
echo "识别错的词" >> ~/.openclaw/skills/douyin-transcript/hotwords.txt
```
再次转录时会自动注入该词作为上下文提示。

### Q: 文字文件在哪里？

```
~/.openclaw/shared/video-transcripts/transcripts/YYYY-MM-DD-{video-name}.txt
```

### Q: 如何更新 mlx-qwen3-asr？

```bash
~/mlx-env/bin/pip install --upgrade mlx-qwen3-asr
```
