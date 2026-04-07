# whisper-transcribe Upgrade Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Upgrade `whisper-transcribe` to a class-based 3-backend ASR skill (MLX Qwen3-ASR → Groq → whisper.cpp) with hotword injection on all backends and SRT/VTT output format support.

**Architecture:** Class-based `ASRBackend` ABC with three concrete implementations. Pure preprocessing and format-conversion helpers kept outside classes. A priority chain iterates backends, falling back silently on failure.

**Tech Stack:** Python 3.10+, `mlx-qwen3-asr` CLI, Groq REST API via `curl`, `whisper-cli` (whisper.cpp), `ffmpeg`

---

## File Map

| File | Action | Responsibility |
|------|--------|----------------|
| `whisper-transcribe/scripts/transcribe.py` | **Rewrite** | All transcription logic — preprocessing, backends, format conversion, CLI |
| `whisper-transcribe/hotwords.txt` | **Create** | User-editable hotword list, one word per line |
| `whisper-transcribe/_meta.json` | **Update** | Mark `whisper-cli` optional, add `mlx` provider |
| `whisper-transcribe/SKILL.md` | **Update** | Document MLX backend, hotwords, `--format`, `--backend` flags |
| `whisper-transcribe/tests/test_transcribe.py` | **Create** | Unit tests for pure functions (format conversion, hotword loading) |

---

## Task 1: Create hotwords.txt

**Files:**
- Create: `whisper-transcribe/hotwords.txt`

- [ ] **Step 1: Create the hotwords file**

```bash
cat > /Users/mingfang/Code/openclaw-skills/whisper-transcribe/hotwords.txt << 'EOF'
Claude Code
OpenClaw
AI Agent
MCP
SaaS
Gartner
Glassdoor
Palo Alto Networks
LoRA
MLX
Whisper
Qwen
GPT
Anthropic
LangGraph
CrewAI
vibes coding
EOF
```

- [ ] **Step 2: Verify**

```bash
cat /Users/mingfang/Code/openclaw-skills/whisper-transcribe/hotwords.txt
```

Expected: 17 lines, one word/phrase per line.

- [ ] **Step 3: Commit**

```bash
cd /Users/mingfang/Code/openclaw-skills
git add whisper-transcribe/hotwords.txt
git commit -m "feat(whisper-transcribe): add hotwords.txt migrated from douyin-transcript"
```

---

## Task 2: Write tests for pure functions

**Files:**
- Create: `whisper-transcribe/tests/__init__.py`
- Create: `whisper-transcribe/tests/test_transcribe.py`

- [ ] **Step 1: Create test directory and empty init**

```bash
mkdir -p /Users/mingfang/Code/openclaw-skills/whisper-transcribe/tests
touch /Users/mingfang/Code/openclaw-skills/whisper-transcribe/tests/__init__.py
```

- [ ] **Step 2: Write failing tests**

Create `whisper-transcribe/tests/test_transcribe.py`:

