# Usage Guide - Audio Timestamp Verifier

## Real-World Workflow

### 1. Full NAATI Audio Transcription

```bash
# Step 1: Transcribe entire 15-minute audio
curl -X POST https://api.lemonfox.ai/v1/audio/transcriptions \
  -H "Authorization: Bearer TOYPp7Ug75QTlcRWxOp8mo8GLylB3LaV" \
  -F "file=@naati_audio.mp3" \
  -F "model=whisper-1" \
  -F "response_format=verbose_json" \
  -F "timestamp_granularities[]=segment" \
  > full_transcription.json
```

### 2. Identify Critical Timestamps

Parse `full_transcription.json` and identify:
- Speaker transitions
- Language switches (中文 ↔ English)
- Key terms (names, dates, medical terms)
- Long segments (>30s) that might have drift

### 3. Verify Critical Timestamps

```bash
# Set up environment
export LEMONFOX_API_KEY="TOYPp7Ug75QTlcRWxOp8mo8GLylB3LaV"
cd ~/.openclaw/skills/audio-timestamp-verifier

# Verify each critical timestamp
python3 scripts/verify_timestamp.py \
  --audio naati_audio.mp3 \
  --timestamp 45.2 \
  --text "我想预约明天下午两点的门诊" \
  --window 2.0 \
  --verbose \
  > verification_45.2s.json

python3 scripts/verify_timestamp.py \
  --audio naati_audio.mp3 \
  --timestamp 125.8 \
  --text "这个是 medical certificate，需要你的签名" \
  --window 2.0 \
  > verification_125.8s.json
```

### 4. Batch Processing

Create a batch script:

```bash
#!/bin/bash
# batch_verify.sh

AUDIO="naati_audio.mp3"
OUTPUT_DIR="verifications"
mkdir -p "$OUTPUT_DIR"

# Read timestamps and texts from CSV
# Format: timestamp,expected_text
while IFS=',' read -r timestamp text; do
  echo "Verifying timestamp: ${timestamp}s"
  
  python3 scripts/verify_timestamp.py \
    --audio "$AUDIO" \
    --timestamp "$timestamp" \
    --text "$text" \
    --window 2.0 \
    > "${OUTPUT_DIR}/verify_${timestamp}s.json"
  
  # Check result
  score=$(jq -r '.match_score' "${OUTPUT_DIR}/verify_${timestamp}s.json")
  diagnosis=$(jq -r '.diagnosis' "${OUTPUT_DIR}/verify_${timestamp}s.json")
  
  if (( $(echo "$score < 0.85" | bc -l) )); then
    echo "⚠️  LOW MATCH (${score}) at ${timestamp}s: $diagnosis"
  else
    echo "✅  GOOD MATCH (${score}) at ${timestamp}s"
  fi
  
done < timestamps.csv
```

Usage:
```bash
chmod +x batch_verify.sh
./batch_verify.sh
```

### 5. Analyze Results

```bash
# Find all low-match timestamps
jq -s 'map(select(.match_score < 0.85))' verifications/*.json > issues.json

# Count diagnosis types
jq -r '.diagnosis' verifications/*.json | sort | uniq -c

# Get average match score
jq -s 'map(.match_score) | add / length' verifications/*.json
```

## Common Scenarios

### Scenario 1: Language Switch Verification

**Problem:** Timestamp at 78.5s is Chinese→English switch

```bash
python3 scripts/verify_timestamp.py \
  --audio audio.mp3 \
  --timestamp 78.5 \
  --text "好的，那么 I will make the appointment for you" \
  --window 2.5  # Wider window for transitions
```

**Expected:** HIGH_MATCH or PARTIAL_MATCH

**If LOW_MATCH:** Language switches often have ±0.5-1s drift. Try:
```bash
# Check slightly earlier
--timestamp 77.5

# Check slightly later  
--timestamp 79.5
```

### Scenario 2: Long Audio End Drift

**Problem:** Timestamp at 890s (near end of 900s audio) might have accumulated error

```bash
python3 scripts/verify_timestamp.py \
  --audio audio.mp3 \
  --timestamp 890.0 \
  --text "最后我们需要确认一下" \
  --window 3.0  # Wider window for potential drift
```

