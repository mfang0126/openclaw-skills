# Quick Start Guide

## Installation (< 2 minutes)

### 1. Install Dependencies

```bash
# macOS
brew install ffmpeg

# Ubuntu/Debian
sudo apt-get update && sudo apt-get install -y ffmpeg

# Install Python dependencies
pip3 install requests python-Levenshtein
```

### 2. Set API Key

```bash
export LEMONFOX_API_KEY="TOYPp7Ug75QTlcRWxOp8mo8GLylB3LaV"
```

### 3. Test Installation

```bash
cd ~/.openclaw/skills/audio-timestamp-verifier
./test_install.sh
```

You should see: ✓ All critical checks passed!

## First Verification

### Create a test scenario

For this example, you'll need an audio file. If you have a NAATI CCL recording:

```bash
cd ~/.openclaw/skills/audio-timestamp-verifier

python3 scripts/verify_timestamp.py \
  --audio /path/to/your/recording.mp3 \
  --timestamp 45.5 \
  --text "你好，这是测试文本" \
  --api-key "$LEMONFOX_API_KEY"
```

### Understanding the output

**Good match (similarity ≥ 0.70):**
```json
{
  "status": "success",
  "similarity": 0.951,
  "match": true,
  "diagnosis": "Excellent match. Timestamp is accurate."
}
```
✅ Your timestamp is correct!

**Poor match (similarity < 0.70):**
```json
{
  "status": "success",
  "similarity": 0.42,
  "match": false,
  "diagnosis": "Poor match. Significant timestamp drift likely.",
  "suggestion": "Check timestamps ±5-10 seconds around this point."
}
```
❌ Timestamp needs adjustment. The audio at this timestamp doesn't match your expected text.

## Common Workflows

### 1. Single Timestamp Verification

```bash
python3 scripts/verify_timestamp.py \
  --audio recording.mp3 \
  --timestamp 120.5 \
  --text "Expected text here"
```

### 2. Wider Search Window

If you're not sure exactly where the text is:

```bash
python3 scripts/verify_timestamp.py \
  --audio recording.mp3 \
  --timestamp 120.0 \
  --text "Expected text" \
  --window 5.0
```

This checks from 115.0s to 125.0s instead of the default ±2s.

### 3. Verify Multiple Timestamps

Create a file `timestamps.txt`:
```
45.5|你好，欢迎
78.2|Good morning
120.0|这是第三段
```

Then run:
```bash
while IFS='|' read -r timestamp text; do
  echo "Checking $timestamp..."
  python3 scripts/verify_timestamp.py \
    --audio recording.mp3 \
    --timestamp "$timestamp" \
    --text "$text"
done < timestamps.txt
```

### 4. Batch Verify Entire Transcription

If you have a full transcription JSON from LemonFox:

```bash
# Extract segments and verify each
cat transcription.json | \
  jq -r '.segments[] | [.start, .text] | @tsv' | \
  while IFS=$'\t' read -r ts text; do
    python3 scripts/verify_timestamp.py \
      --audio recording.mp3 \
      --timestamp "$ts" \
      --text "$text" | \
      jq -r 'if .match then "✓" else "✗ " + .diagnosis end'
  done
```

## Troubleshooting

### Error: "ffmpeg not found"

```bash
# Install ffmpeg first
brew install ffmpeg  # macOS
# or
sudo apt-get install ffmpeg  # Linux
```

### Error: "No module named 'requests'"

```bash
pip3 install requests
```

### Error: "Audio file not found"

Make sure the path is correct:
```bash
# Use absolute path
python3 scripts/verify_timestamp.py --audio /Users/you/recording.mp3 ...

# Or relative path from current directory
python3 scripts/verify_timestamp.py --audio ./recording.mp3 ...
```

### API Error: "Unauthorized" or rate limit

1. Check your API key is set:
   ```bash
   echo $LEMONFOX_API_KEY
   ```

2. If hitting rate limits, add delays between requests:
   ```bash
   sleep 1  # Wait 1 second between verifications
   ```

## Next Steps

- **Full documentation:** [SKILL.md](SKILL.md)
- **More examples:** [EXAMPLES.md](EXAMPLES.md)
- **Test similarity module:** `python3 scripts/text_similarity.py "text1" "text2" --verbose`

## Tips for NAATI CCL

1. **Focus on language switches** - Verify timestamps where the speaker switches from Chinese to English or vice versa

2. **Check dialogue segments** - When verifying speaker B's first response, use wider windows (3-4s)

3. **Back-half verification** - In 15-minute recordings, verify more timestamps in the second half (minutes 8-15) where drift accumulates

4. **Batch check suspects** - If you notice timestamps getting progressively off, verify every 30 seconds to find where drift starts

Example NAATI workflow:
```bash
# Check key transition points
for timestamp in 0.0 120.0 240.0 360.0 480.0 600.0; do
  python3 scripts/verify_timestamp.py \
    --audio naati_recording.mp3 \
    --timestamp $timestamp \
    --text "$(extract_text_at_timestamp $timestamp)" \
    --window 3.0
done
```

## Support

For issues or questions:
1. Check [SKILL.md](SKILL.md) for detailed documentation
2. Run `./test_install.sh` to verify setup
3. Use `--verbose` flag for detailed diagnostics