```python
"""Tests for pure functions in transcribe.py"""
import os
import sys
import tempfile

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..","scripts"))
import transcribe


def test_seconds_to_srt_time_zero():
    assert transcribe._seconds_to_srt_time(0.0) == "00:00:00,000"


def test_seconds_to_srt_time_full():
    # 1h 2m 3.456s
    assert transcribe._seconds_to_srt_time(3723.456) == "01:02:03,456"


def test_seconds_to_vtt_time_zero():
    assert transcribe._seconds_to_vtt_time(0.0) == "00:00:00.000"


def test_seconds_to_vtt_time_full():
    assert transcribe._seconds_to_vtt_time(3723.456) == "01:02:03.456"


def test_segments_to_srt_single():
    segments = [{"start": 0.0, "end": 2.5, "text": "Hello world"}]
    result = transcribe._segments_to_srt(segments)
    assert "1\n" in result
    assert "00:00:00,000 --> 00:00:02,500" in result
    assert "Hello world" in result


def test_segments_to_srt_multiple():
    segments = [
        {"start": 0.0, "end": 2.0, "text": "First"},
        {"start": 2.0, "end": 4.5, "text": "Second"},
    ]
    result = transcribe._segments_to_srt(segments)
    assert "1\n" in result
    assert "2\n" in result
    assert "First" in result
    assert "Second" in result


def test_segments_to_vtt_starts_with_webvtt():
    segments = [{"start": 0.0, "end": 1.0, "text": "Hi"}]
    result = transcribe._segments_to_vtt(segments)
    assert result.startswith("WEBVTT")


def test_segments_to_vtt_uses_dot_separator():
    segments = [{"start": 0.0, "end": 1.5, "text": "Hi"}]
    result = transcribe._segments_to_vtt(segments)
    assert "00:00:00.000 --> 00:00:01.500" in result


def test_segments_to_srt_empty():
    assert transcribe._segments_to_srt([]) == ""


def test_segments_to_vtt_empty():
    result = transcribe._segments_to_vtt([])
    assert result.startswith("WEBVTT")


def test_load_hotwords_valid_file():
    with tempfile.NamedTemporaryFile(mode="w", suffix=".txt", delete=False) as f:
        f.write("Claude Code\nMCP\n\nOpenClaw\n")
        path = f.name
    try:
        original = transcribe.HOTWORDS_PATH
        transcribe.HOTWORDS_PATH = path
        words = transcribe.load_hotwords()
        assert words == ["Claude Code", "MCP", "OpenClaw"]
    finally:
        transcribe.HOTWORDS_PATH = original
        os.unlink(path)


def test_load_hotwords_missing_file():
    original = transcribe.HOTWORDS_PATH
    transcribe.HOTWORDS_PATH = "/nonexistent/hotwords.txt"
    try:
        words = transcribe.load_hotwords()
        assert words == []
    finally:
        transcribe.HOTWORDS_PATH = original
```

- [ ] **Step 3: Run tests — expect failure (module not yet rewritten)**

```bash
cd /Users/mingfang/Code/openclaw-skills/whisper-transcribe
python -m pytest tests/test_transcribe.py -v 2>&1 | head -30
```

Expected: ImportError or AttributeError — `_seconds_to_srt_time`, `_segments_to_srt`, etc. not defined yet.

- [ ] **Step 4: Commit the tests**

```bash
cd /Users/mingfang/Code/openclaw-skills
git add whisper-transcribe/tests/
git commit -m "test(whisper-transcribe): add unit tests for format conversion and hotword loading"
```

---

## Task 3: Rewrite transcribe.py (class-based)

**Files:**
- Modify: `whisper-transcribe/scripts/transcribe.py`

- [ ] **Step 1: Replace the file with the new implementation**

Write `whisper-transcribe/scripts/transcribe.py`:

