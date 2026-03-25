---
name: audio-timestamp-verifier
version: 1.0.0
description: |
  Verify audio timestamp accuracy by re-transcribing segments and comparing with expected text.
  Designed for NAATI CCL audio processing where Whisper timestamps may drift.

  USE FOR:
  - "verify this timestamp", "check if the timestamp is correct", "验证时间戳"
  - "timestamp drift", "audio timestamp wrong", "时间戳偏移", "转录时间不准"
  - "NAATI audio processing", "Whisper timestamp verification", "whisper 时间戳校验"
  - "re-transcribe segment", "check language switch timestamp", "语言切换时间点"
  - "batch verify timestamps", "find timestamp errors in audio", "批量验证时间戳"

  REPLACES: Manual listening/checking of audio timestamps

  REQUIRES:
  - ffmpeg (audio extraction)
  - Python 3.7+
  - LemonFox API key (set as LEMONFOX_API_KEY env var)
  - python-Levenshtein (optional, for faster similarity)
author: OpenClaw
tags: [audio, transcription, whisper, verification, naati]
dependencies:
  - ffmpeg
  - python3
  - requests
env:
  LEMONFOX_API_KEY: TOYPp7Ug75QTlcRWxOp8mo8GLylB3LaV
---

# Audio Timestamp Verifier

**Pattern: Reviewer** (Google ADK)

## When to Use
Use when you need to **verify that a Whisper transcription timestamp accurately aligns with the expected text** in an audio file. Especially useful for NAATI CCL recordings where language switches (Chinese ↔ English) or long files cause timestamp drift.

**Don't use when:** You need a full transcription from scratch (use LemonFox Whisper directly). This tool is for *verifying* timestamps from an existing transcription.

## Prerequisites
1. Install ffmpeg: `brew install ffmpeg` (macOS) or `sudo apt install ffmpeg` (Linux)
2. Install Python dependencies: `pip3 install requests` (and optionally `pip3 install python-Levenshtein`)
3. Set API key: `export LEMONFOX_API_KEY="your-key-here"`
4. Verify ffmpeg works: `ffmpeg -version`

Precisely verify whether an audio timestamp matches the expected transcription text. Designed for NAATI CCL audio processing workflows where Whisper timestamps may drift, especially at language switches or in long recordings.

## Problem Solved

When transcribing 15-minute audio files with LemonFox Whisper, timestamps aren't always 100% accurate:
- **Language switches** (Chinese ↔ English) cause drift
- **Long audio** accumulates timing errors toward the end
- **Overlapping speech** confuses timestamp alignment

This skill provides a verification workflow: extract a short audio segment around the timestamp, re-transcribe it, and measure text similarity.

## Usage

### Basic Verification

```bash
python3 scripts/verify_timestamp.py \
  --audio /path/to/audio.mp3 \
  --timestamp 125.5 \
  --text "这段话应该在这个时间点" \
  --window 2.0
```

### Output Example

```json
{
  "match_score": 0.87,
  "expected_text": "这段话应该在这个时间点",
  "actual_text": "这段话应该 在这个时间点",
  "segment_start": 123.5,
  "segment_end": 127.5,
  "diagnosis": "HIGH_MATCH",
  "suggestion": "Timestamp is accurate (87% match)",
  "metrics": {
    "char_similarity": 0.92,
    "word_similarity": 0.83,
    "levenshtein_ratio": 0.87
  }
}
```

### Diagnosis Levels

| Score | Diagnosis | Meaning |
|-------|-----------|---------|
| ≥0.85 | `HIGH_MATCH` | Timestamp is accurate |
| 0.70-0.84 | `PARTIAL_MATCH` | Minor drift, check ±0.5s |
| 0.50-0.69 | `LOW_MATCH` | Significant drift, search ±2s |
| <0.50 | `NO_MATCH` | Wrong timestamp or text error |

## Parameters

### Required

- `--audio PATH` - Audio file path (mp3/wav/m4a)
- `--timestamp SECONDS` - Timestamp to verify (decimal seconds)
- `--text TEXT` - Expected transcription text

### Optional

- `--window SECONDS` - Window size before/after timestamp (default: 2.0)
  - Extracts audio from `timestamp - window` to `timestamp + window`
- `--output-dir PATH` - Save extracted audio segment (default: temp)
- `--api-key KEY` - LemonFox API key (default: from env)
- `--verbose` - Show detailed diagnostics

## How It Works

