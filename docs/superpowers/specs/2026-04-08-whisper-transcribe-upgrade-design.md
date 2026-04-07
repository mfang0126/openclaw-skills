# whisper-transcribe 升级设计

**日期:** 2026-04-08  
**状态:** 已审阅，待实施  
**范围:** 升级现有 `whisper-transcribe` skill，添加 MLX Qwen3-ASR 作为首选后端，支持热词注入和字幕格式输出

---

## 背景

现有 `whisper-transcribe` 在 `/Users/mingfang/Code/openclaw-skills/whisper-transcribe/` 已有完整实现，后端为 Groq API → whisper.cpp。升级目标：

1. 添加 MLX Qwen3-ASR 作为优先级最高的后端（本地、中文最优）
2. 热词注入覆盖所有后端
3. 支持 SRT/VTT 字幕格式输出
4. 代码重构为 class-based 架构，职责清晰，便于扩展

---

## 设计

### 1. 整体架构

```
transcribe.py
├── preprocess(input_path) → tmp_wav_path   # 音视频 → 16kHz mono WAV
├── load_hotwords() → list[str]             # 读 hotwords.txt
├── ASRBackend (abstract base class)
│   ├── is_available() → bool
│   └── transcribe(wav_path, hotwords, language, fmt) → str
├── MLXQwen3Backend     # 优先级 1
├── GroqBackend         # 优先级 2
├── WhisperCppBackend   # 优先级 3
└── main()              # 选后端 → 转录 → stdout / --output 文件
```

**单一职责：** 只做转录，输出文字到 stdout 或指定文件。不存档、不管理目录。

### 2. 音频预处理

```python
def preprocess(input_path) -> tmp_wav_path:
    # 视频 (.mp4/.mov/.mkv/.webm/...) → 提取音频
    # 音频已是 16kHz mono WAV → 直接返回原路径（跳过转换）
    # 其他音频 (.mp3/.m4a/.flac/...) → 重采样
    # 输出: /tmp/whisper_XXXXXX.wav（随机后缀避冲突）
    # 参数: -ar 16000 -ac 1 -vn
```

临时文件在 `main()` 结束时统一清理（成功/失败都清理）。

**为什么 16kHz mono WAV：** ASR 模型最优输入格式，质量无损，体积适中。Groq 上传前额外压缩为 MP3（网络传输优化，在 GroqBackend 内部处理）。

### 3. 热词

**文件路径：** `~/.openclaw/skills/whisper-transcribe/hotwords.txt`  
（从 `douyin-transcript/hotwords.txt` 迁移现有词库）

- 每行一个词，支持中英文
- 读取失败 → 静默忽略，继续转录
- 热词为空 → 各后端省略对应参数

各后端注入方式：

| 后端 | 注入参数 |
|------|---------|
| MLX Qwen3-ASR | `--context "<hotwords joined by space>"` |
| Groq API | `prompt` 字段（POST body） |
| whisper.cpp | `--prompt "<hotwords>"` |

### 4. 后端实现

#### MLXQwen3Backend（优先级 1）

```
is_available: ~/mlx-env/bin/mlx-qwen3-asr --help 成功（exit 0）
transcribe:
  - 直接传 WAV 文件
  - 参数: --model Qwen/Qwen3-ASR-1.7B --language <lang> --context <hotwords>
  - 格式: --output-format txt|srt|vtt
  - 输出到临时目录，读取结果后删除
优势: 中文最优，本地运行，原生支持所有输出格式
```

#### GroqBackend（优先级 2）

```
is_available: GROQ_API_KEY 存在（env 或 ~/.openclaw/openclaw.json）
transcribe:
  - WAV → 压缩 MP3（16kHz 32kbps）→ POST /v1/audio/transcriptions
  - txt 格式: response_format=json，取 .text
  - srt/vtt 格式: response_format=verbose_json（含 segments），转换为 SRT/VTT
  - hotwords 通过 prompt 参数传入
  - 临时 MP3 文件用完即删
优势: 极速（2分钟音频 < 1s），无本地 GPU 依赖
限制: 文件 ≤ 25MB（处理后的 WAV 超限时回退下一后端）
```

#### WhisperCppBackend（优先级 3）

```
is_available: which whisper-cli 成功
transcribe:
  - whisper-cli -m <model> -f <wav> --no-timestamps
  - srt 格式: -osrt；vtt 格式: -ovtt
  - hotwords: --prompt "<hotwords>"
  - 模型: ggml-large-v3-turbo（不存在时自动下载到 ~/.cache/whisper.cpp/）
优势: 完全离线，无 API 依赖
```

### 5. 输出格式

```bash
--format txt    # 默认：纯文字，无时间戳，stdout
--format srt    # SubRip 字幕，含时间戳
--format vtt    # WebVTT 字幕，含时间戳
```

格式支持矩阵：

| 格式 | MLX | Groq | whisper.cpp |
|------|-----|------|-------------|
| txt  | ✅ 原生 | ✅ 原生 | ✅ 原生 |
| srt  | ✅ 原生 | ⚙️ verbose_json 转换 | ✅ -osrt |
| vtt  | ✅ 原生 | ⚙️ verbose_json 转换 | ✅ -ovtt |

Groq SRT/VTT 转换逻辑内置于 `GroqBackend.transcribe()`，输出格式与其他后端一致。

### 6. CLI 接口

完全兼容现有用法，新增 `--format` 和 `--backend`：

```bash
# 基本用法
python3 transcribe.py <file>

# 选项
--language zh|en|ja|...      # 语言（默认 auto）
--local                      # 跳过 Groq，MLX → whisper.cpp
--backend mlx|groq|whisper   # 强制指定后端
--format txt|srt|vtt         # 输出格式（默认 txt）
--output /path/to/file       # 输出到文件（默认 stdout）
```

**stdout/stderr 分离：**
- `stdout` — 纯转录内容（方便管道和脚本捕获）
- `stderr` — 进度、后端选择、耗时信息

### 7. 错误处理

**单个后端失败：** stderr 打印 `[mlx] failed: <reason>, trying groq...`，静默 fallback。

**全部后端不可用：**
```
❌ No ASR backend available. Install one of:
   • MLX Qwen3-ASR: pip install mlx-qwen3-asr  (Apple Silicon)
   • Groq API:      set GROQ_API_KEY in ~/.openclaw/openclaw.json
   • whisper.cpp:   brew install whisper-cpp
```

---

## 文件变化

| 文件 | 操作 |
|------|------|
| `scripts/transcribe.py` | 重写（class-based，现有逻辑全保留） |
| `hotwords.txt` | 新增（迁移 douyin-transcript 热词库） |
| `SKILL.md` | 更新（加 MLX 后端，hotwords 说明，格式选项） |
| `_meta.json` | 微调（移除强制 whisper-cli 依赖，改为可选） |

`douyin-transcript`（已在 `.archive/`）不需要额外操作。

---

## 不在范围内

- 存档/保存到固定目录（调用方负责）
- 实时流式转录
- 说话人分离（diarization）
- 批量处理（目录输入）
- 翻译功能