```python
#!/usr/bin/env python3
"""whisper-transcribe: Audio/video to text via MLX Qwen3-ASR, Groq API, or whisper.cpp"""

import abc
import argparse
import json
import os
import shutil
import subprocess
import sys
import tempfile
import time

GROQ_API = "https://api.groq.com/openai/v1/audio/transcriptions"
WHISPER_MODEL_CACHE = os.path.expanduser("~/.cache/whisper.cpp")
WHISPER_MODEL_NAME = "ggml-large-v3-turbo.bin"
WHISPER_MODEL_URL = (
    f"https://huggingface.co/ggerganov/whisper.cpp/resolve/main/{WHISPER_MODEL_NAME}"
)
MLX_ASR_BIN = os.path.expanduser("~/mlx-env/bin/mlx-qwen3-asr")
MLX_ASR_MODEL = "Qwen/Qwen3-ASR-1.7B"
HOTWORDS_PATH = os.path.expanduser(
    "~/.openclaw/skills/whisper-transcribe/hotwords.txt"
)


# ─── Hotwords ────────────────────────────────────────────────────────────────

def load_hotwords():
    """Load hotwords from file. Returns empty list on failure."""
    try:
        with open(HOTWORDS_PATH) as f:
            return [line.strip() for line in f if line.strip()]
    except Exception:
        return []


# ─── Preprocessing ───────────────────────────────────────────────────────────

def preprocess(input_path):
    """Convert audio/video to 16kHz mono WAV. Returns (path, needs_cleanup)."""
    ext = os.path.splitext(input_path)[1].lower()
    if ext == ".wav":
        return input_path, False
    fd, tmp_path = tempfile.mkstemp(suffix=".wav", prefix="whisper_")
    os.close(fd)
    subprocess.run(
        ["ffmpeg", "-y", "-i", input_path, "-vn", "-acodec", "pcm_s16le",
         "-ar", "16000", "-ac", "1", tmp_path],
        capture_output=True, check=True,
    )
    return tmp_path, True


# ─── Format conversion (Groq verbose_json → SRT/VTT) ────────────────────────

def _seconds_to_srt_time(s):
    h = int(s // 3600)
    m = int((s % 3600) // 60)
    sec = int(s % 60)
    ms = int(round((s % 1) * 1000))
    return f"{h:02d}:{m:02d}:{sec:02d},{ms:03d}"


def _seconds_to_vtt_time(s):
    h = int(s // 3600)
    m = int((s % 3600) // 60)
    sec = int(s % 60)
    ms = int(round((s % 1) * 1000))
    return f"{h:02d}:{m:02d}:{sec:02d}.{ms:03d}"


def _segments_to_srt(segments):
    parts = []
    for i, seg in enumerate(segments, 1):
        start = _seconds_to_srt_time(seg["start"])
        end = _seconds_to_srt_time(seg["end"])
        parts.append(f"{i}\n{start} --> {end}\n{seg['text'].strip()}\n")
    return "\n".join(parts)


def _segments_to_vtt(segments):
    parts = ["WEBVTT", ""]
    for seg in segments:
        start = _seconds_to_vtt_time(seg["start"])
        end = _seconds_to_vtt_time(seg["end"])
        parts.append(f"{start} --> {end}\n{seg['text'].strip()}\n")
    return "\n".join(parts)


# ─── Backends ────────────────────────────────────────────────────────────────

class ASRBackend(abc.ABC):
    @abc.abstractmethod
    def is_available(self):
        """Return True if this backend can be used."""

    @abc.abstractmethod
    def transcribe(self, wav_path, hotwords, language=None, fmt="txt"):
        """Transcribe wav_path and return text in the requested format."""


class MLXQwen3Backend(ASRBackend):
    def is_available(self):
        try:
            r = subprocess.run([MLX_ASR_BIN, "--help"], capture_output=True, timeout=10)
            return r.returncode == 0
        except Exception:
            return False

    def transcribe(self, wav_path, hotwords, language=None, fmt="txt"):
        with tempfile.TemporaryDirectory(prefix="whisper_mlx_") as tmpdir:
            cmd = [
                MLX_ASR_BIN,
                "--model", MLX_ASR_MODEL,
                "--output-dir", tmpdir,
                "--output-format", fmt,
            ]
            if language:
                cmd += ["--language", language]
            if hotwords:
                cmd += ["--context", " ".join(hotwords)]
            cmd.append(wav_path)

            r = subprocess.run(cmd, capture_output=True, text=True)
            if r.returncode != 0:
                raise RuntimeError(r.stderr[:300])

            # MLX names the output after the input file base
            base = os.path.splitext(os.path.basename(wav_path))[0]
            out_file = os.path.join(tmpdir, f"{base}.{fmt}")
            if not os.path.exists(out_file):
                candidates = [f for f in os.listdir(tmpdir) if f.endswith(f".{fmt}")]
                if not candidates:
                    raise RuntimeError(f"No .{fmt} output produced")
                out_file = os.path.join(tmpdir, candidates[0])

            with open(out_file) as f:
                return f.read().strip()


class GroqBackend(ASRBackend):
    def is_available(self):
        return bool(self._get_key())

    def _get_key(self):
        key = os.environ.get("GROQ_API_KEY", "")
        if not key:
            try:
                with open(os.path.expanduser("~/.openclaw/openclaw.json")) as f:
                    key = json.load(f).get("GROQ_API_KEY", "")
            except Exception:
                pass
        return key

    def transcribe(self, wav_path, hotwords, language=None, fmt="txt"):
        key = self._get_key()
        size_mb = os.path.getsize(wav_path) / (1024 * 1024)
        if size_mb > 25:
            raise RuntimeError(f"File too large for Groq ({size_mb:.1f}MB > 25MB)")

        mp3_path = wav_path + "_groq.mp3"
        try:
            subprocess.run(
                ["ffmpeg", "-y", "-i", wav_path, "-codec:a", "libmp3lame",
                 "-b:a", "32k", "-ar", "16000", "-ac", "1", mp3_path],
                capture_output=True, check=True,
            )
            response_format = "verbose_json" if fmt in ("srt", "vtt") else "json"
            cmd = [
                "curl", "-s", "-X", "POST", GROQ_API,
                "-H", f"Authorization: Bearer {key}",
                "-F", f"file=@{mp3_path}",
                "-F", "model=whisper-large-v3",
                "-F", f"response_format={response_format}",
            ]
            if language:
                cmd += ["-F", f"language={language}"]
            if hotwords:
                cmd += ["-F", f"prompt={' '.join(hotwords)}"]
            if response_format == "verbose_json":
                cmd += ["-F", "timestamp_granularities[]=segment"]

            r = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
            data = json.loads(r.stdout)
            if "error" in data:
                raise RuntimeError(str(data["error"]))

            if fmt == "srt":
                return _segments_to_srt(data.get("segments", []))
            if fmt == "vtt":
                return _segments_to_vtt(data.get("segments", []))
            return data.get("text", "").strip()
        finally:
            try:
                os.remove(mp3_path)
            except Exception:
                pass


class WhisperCppBackend(ASRBackend):
    def is_available(self):
        return shutil.which("whisper-cli") is not None

    def transcribe(self, wav_path, hotwords, language=None, fmt="txt"):
        model_path = self._ensure_model()
        with tempfile.TemporaryDirectory(prefix="whisper_cpp_") as tmpdir:
            out_base = os.path.join(tmpdir, "out")
            cmd = [
                "whisper-cli", "-m", model_path, "-f", wav_path,
                "--no-timestamps", "-of", out_base,
            ]
            if fmt == "srt":
                cmd.append("-osrt")
            elif fmt == "vtt":
                cmd.append("-ovtt")
            else:
                cmd.append("-otxt")
            if language:
                cmd += ["-l", language]
            if hotwords:
                cmd += ["--prompt", " ".join(hotwords)]

            r = subprocess.run(cmd, capture_output=True, text=True)
            if r.returncode != 0:
                raise RuntimeError(r.stderr[:300])

            out_file = f"{out_base}.{fmt}"
            if os.path.exists(out_file):
                with open(out_file) as f:
                    return f.read().strip()
            return r.stdout.strip()

    def _ensure_model(self):
        model_path = os.path.join(WHISPER_MODEL_CACHE, WHISPER_MODEL_NAME)
        if os.path.exists(model_path):
            return model_path
        os.makedirs(WHISPER_MODEL_CACHE, exist_ok=True)
        print("[whisper.cpp] Downloading model (~1.5GB)...", file=sys.stderr)
        subprocess.run(["curl", "-L", "-o", model_path, WHISPER_MODEL_URL], check=True)
        return model_path


# ─── Backend registry ────────────────────────────────────────────────────────

BACKENDS = {
    "mlx": MLXQwen3Backend,
    "groq": GroqBackend,
    "whisper": WhisperCppBackend,
}
DEFAULT_CHAIN = ["mlx", "groq", "whisper"]


# ─── Entry point ─────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="Transcribe audio/video to text")
    parser.add_argument("input", help="Audio or video file path")
    parser.add_argument("--language", "-l", help="Language code (zh, en, ja, etc.)")
    parser.add_argument("--local", action="store_true",
                        help="Skip Groq, use MLX → whisper.cpp only")
    parser.add_argument("--backend", choices=list(BACKENDS),
                        help="Force a specific backend")
    parser.add_argument("--format", "-f", choices=["txt", "srt", "vtt"], default="txt",
                        help="Output format (default: txt)")
    parser.add_argument("--output", "-o", help="Output file path (default: stdout)")
    args = parser.parse_args()

    if not os.path.exists(args.input):
        print(f"Error: File not found: {args.input}", file=sys.stderr)
        sys.exit(1)

    print("[preprocess] Preparing audio...", file=sys.stderr)
    audio_path, needs_cleanup = preprocess(args.input)

    hotwords = load_hotwords()
    if hotwords:
        print(f"[hotwords] Loaded {len(hotwords)} words", file=sys.stderr)

    if args.backend:
        chain = [args.backend]
    elif args.local:
        chain = ["mlx", "whisper"]
    else:
        chain = DEFAULT_CHAIN

    start = time.time()
    text = None
    try:
        for name in chain:
            backend = BACKENDS[name]()
            if not backend.is_available():
                print(f"[{name}] not available, skipping", file=sys.stderr)
                continue
            try:
                print(f"[{name}] transcribing...", file=sys.stderr)
                text = backend.transcribe(audio_path, hotwords, args.language, args.format)
                elapsed = time.time() - start
                size_mb = os.path.getsize(audio_path) / (1024 * 1024)
                print(f"[{name}] done in {elapsed:.1f}s | {size_mb:.1f}MB", file=sys.stderr)
                break
            except Exception as e:
                print(f"[{name}] failed: {e}, trying next...", file=sys.stderr)
    finally:
        if needs_cleanup:
            try:
                os.remove(audio_path)
            except Exception:
                pass

    if text is None:
        print("❌ No ASR backend available. Install one of:", file=sys.stderr)
        print("   • MLX Qwen3-ASR: pip install mlx-qwen3-asr  (Apple Silicon)", file=sys.stderr)
        print("   • Groq API:      set GROQ_API_KEY in ~/.openclaw/openclaw.json", file=sys.stderr)
        print("   • whisper.cpp:   brew install whisper-cpp", file=sys.stderr)
        sys.exit(1)

    if args.output:
        with open(args.output, "w") as f:
            f.write(text + "\n")
        print(f"Saved to {args.output}", file=sys.stderr)
    else:
        print(text)


if __name__ == "__main__":
    main()
```