**If LOW_MATCH:** Try wider search:
```bash
# Check ±5s range
for t in 885 887 889 891 893 895; do
  python3 scripts/verify_timestamp.py \
    --audio audio.mp3 \
    --timestamp $t \
    --text "最后我们需要确认一下" \
    --format text | grep "Match Score"
done
```

### Scenario 3: Short Utterance

**Problem:** Verifying short phrase "你好" at 15.2s

```bash
python3 scripts/verify_timestamp.py \
  --audio audio.mp3 \
  --timestamp 15.2 \
  --text "你好" \
  --window 1.0  # Narrow window to avoid adjacent speech
```

**Why narrow?** Short phrases with wide windows may include neighboring words, lowering match score.

### Scenario 4: Overlapping Speech

**Problem:** Two speakers talking at same time around 240s

```bash
python3 scripts/verify_timestamp.py \
  --audio audio.mp3 \
  --timestamp 240.0 \
  --text "对，我明白了" \
  --window 2.0
```

**If LOW_MATCH with diagnosis mentioning longer text:**
- Check if actual_text includes both speakers
- May need manual review
- Consider timestamps slightly before/after overlap

### Scenario 5: Silence Detection

**Problem:** Timestamp might be in a pause

```bash
python3 scripts/verify_timestamp.py \
  --audio audio.mp3 \
  --timestamp 180.0 \
  --text "这是一句话" \
  --window 2.0
```

**Output:**
```json
{
  "actual_text": "",
  "diagnosis": "SILENCE",
  "suggestion": "Segment contains no speech - timestamp may be in a pause"
}
```

**Solution:** Search nearby timestamps:
```bash
# Try ±2s
--timestamp 178.0
--timestamp 182.0
```

## Python API Usage

### Simple Verification

```python
from verify_timestamp import TimestampVerifier

verifier = TimestampVerifier("audio.mp3")
result = verifier.verify(
    timestamp=125.5,
    expected_text="这段话",
    window=2.0
)

print(f"Score: {result['match_score']}")
print(f"Diagnosis: {result['diagnosis']}")
```

### Batch Verification with Error Handling

```python
import json
from verify_timestamp import TimestampVerifier

def verify_batch(audio_path, timestamps_dict):
    """
    Verify multiple timestamps.
    
    Args:
        audio_path: Path to audio file
        timestamps_dict: {timestamp: expected_text}
    
    Returns:
        List of results with issues flagged
    """
    verifier = TimestampVerifier(audio_path)
    results = []
    
    for ts, text in timestamps_dict.items():
        try:
            result = verifier.verify(ts, text, window=2.0)
            result['has_issue'] = result['match_score'] < 0.85
            results.append(result)
        except Exception as e:
            results.append({
                'timestamp': ts,
                'expected_text': text,
                'error': str(e),
                'has_issue': True
            })
    
    return results

# Usage
timestamps = {
    15.2: "你好",
    45.8: "我想预约",
    78.5: "Hello there",
    125.8: "这是一个测试"
}

results = verify_batch("audio.mp3", timestamps)

# Save results
with open("batch_results.json", "w", encoding="utf-8") as f:
    json.dump(results, f, ensure_ascii=False, indent=2)

# Print issues
issues = [r for r in results if r.get('has_issue')]
print(f"Found {len(issues)} problematic timestamps:")
for issue in issues:
    print(f"  {issue['timestamp']}s: {issue.get('diagnosis', 'ERROR')}")
```

### Smart Window Adjustment

```python
def verify_with_adaptive_window(verifier, timestamp, text):
    """
    Try multiple window sizes to find best match.
    """
    windows = [1.0, 1.5, 2.0, 2.5, 3.0]
    best_result = None
    best_score = 0
    
    for window in windows:
        result = verifier.verify(timestamp, text, window=window)
        if result['match_score'] > best_score:
            best_score = result['match_score']
            best_result = result
            best_result['optimal_window'] = window
        
        # Early exit if excellent match
        if result['match_score'] >= 0.95:
            result['optimal_window'] = window
            return result
    
    return best_result

# Usage
verifier = TimestampVerifier("audio.mp3")
result = verify_with_adaptive_window(verifier, 125.5, "这段话")
print(f"Best match: {result['match_score']} with window={result['optimal_window']}s")
```

### Drift Search

