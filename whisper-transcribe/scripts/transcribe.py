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