- [ ] **Step 2: Run the tests — expect them to pass now**

```bash
cd /Users/mingfang/Code/openclaw-skills/whisper-transcribe
python -m pytest tests/test_transcribe.py -v
```

Expected output:
```
test_transcribe.py::test_seconds_to_srt_time_zero PASSED
test_transcribe.py::test_seconds_to_srt_time_full PASSED
test_transcribe.py::test_seconds_to_vtt_time_zero PASSED
test_transcribe.py::test_seconds_to_vtt_time_full PASSED
test_transcribe.py::test_segments_to_srt_single PASSED
test_transcribe.py::test_segments_to_srt_multiple PASSED
test_transcribe.py::test_segments_to_vtt_starts_with_webvtt PASSED
test_transcribe.py::test_segments_to_vtt_uses_dot_separator PASSED
test_transcribe.py::test_segments_to_srt_empty PASSED
test_transcribe.py::test_segments_to_vtt_empty PASSED
test_transcribe.py::test_load_hotwords_valid_file PASSED
test_transcribe.py::test_load_hotwords_missing_file PASSED
12 passed
```

If any test fails, fix the implementation before continuing.

- [ ] **Step 3: Verify CLI help works**

```bash
python scripts/transcribe.py --help
```

Expected: argparse help showing `input`, `--language`, `--local`, `--backend`, `--format`, `--output`.