1. **Boundary Handling**
   - If `timestamp - window < 0`, start from 0
   - If `timestamp + window > duration`, end at duration
   - Always extract valid audio range

2. **Audio Extraction**
   ```bash
   ffmpeg -i input.mp3 -ss <start> -t <duration> -c copy segment.mp3
   ```
   - Uses `-c copy` for fast extraction without re-encoding
   - Handles edge cases at audio start/end

3. **Re-Transcription**
   - Sends segment to LemonFox Whisper API
   - Language: auto-detect (supports zh/en mixed)
   - Response format: json with full text

4. **Similarity Calculation**
   - **Character-level**: Levenshtein distance ratio
   - **Word-level**: Token overlap (handles CJK tokenization)
   - **Final score**: Weighted average (char 60%, word 40%)

5. **Diagnosis**
   - Analyzes score and text patterns
   - Suggests correction strategies
   - Detects common issues (silence, crosstalk, drift)

## Edge Cases Handled

### 1. Timestamp at Audio Boundaries

```python
# Start of audio (timestamp = 1.5s, window = 2s)
segment_start = max(0, 1.5 - 2.0)  # → 0.0
segment_end = 1.5 + 2.0  # → 3.5

# End of audio (timestamp = 898s, duration = 900s, window = 2s)
segment_end = min(900, 898 + 2.0)  # → 900.0
```

### 2. Window Exceeds Audio Duration

If the window is larger than the audio file, extract the entire file.

### 3. Empty or Silence Segments

If re-transcription returns empty text:
```json
{
  "match_score": 0.0,
  "diagnosis": "SILENCE",
  "suggestion": "Segment contains no speech - timestamp may be in a pause"
}
```

### 4. Multi-Language Mixing

Text similarity handles mixed Chinese/English:
- Tokenizes CJK characters individually
- Tokenizes English by words
- Compares both levels and weights appropriately

## Advanced Usage

### Batch Verification

```python
from verify_timestamp import TimestampVerifier

verifier = TimestampVerifier(audio_path="long_audio.mp3")

timestamps = [
    (15.2, "你好世界"),
    (47.8, "Hello world"),
    (125.5, "This is a test")
]

results = []
for ts, text in timestamps:
    result = verifier.verify(ts, text, window=2.0)
    results.append(result)
    
# Find all problematic timestamps
issues = [r for r in results if r['match_score'] < 0.85]
```

### Integration with Transcription Pipeline

```python
# After full transcription
transcription = whisper_transcribe("audio.mp3")

# Verify critical segments (e.g., speaker transitions)
for segment in transcription['segments']:
    if segment['is_transition']:
        result = verify_timestamp(
            audio="audio.mp3",
            timestamp=segment['start'],
            text=segment['text'],
            window=1.5
        )
        if result['match_score'] < 0.85:
            print(f"⚠️ Drift detected at {segment['start']}s")
```

## API Reference

### TimestampVerifier Class

```python
class TimestampVerifier:
    def __init__(self, audio_path: str, api_key: str = None):
        """Initialize verifier with audio file."""
        
    def verify(self, timestamp: float, expected_text: str, 
               window: float = 2.0) -> dict:
        """Verify timestamp accuracy.
        
        Returns:
            {
                'match_score': float,
                'expected_text': str,
                'actual_text': str,
                'diagnosis': str,
                'suggestion': str,
                'metrics': dict
            }
        """
        
    def get_audio_duration(self) -> float:
        """Get total audio duration in seconds."""
```

### Similarity Functions

```python
def calculate_similarity(text1: str, text2: str) -> dict:
    """Calculate multi-metric similarity.
    
    Returns:
        {
            'char_similarity': float,  # Levenshtein ratio
            'word_similarity': float,  # Token overlap
            'final_score': float       # Weighted average
        }
    """
```

## Error Handling

| Error | Cause | Solution |
|-------|-------|----------|
| `ffmpeg not found` | ffmpeg not installed | `brew install ffmpeg` (macOS) or `sudo apt install ffmpeg` (Linux) |
| `API key invalid` / `401 Unauthorized` | Missing or wrong LEMONFOX_API_KEY | `export LEMONFOX_API_KEY="your-key"` or use `--api-key` flag |
| `match_score` always 0 | Timestamp in silence/pause | Extend window (`--window 3.0`) or check if timestamp is between sentences |
| `Segment extraction failed` | Audio file path wrong or unsupported format | Verify file path exists; use mp3/wav/m4a format |
| Low match on correct timestamps | Window too small for phrase length | Increase `--window` to 3.0+ for longer phrases |
| `python3: command not found` | Python 3 not installed | Install Python 3.7+: `brew install python3` |

