# Usage Examples

## Quick Start

### Basic Verification

```bash
cd ~/.openclaw/skills/audio-timestamp-verifier

python3 scripts/verify_timestamp.py \
  --audio ~/naati-ccl/recording.mp3 \
  --timestamp 45.5 \
  --text "你好，这是测试文本" \
  --api-key "$LEMONFOX_API_KEY"
```

**Output:**
```json
{
  "status": "success",
  "timestamp": 45.5,
  "window": 2.0,
  "segment": {
    "start": 43.5,
    "end": 47.5,
    "duration": 4.0
  },
  "expected_text": "你好，这是测试文本",
  "actual_text": "你好这是测试文本",
  "similarity": 0.951,
  "match": true,
  "diagnosis": "Excellent match. Timestamp is accurate.",
  "suggestion": "No adjustment needed.",
  "metrics": {
    "levenshtein_similarity": 0.944,
    "char_overlap": 0.966,
    "word_overlap": 0.966,
    "overall": 0.951,
    "levenshtein_distance": 1
  }
}
```

## Advanced Scenarios

### 1. Bilingual Audio (Chinese-English)

For NAATI CCL recordings with language switching:

```bash
python3 scripts/verify_timestamp.py \
  --audio naati_dialogue.mp3 \
  --timestamp 78.2 \
  --text "Good morning, 你好" \
  --window 2.5 \
  --verbose
```

### 2. Longer Window for Uncertain Timestamps

When you suspect drift:

```bash
python3 scripts/verify_timestamp.py \
  --audio long_recording.mp3 \
  --timestamp 420.0 \
  --text "Expected dialogue here" \
  --window 5.0 \
  --api-key "$LEMONFOX_API_KEY"
```

### 3. Language-Specific Hint

For purely Chinese audio:

```bash
python3 scripts/verify_timestamp.py \
  --audio chinese_only.mp3 \
  --timestamp 120.0 \
  --text "这是纯中文对话" \
  --language zh
```

## Batch Processing

### Verify All Timestamps from Transcription

Create a batch verification script:

```python
#!/usr/bin/env python3
"""batch_verify.py - Verify all segments from a transcription"""

import json
import subprocess
import sys
from pathlib import Path

def verify_batch(audio_path, transcription_path, api_key):
    # Load transcription
    with open(transcription_path) as f:
        data = json.load(f)
    
    segments = data.get('segments', [])
    results = []
    mismatches = []
    
    print(f"Verifying {len(segments)} segments...")
    
    for i, seg in enumerate(segments, 1):
        print(f"\r[{i}/{len(segments)}] Verifying timestamp {seg['start']:.2f}s...", end='')
        
        # Run verifier
        result = subprocess.run([
            'python3',
            'scripts/verify_timestamp.py',
            '--audio', audio_path,
            '--timestamp', str(seg['start']),
            '--text', seg['text'],
            '--api-key', api_key
        ], capture_output=True, text=True)
        
        data = json.loads(result.stdout)
        results.append(data)
        
        if not data.get('match'):
            mismatches.append({
                'segment_id': i,
                'timestamp': seg['start'],
                'similarity': data.get('similarity'),
                'expected': seg['text'],
                'actual': data.get('actual_text')
            })
    
    print("\n\nResults:")
    print(f"Total segments: {len(segments)}")
    print(f"Matches: {len(segments) - len(mismatches)}")
    print(f"Mismatches: {len(mismatches)}")
    
    if mismatches:
        print("\nMismatched segments:")
        for m in mismatches:
            print(f"  #{m['segment_id']} @ {m['timestamp']:.2f}s (similarity: {m['similarity']:.3f})")
            print(f"    Expected: {m['expected']}")
            print(f"    Actual:   {m['actual']}")
    
    # Save detailed results
    with open('verification_results.json', 'w') as f:
        json.dump({
            'summary': {
                'total': len(segments),
                'matches': len(segments) - len(mismatches),
                'mismatches': len(mismatches)
            },
            'mismatched_segments': mismatches,
            'full_results': results
        }, f, ensure_ascii=False, indent=2)
    
    print("\nDetailed results saved to verification_results.json")

if __name__ == '__main__':
    if len(sys.argv) < 4:
        print("Usage: python batch_verify.py <audio> <transcription.json> <api_key>")
        sys.exit(1)
    
    verify_batch(sys.argv[1], sys.argv[2], sys.argv[3])
```

**Usage:**
```bash
python3 batch_verify.py recording.mp3 transcription.json "$LEMONFOX_API_KEY"
```

## Text Similarity Testing

Test similarity calculation standalone:

```bash
cd scripts

# Test exact match
python3 text_similarity.py "你好世界" "你好世界" --verbose

# Test with punctuation differences
python3 text_similarity.py "Hello, world!" "Hello world" --verbose

# Test CJK vs romanized
python3 text_similarity.py "谢谢你的帮助" "谢谢你帮助" --verbose
```

**Example output:**
```
--- Similarity Metrics ---
Expected (normalized): 你好世界
Actual (normalized):   你好世界
Levenshtein:  1.000
Char overlap: 1.000
Word overlap: 1.000
Overall:      1.000

==================================================
Overall Similarity: 1.000
Match: ✅ YES
Diagnosis: Excellent match. Timestamp is accurate.
Suggestion: No adjustment needed.
==================================================
```

## Edge Cases

### Timestamp Near Start

```bash
python3 scripts/verify_timestamp.py \
  --audio recording.mp3 \
  --timestamp 1.0 \
  --text "Opening words" \
  --window 2.0 \
  --verbose
```