```python
def search_for_text(verifier, approximate_timestamp, text, search_range=5.0, step=0.5):
    """
    Search for text around approximate timestamp.
    
    Args:
        verifier: TimestampVerifier instance
        approximate_timestamp: Starting point
        text: Text to find
        search_range: Search ±range seconds
        step: Step size in seconds
    
    Returns:
        Best matching timestamp and result
    """
    import numpy as np
    
    start = max(0, approximate_timestamp - search_range)
    end = min(verifier.duration, approximate_timestamp + search_range)
    timestamps = np.arange(start, end, step)
    
    best_ts = None
    best_result = None
    best_score = 0
    
    for ts in timestamps:
        result = verifier.verify(ts, text, window=2.0, verbose=False)
        if result['match_score'] > best_score:
            best_score = result['match_score']
            best_ts = ts
            best_result = result
    
    return best_ts, best_result

# Usage
verifier = TimestampVerifier("audio.mp3")
best_ts, result = search_for_text(
    verifier,
    approximate_timestamp=450.0,  # Drift suspected here
    text="我们需要确认信息",
    search_range=10.0,
    step=0.5
)

print(f"Best match at {best_ts}s (score: {result['match_score']})")
print(f"Drift from original: {best_ts - 450.0:+.1f}s")
```

## Performance Tips

1. **Save extracted segments** for manual review:
   ```bash
   --output-dir ./segments
   ```

2. **Use appropriate window sizes:**
   - Short phrases (<5 chars): `--window 1.0`
   - Normal phrases: `--window 2.0` (default)
   - Long sentences: `--window 3.0`
   - Language transitions: `--window 2.5`

3. **Parallel processing** for large batches:
   ```bash
   # Use GNU parallel
   cat timestamps.csv | parallel -j 5 --colsep ',' \
     python3 scripts/verify_timestamp.py \
     --audio audio.mp3 --timestamp {1} --text {2}
   ```

4. **Cache API results** if re-running:
   ```python
   import hashlib
   import pickle
   
   def cached_verify(verifier, timestamp, text, window):
       cache_key = hashlib.md5(
           f"{timestamp}_{text}_{window}".encode()
       ).hexdigest()
       cache_file = f".cache/{cache_key}.pkl"
       
       if os.path.exists(cache_file):
           with open(cache_file, 'rb') as f:
               return pickle.load(f)
       
       result = verifier.verify(timestamp, text, window)
       
       os.makedirs('.cache', exist_ok=True)
       with open(cache_file, 'wb') as f:
           pickle.dump(result, f)
       
       return result
   ```

## Exit Codes

The CLI returns different exit codes for automation:

- `0`: High match (≥0.85) ✅
- `1`: Partial match (0.70-0.84) ⚠️
- `2`: Low/no match (<0.70) ❌
- `3`: Error (file not found, API error, etc.) 🔥

Example:
```bash
if python3 scripts/verify_timestamp.py --audio audio.mp3 --timestamp 125.5 --text "测试"; then
  echo "Timestamp verified!"
else
  echo "Verification failed (exit code: $?)"
fi
```

## Integration with Other Tools

### With jq (JSON processing)

```bash
# Extract only problematic timestamps
python3 scripts/verify_timestamp.py ... | \
  jq 'select(.match_score < 0.85)'

# Get just the score
python3 scripts/verify_timestamp.py ... | \
  jq -r '.match_score'

# Pretty print suggestion
python3 scripts/verify_timestamp.py ... | \
  jq -r '.suggestion'
```

### With spreadsheets

```python
import csv
import json

# Generate CSV report
with open('verification_report.csv', 'w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f)
    writer.writerow(['Timestamp', 'Score', 'Diagnosis', 'Expected', 'Actual'])
    
    for result_file in glob('verifications/*.json'):
        with open(result_file) as rf:
            r = json.load(rf)
            writer.writerow([
                r['timestamp'],
                r['match_score'],
                r['diagnosis'],
                r['expected_text'],
                r['actual_text']
            ])
```

## Troubleshooting

See main `SKILL.md` troubleshooting section for common issues.

Additional tips:
- If API is slow, consider using local Whisper model
- For very long audio (>30min), consider splitting into segments first
- If timestamps are consistently off by fixed amount, check if original transcription used different start time