- [ ] **Step 4: Verify error path for missing file**

```bash
python scripts/transcribe.py /nonexistent.wav; echo "exit: $?"
```

Expected: `Error: File not found: /nonexistent.wav` on stderr, exit code 1.

- [ ] **Step 5: Commit**

```bash
cd /Users/mingfang/Code/openclaw-skills
git add whisper-transcribe/scripts/transcribe.py
git commit -m "feat(whisper-transcribe): rewrite to class-based 3-backend architecture with hotwords and format support"
```

---

## Task 4: Update _meta.json

**Files:**
- Modify: `whisper-transcribe/_meta.json`

- [ ] **Step 1: Update the file**

Replace `whisper-transcribe/_meta.json` with:

```json
{
  "name": "whisper-transcribe",
  "version": "2.0.0",
  "author": "King",
  "pattern": "Tool Wrapper",
  "emoji": "🎤",
  "created": "2026-03-29",
  "updated": "2026-04-08",
  "requires": {
    "bins": ["ffmpeg"],
    "modules": []
  },
  "optional": {
    "bins": ["whisper-cli"],
    "modules": ["mlx-qwen3-asr"]
  },
  "providers": ["mlx-qwen3-asr", "groq", "whisper-cpp"],
  "tags": ["transcription", "speech-to-text", "whisper", "mlx", "audio", "video", "srt", "vtt"]
}
```