Output will show:
```
[WARN] Timestamp near start, adjusted window to begin at 0.0s
```

### Timestamp Near End

```bash
python3 scripts/verify_timestamp.py \
  --audio recording.mp3 \
  --timestamp 598.5 \
  --text "Closing remarks" \
  --window 2.0 \
  --verbose
```

If audio is 600s long:
```
[WARN] Timestamp near end, adjusted window to end at 600.0s
```

## Error Handling

### Missing Audio File

```bash
python3 scripts/verify_timestamp.py \
  --audio nonexistent.mp3 \
  --timestamp 10.0 \
  --text "Test"
```

**Output:**
```json
{
  "status": "error",
  "error": "Audio file not found: /path/to/nonexistent.mp3"
}
```

### Timestamp Beyond Duration

```bash
python3 scripts/verify_timestamp.py \
  --audio short_clip.mp3 \
  --timestamp 500.0 \
  --text "Test"
```

**Output:**
```json
{
  "status": "error",
  "error": "Timestamp 500.0s exceeds audio duration (30.5s)",
  "timestamp": 500.0,
  "audio_duration": 30.5
}
```

## Integration with Transcription Workflow

### Full NAATI CCL Workflow

```bash
#!/bin/bash
# naati_process.sh - Complete processing workflow

AUDIO="naati_recording.mp3"
API_KEY="$LEMONFOX_API_KEY"

echo "Step 1: Full transcription..."
# (Your existing LemonFox full transcription)
# Results saved to: transcription.json

echo "Step 2: Verify critical timestamps..."
# Verify speaker transitions and language switches
cat transcription.json | jq -r '.segments[] | select(.start > 0) | [.start, .text] | @tsv' | \
while IFS=$'\t' read -r timestamp text; do
  result=$(python3 scripts/verify_timestamp.py \
    --audio "$AUDIO" \
    --timestamp "$timestamp" \
    --text "$text" \
    --api-key "$API_KEY")
  
  match=$(echo "$result" | jq -r '.match')
  
  if [ "$match" != "true" ]; then
    echo "⚠️  Mismatch at ${timestamp}s"
    echo "$result" | jq '.diagnosis, .suggestion'
  fi
done

echo "Verification complete!"
```

## Performance Optimization

### Parallel Verification (for large batches)

```python
#!/usr/bin/env python3
"""parallel_verify.py - Verify segments in parallel"""

import json
import subprocess
from concurrent.futures import ThreadPoolExecutor, as_completed

def verify_segment(audio, timestamp, text, api_key):
    result = subprocess.run([
        'python3', 'scripts/verify_timestamp.py',
        '--audio', audio,
        '--timestamp', str(timestamp),
        '--text', text,
        '--api-key', api_key
    ], capture_output=True, text=True)
    return json.loads(result.stdout)

def parallel_verify(audio_path, segments, api_key, workers=4):
    results = []
    
    with ThreadPoolExecutor(max_workers=workers) as executor:
        futures = {
            executor.submit(verify_segment, audio_path, seg['start'], seg['text'], api_key): seg
            for seg in segments
        }
        
        for future in as_completed(futures):
            result = future.result()
            results.append(result)
            print(f"✓ Verified {result['timestamp']:.2f}s (match: {result.get('match')})")
    
    return results

# Usage
if __name__ == '__main__':
    import sys
    
    with open(sys.argv[2]) as f:
        transcription = json.load(f)
    
    results = parallel_verify(
        sys.argv[1],
        transcription['segments'],
        sys.argv[3],
        workers=4
    )
    
    print(f"\nVerified {len(results)} segments")
```

Run with:
```bash
python3 parallel_verify.py recording.mp3 transcription.json "$LEMONFOX_API_KEY"
```

## Debugging Tips

### Keep Temporary Files

To inspect extracted audio segments:

```bash
python3 scripts/verify_timestamp.py \
  --audio recording.mp3 \
  --timestamp 120.0 \
  --text "Expected text" \
  --keep-temp \
  --verbose
```

This will output:
```
[INFO] Segment extracted to: /tmp/verify_segment_abc123.mp3
...
[INFO] Kept temp files: /tmp/verify_segment_abc123.mp3
```

You can then listen to the extracted segment to verify what was actually transcribed.

### Verbose Mode for Troubleshooting

```bash
python3 scripts/verify_timestamp.py \
  --audio recording.mp3 \
  --timestamp 78.5 \
  --text "测试文本" \
  --verbose
```

Shows detailed processing steps:
```
[INFO] Audio duration: 600.00 seconds
[INFO] Extracting segment: 76.50s to 80.50s (4.00s)
[INFO] Segment extracted to: /tmp/verify_segment_xyz.mp3
[INFO] Sending segment to LemonFox API...
[INFO] Transcription received: 测试文本

--- Similarity Metrics ---
Expected (normalized): 测试文本
Actual (normalized):   测试文本
Levenshtein:  1.000
Char overlap: 1.000
Word overlap: 1.000
Overall:      1.000
```

## Exit Codes

The script uses meaningful exit codes:

- `0` - Success, timestamp matches
- `1` - Error (file not found, API failure, etc.)
- `2` - No match (timestamp drift detected)

Use in shell scripts:

```bash
if python3 scripts/verify_timestamp.py --audio file.mp3 --timestamp 10 --text "test" --api-key "$KEY"; then
  echo "Timestamp accurate!"
else
  exit_code=$?
  if [ $exit_code -eq 2 ]; then
    echo "Timestamp mismatch detected"
  else
    echo "Error occurred"
  fi
fi
```
