# Audio Timestamp Verifier

> Precision validation for audio transcription timestamps

Verify that timestamps in Whisper transcriptions actually match the spoken content. Essential for NAATI CCL and other bilingual audio processing where timestamp accuracy matters.

## Quick Start

```bash
# Install dependencies
pip3 install -r requirements.txt

# Verify a timestamp
export LEMONFOX_API_KEY="your-api-key"

python3 scripts/verify_timestamp.py \
  --audio recording.mp3 \
  --timestamp 45.5 \
  --text "Expected text at this timestamp"
```

## What It Does

1. **Extracts** a small audio segment around the timestamp (±2 seconds by default)
2. **Re-transcribes** just that segment via LemonFox Whisper API
3. **Compares** the new transcription with your expected text
4. **Reports** similarity score + diagnosis

## Why You Need This

Whisper timestamps aren't perfect. Common issues:

- ❌ **Language switching** (中文 ↔ English) causes drift
- ❌ **Long audio** accumulates errors in the second half
- ❌ **Overlapping speech** confuses timestamp assignment
- ❌ **Background noise** shifts segment boundaries

This tool catches those problems before they mess up your subtitle sync or audio analysis.

## Installation

See [SKILL.md](SKILL.md) for full installation instructions.

**Quick version:**

```bash
brew install ffmpeg  # or: apt-get install ffmpeg
pip3 install requests python-Levenshtein
```

## Documentation

- **[SKILL.md](SKILL.md)** - Complete documentation
- **[EXAMPLES.md](EXAMPLES.md)** - Usage examples & workflows
- **[scripts/verify_timestamp.py](scripts/verify_timestamp.py)** - Main verification tool
- **[scripts/text_similarity.py](scripts/text_similarity.py)** - Similarity calculator

## Example Output

```json
{
  "status": "success",
  "timestamp": 45.5,
  "similarity": 0.951,
  "match": true,
  "diagnosis": "Excellent match. Timestamp is accurate.",
  "expected_text": "你好，这是测试",
  "actual_text": "你好这是测试",
  "metrics": {
    "levenshtein_similarity": 0.944,
    "char_overlap": 0.966,
    "word_overlap": 0.966
  }
}
```

## Key Features

✅ **Multi-language support** - CJK-aware text comparison  
✅ **Edge case handling** - Timestamps near start/end of audio  
✅ **Detailed diagnostics** - Know if it's drift or transcription variance  
✅ **Batch processing** - Verify entire transcription files  
✅ **JSON output** - Easy integration into pipelines  

## Common Use Cases

### Verify suspicious timestamps

```bash
python3 scripts/verify_timestamp.py \
  --audio naati.mp3 \
  --timestamp 420.0 \
  --text "这句话应该在这里" \
  --window 3.0
```

### Batch verify all segments

```bash
cat transcription.json | jq -r '.segments[] | [.start, .text] | @tsv' | \
while IFS=$'\t' read -r ts text; do
  python3 scripts/verify_timestamp.py --audio file.mp3 --timestamp "$ts" --text "$text"
done
```

### Check language switches

```bash
# Bilingual segment at 78.2 seconds
python3 scripts/verify_timestamp.py \
  --audio dialogue.mp3 \
  --timestamp 78.2 \
  --text "Good morning, 你好" \
  --verbose
```

## Similarity Thresholds

| Score | Meaning | Action |
|-------|---------|--------|
| ≥ 0.90 | Excellent match | ✅ Timestamp accurate |
| 0.70-0.89 | Good match | ✅ Likely correct |
| 0.50-0.69 | Partial match | ⚠️ Check ±2-3 seconds |
| 0.30-0.49 | Poor match | ❌ Check ±5-10 seconds |
| < 0.30 | No match | ❌ Manual review needed |

## Requirements

- **Python 3.7+**
- **ffmpeg** - Audio extraction
- **LemonFox API key** - Transcription service
- **requests** - HTTP client
- **python-Levenshtein** (optional but recommended) - Fast similarity

## License

MIT

## Credits

Built for NAATI CCL audio processing workflows. Works with any Whisper transcription that needs timestamp validation.