- [ ] **Step 2: Commit**

```bash
cd /Users/mingfang/Code/openclaw-skills
git add whisper-transcribe/_meta.json
git commit -m "chore(whisper-transcribe): update meta to v2.0.0, add mlx provider, mark whisper-cli optional"
```

---

## Task 5: Update SKILL.md

**Files:**
- Modify: `whisper-transcribe/SKILL.md`

- [ ] **Step 1: Update the SKILL.md**

Replace `whisper-transcribe/SKILL.md` with:

```markdown
---
name: whisper-transcribe
description: |
  Transcribe audio/video to text using the best available ASR backend.
  
  Backend priority: MLX Qwen3-ASR (local, best for Chinese) → Groq API (fast, cloud) → whisper.cpp (local fallback)

  USE FOR:
  - "转文字", "转录", "transcribe this", "speech to text"
  - Any audio file (wav, mp3, m4a, flac, ogg, wma, aac) needs transcription
  - Video file needs transcription (extracts audio first via ffmpeg)
  - Douyin/video downloaded → auto transcribe
  - Need SRT/VTT subtitles from audio/video
  - "这个视频说的什么", "听一下这个音频"

  REPLACES: openai-whisper, openai-whisper-api, mlx-whisper, douyin-transcript (for ASR step)
  REQUIRES: ffmpeg
  OPTIONAL: mlx-qwen3-asr (pip), GROQ_API_KEY, whisper-cli (brew)
version: 2.0.0
user-invocable: true
compatibility:
  - python>=3.10
  - ffmpeg
metadata:
  author: King
  category: media
  tags: [asr, transcript, 转文字, speech-to-text, mlx, groq, whisper, srt, vtt]
  pattern: Tool Wrapper
  openclaw:
    emoji: "🎤"
    requires:
      bins: ["ffmpeg", "python3"]
---

# Whisper Transcribe

**Pattern: Tool Wrapper** — 检测音频/视频 → 预处理 → 选 ASR 后端 → 输出文字/字幕

将音频或视频文件转录为文字。后端优先级：MLX Qwen3-ASR（本地、中文最优）→ Groq API（云端极速）→ whisper.cpp（本地离线）。

## When to Use

触发条件：
- 用户说"转文字"、"转录"、"transcribe"
- 用户发了音频文件（wav/mp3/m4a/flac/ogg）
- 用户发了视频文件（mp4/mov/mkv）需要提取语音内容
- 需要带时间戳的字幕（SRT/VTT 格式）
- "这个视频说的什么"、"听一下这个音频"

不适用：
- TTS（文字转语音）
- 实时流式转录
- 翻译（先转录再单独翻译）

## Quick Start

```bash
# 自动选最优后端，输出纯文字
python3 ~/.openclaw/skills/whisper-transcribe/scripts/transcribe.py /path/to/audio.wav

# 生成 SRT 字幕
python3 ~/.openclaw/skills/whisper-transcribe/scripts/transcribe.py /path/to/video.mp4 --format srt

# 生成 VTT 字幕
python3 ~/.openclaw/skills/whisper-transcribe/scripts/transcribe.py /path/to/video.mp4 --format vtt

# 强制本地（MLX → whisper.cpp，跳过 Groq）
python3 ~/.openclaw/skills/whisper-transcribe/scripts/transcribe.py /path/to/audio.wav --local

