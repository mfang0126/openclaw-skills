"""Tests for pure functions in transcribe.py"""
import os
import sys
import tempfile

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "scripts"))
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