## Troubleshooting

### "ffmpeg not found"
```bash
# macOS
brew install ffmpeg

# Linux
sudo apt install ffmpeg

# Verify
ffmpeg -version
```

### "API key invalid"
Check environment variable or pass explicitly:
```bash
export LEMONFOX_API_KEY="your-key-here"
# OR
python3 scripts/verify_timestamp.py --api-key "your-key-here" ...
```

### Low match scores on correct timestamps

Try adjusting the window:
```bash
# Increase window for longer phrases
--window 3.0

# Decrease for short utterances
--window 1.0
```

### Handling silence/pauses

If the timestamp falls in a pause between sentences, the verifier will detect it:
```json
{
  "diagnosis": "SILENCE",
  "suggestion": "Extend window or check if timestamp is between sentences"
}
```

## Performance

- **Extraction**: ~0.1s (ffmpeg with `-c copy`)
- **Transcription**: ~2-5s (LemonFox API, depends on segment length)
- **Similarity**: <0.01s
- **Total**: ~2-5s per verification

For batch processing, consider:
- Parallel API requests (max 5 concurrent)
- Cache extracted segments if verifying multiple timestamps in same region

## Examples

### Example 1: Chinese Segment

**User says:** "帮我验证一下 45.2 秒这个时间戳，预期文本是'我想预约明天下午两点的门诊'"
**Steps:**
```bash
python3 scripts/verify_timestamp.py \
  --audio "naati_sample.mp3" \
  --timestamp 45.2 \
  --text "我想预约明天下午两点的门诊" \
  --window 2.0
```
**Output:**
```json
{
  "match_score": 0.92,
  "diagnosis": "HIGH_MATCH",
  "suggestion": "Timestamp is accurate"
}
```
**Reply:** "时间戳 45.2s 验证通过，匹配度 92%（HIGH_MATCH），该时间戳准确。"

### Example 2: English Segment

```bash
python3 scripts/verify_timestamp.py \
  --audio "naati_sample.mp3" \
  --timestamp 78.5 \
  --text "I would like to make an appointment for tomorrow at 2pm" \
  --window 2.5
```

### Example 3: Mixed Language

```bash
python3 scripts/verify_timestamp.py \
  --audio "naati_sample.mp3" \
  --timestamp 125.8 \
  --text "这个是 medical certificate，需要你的签名" \
  --window 2.0
```

### Example 4: Low Match (Drift Detected)

```bash
python3 scripts/verify_timestamp.py \
  --audio "naati_sample.mp3" \
  --timestamp 450.0 \
  --text "我们需要确认一下你的个人信息" \
  --window 2.0
```

Output:
```json
{
  "match_score": 0.62,
  "expected_text": "我们需要确认一下你的个人信息",
  "actual_text": "好的，那我们现在开始吧",
  "diagnosis": "LOW_MATCH",
  "suggestion": "Timestamp drift detected. Try searching in range [448.0, 452.0]s"
}
```

## Integration with NAATI Workflow

Typical workflow:

1. **Full transcription**
   ```bash
   # Get full transcription with timestamps
   lemonfox-transcribe naati_audio.mp3 > transcription.json
   ```

2. **Identify critical points**
   - Speaker transitions
   - Language switches
   - Key phrases (names, dates, medical terms)

3. **Verify timestamps**
   ```bash
   # Verify each critical timestamp
   python3 scripts/verify_timestamp.py \
     --audio naati_audio.mp3 \
     --timestamp <critical_timestamp> \
     --text "<critical_text>"
   ```

4. **Adjust if needed**
   - If match_score < 0.85, search in wider window
   - Manually adjust timestamp in transcription file
   - Re-verify until match_score > 0.85

## Dependencies

- **ffmpeg** - Audio extraction
- **Python 3.7+** - Runtime
- **requests** - HTTP client for LemonFox API
- **python-Levenshtein** (optional) - Faster similarity calculation
  ```bash
  pip3 install python-Levenshtein
  ```

## Files

```
audio-timestamp-verifier/
├── SKILL.md                      # This file
├── scripts/
│   ├── verify_timestamp.py       # Main verification script
│   └── text_similarity.py        # Similarity calculation utilities
└── examples/
    └── sample_verification.json  # Sample output
```

## License

MIT

## Support

For issues or questions:
- Check troubleshooting section above
- Review edge cases and examples
- Adjust window size based on your specific audio characteristics