# 指定语言
python3 ~/.openclaw/skills/whisper-transcribe/scripts/transcribe.py /path/to/audio.wav --language zh

# 强制指定后端
python3 ~/.openclaw/skills/whisper-transcribe/scripts/transcribe.py /path/to/audio.wav --backend mlx

# 输出到文件
python3 ~/.openclaw/skills/whisper-transcribe/scripts/transcribe.py /path/to/audio.wav --output /tmp/transcript.txt
```

## Instructions

### Step 1: 检测输入
确认文件存在且是支持的格式（wav/mp3/m4a/flac/ogg/wma/aac/mp4/mov/mkv/webm/avi/flv）。

### Step 2: 预处理
- 视频或非 WAV 音频 → ffmpeg 转 16kHz mono WAV（临时文件）
- WAV 文件 → 直接使用

### Step 3: 选择后端
按优先级尝试：
1. **MLX Qwen3-ASR** — `~/mlx-env/bin/mlx-qwen3-asr` 可用时优先使用，中文最优，支持热词
2. **Groq API** — `GROQ_API_KEY` 存在时使用，极速，支持多语言
3. **whisper.cpp** — `whisper-cli` 在 PATH 中时使用，完全离线

### Step 4: 转录
运行 transcribe.py，输出结果到 stdout 或 --output 指定路径。

## Hotwords（热词注入）

热词文件：`~/.openclaw/skills/whisper-transcribe/hotwords.txt`

- 每行一个词，支持中英文
- 三个后端都会使用热词（MLX: `--context`，Groq: `prompt` 参数，whisper.cpp: `--prompt`）
- 读取失败时静默跳过，不影响转录
- 随时可编辑，添加视频中出现的专有名词以提升识别准确率

## Output Formats

| 格式 | 说明 | 用途 |
|------|------|------|
| `txt` | 纯文字，无时间戳（默认） | 文章、笔记 |
| `srt` | SubRip 字幕，含时间戳 | 视频字幕 |
| `vtt` | WebVTT 字幕，含时间戳 | Web 播放器 |

## Prerequisites

必需：
- `ffmpeg`（`brew install ffmpeg`）
- `python3`

任选其一：
- `mlx-qwen3-asr`（`~/mlx-env/bin/pip install mlx-qwen3-asr`）— Apple Silicon 推荐
- `GROQ_API_KEY` — 在 `~/.openclaw/openclaw.json` 配置
- `whisper-cli`（`brew install whisper-cpp`）

## Examples

### Example 1: 抖音视频转文字
**User says:** "帮我下载这个抖音视频然后转文字"
**Steps:**
1. douyin-dl 下载视频
2. 运行 transcribe.py，视频 → ffmpeg 提音频
3. MLX Qwen3-ASR 转录（带热词注入）
**Output:** 转录文字

### Example 2: 生成 SRT 字幕
**User says:** "给这个视频生成字幕 /tmp/talk.mp4"
**Steps:**
1. ffmpeg 提取音频
2. Groq API 返回 verbose_json（含 segments）
3. 转换为 SRT 格式输出
**Output:** SRT 字幕文件

### Example 3: 本地英文播客
**User says:** "transcribe this podcast episode /tmp/podcast.mp3 --local"
**Steps:**
1. ffmpeg 转 WAV
2. MLX → whisper.cpp（跳过 Groq）
**Output:** 英文全文

## Error Handling

| 错误 | 原因 | 解决方案 |
|------|------|---------|
| `File not found` | 路径错误 | 检查路径 |
| `No ASR backend available` | 三个后端都不可用 | 安装至少一个后端（见 Prerequisites） |
| `[mlx] failed: ...` | MLX 转录失败 | 自动 fallback 到 Groq |
| `[groq] failed: ...` | API key 无效或超额度 | 自动 fallback 到 whisper.cpp |
| `ffmpeg not found` | ffmpeg 未安装 | `brew install ffmpeg` |

## Backend Details

### MLX Qwen3-ASR（首选）
- 二进制：`~/mlx-env/bin/mlx-qwen3-asr`
- 模型：`Qwen/Qwen3-ASR-1.7B`（首次运行自动下载）
- 热词：`--context` 参数
- 格式：原生支持 txt/srt/vtt/json

### Groq API（第二）
- 端点：`https://api.groq.com/openai/v1/audio/transcriptions`
- 模型：`whisper-large-v3`
- 免费额度：~8 小时/天
- 文件限制：≤ 25MB（WAV 自动压缩为 MP3 上传）
- 热词：`prompt` 参数
- SRT/VTT：`verbose_json` + 内置转换

### whisper.cpp（离线备选）
- 二进制：`whisper-cli`
- 模型：`ggml-large-v3-turbo`（~1.5GB，首次自动下载到 `~/.cache/whisper.cpp/`）
- 热词：`--prompt` 参数
- 格式：原生 -osrt/-ovtt
```

- [ ] **Step 2: Commit**

```bash
cd /Users/mingfang/Code/openclaw-skills
git add whisper-transcribe/SKILL.md
git commit -m "docs(whisper-transcribe): update SKILL.md for v2 — MLX backend, hotwords, SRT/VTT formats"
```

---

## Task 6: Smoke Test

- [ ] **Step 1: Verify all tests still pass**

```bash
cd /Users/mingfang/Code/openclaw-skills/whisper-transcribe
python -m pytest tests/test_transcribe.py -v
```

Expected: 12 passed.

- [ ] **Step 2: Test MLX backend availability check**

```bash
python3 scripts/transcribe.py --backend mlx /nonexistent.wav 2>&1; echo "exit: $?"
```

Expected: `Error: File not found` (not a backend error — file check happens first).

- [ ] **Step 3: Test with a real audio file using MLX**

Find or create a short test audio file:
```bash
# Generate a 3-second silent WAV for pipeline testing (verifies ffmpeg path but no speech)
python3 -c "
import subprocess, tempfile
with tempfile.NamedTemporaryFile(suffix='.mp3', delete=False) as f:
    path = f.name
subprocess.run(['ffmpeg', '-y', '-f', 'lavfi', '-i', 'sine=frequency=440:duration=3', path], 
               capture_output=True)
print(path)
" 
```

Then run transcribe on it (confirms pipeline doesn't crash):
```bash
python3 scripts/transcribe.py <path_from_above> 2>&1
```

Expected: stderr shows `[preprocess]`, `[hotwords]`, then a backend attempt. Output may be empty or minimal (silence has no speech).

- [ ] **Step 4: Test with a real video or audio that has speech (if available)**

```bash
# Use any mp4/wav on disk that has speech
python3 scripts/transcribe.py ~/Downloads/some_audio.wav 2>&1
# or
python3 scripts/transcribe.py ~/Downloads/some_video.mp4 --format srt 2>&1
```

Expected: transcription text on stdout, backend info on stderr.

- [ ] **Step 5: Final commit if any fixes were needed**

```bash
cd /Users/mingfang/Code/openclaw-skills
git status
# only commit if there are changes from smoke test fixes
git add -p
git commit -m "fix(whisper-transcribe): smoke test corrections"
```

---

## Self-Review

**Spec coverage check:**

| Spec requirement | Task |
|-----------------|------|
| Class-based ASRBackend architecture | Task 3 |
| MLX Qwen3-ASR backend (priority 1) | Task 3 |
| Groq API backend (priority 2) | Task 3 |
| whisper.cpp backend (priority 3) | Task 3 |
| Hotwords — all backends | Task 3 |
| Hotwords file at `~/.openclaw/skills/whisper-transcribe/hotwords.txt` | Task 1 |
| Video/audio → 16kHz mono WAV preprocessing | Task 3 |
| `--format txt\|srt\|vtt` | Task 3 |
| Groq verbose_json → SRT/VTT conversion | Task 3 |
| `--backend mlx\|groq\|whisper` | Task 3 |
| `--local` skips Groq | Task 3 |
| stdout/stderr separation | Task 3 |
| All-backends-fail error message | Task 3 |
| CLI backwards compatibility | Task 3 |
| `_meta.json` updated | Task 4 |
| `SKILL.md` updated | Task 5 |

**No gaps found.**
