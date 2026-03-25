#!/usr/bin/env python3
"""
Audio Timestamp Verifier
Verify timestamp accuracy by extracting audio segments and re-transcribing.
"""

import argparse
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Dict, Optional, Tuple

try:
    import requests
except ImportError:
    print("Error: 'requests' module not found. Install with: pip3 install requests", file=sys.stderr)
    sys.exit(1)

# Import similarity calculator from same directory
try:
    from text_similarity import calculate_similarity, diagnose_mismatch
except ImportError:
    # Try alternative import path
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    from text_similarity import calculate_similarity, diagnose_mismatch


class TimestampVerifier:
    """Verify audio timestamp accuracy."""
    
    LEMONFOX_API_URL = "https://api.lemonfox.ai/v1/audio/transcriptions"
    
    def __init__(self, audio_path: str, api_key: Optional[str] = None):
        """
        Initialize verifier.
        
        Args:
            audio_path: Path to audio file
            api_key: LemonFox API key (defaults to env LEMONFOX_API_KEY)
        """
        self.audio_path = Path(audio_path)
        if not self.audio_path.exists():
            raise FileNotFoundError(f"Audio file not found: {audio_path}")
        
        self.api_key = api_key or os.environ.get('LEMONFOX_API_KEY')
        if not self.api_key:
            raise ValueError("API key required. Set LEMONFOX_API_KEY env var or pass --api-key")
        
        self.duration = self._get_audio_duration()
    
    def _get_audio_duration(self) -> float:
        """Get audio file duration in seconds using ffprobe."""
        try:
            result = subprocess.run(
                [
                    'ffprobe',
                    '-v', 'error',
                    '-show_entries', 'format=duration',
                    '-of', 'default=noprint_wrappers=1:nokey=1',
                    str(self.audio_path)
                ],
                capture_output=True,
                text=True,
                check=True
            )
            return float(result.stdout.strip())
        except subprocess.CalledProcessError as e:
            raise RuntimeError(f"Failed to get audio duration: {e.stderr}")
        except FileNotFoundError:
            raise RuntimeError("ffprobe not found. Install ffmpeg: brew install ffmpeg")
    
    def _calculate_segment_bounds(self, timestamp: float, window: float) -> Tuple[float, float, float]:
        """
        Calculate segment boundaries with edge case handling.
        
        Args:
            timestamp: Target timestamp in seconds
            window: Window size (±seconds)
        
        Returns:
            (start_time, end_time, duration)
        """
        start = max(0.0, timestamp - window)
        end = min(self.duration, timestamp + window)
        duration = end - start
        
        return start, end, duration
    
    def _extract_audio_segment(self, start: float, duration: float, output_path: str) -> None:
        """
        Extract audio segment using ffmpeg.
        
        Args:
            start: Start time in seconds
            duration: Duration in seconds
            output_path: Output file path
        """
        try:
            subprocess.run(
                [
                    'ffmpeg',
                    '-i', str(self.audio_path),
                    '-ss', str(start),
                    '-t', str(duration),
                    '-c', 'copy',  # Fast copy without re-encoding
                    '-y',  # Overwrite output file
                    output_path
                ],
                capture_output=True,
                check=True
            )
        except subprocess.CalledProcessError as e:
            raise RuntimeError(f"ffmpeg extraction failed: {e.stderr.decode()}")
        except FileNotFoundError:
            raise RuntimeError("ffmpeg not found. Install: brew install ffmpeg")
    
    def _transcribe_segment(self, audio_path: str) -> str:
        """
        Transcribe audio segment using LemonFox API.
        
        Args:
            audio_path: Path to audio file
        
        Returns:
            Transcribed text
        """
        try:
            with open(audio_path, 'rb') as f:
                files = {'file': f}
                data = {
                    'model': 'whisper-1',
                    'response_format': 'json'
                }
                headers = {'Authorization': f'Bearer {self.api_key}'}
                
                response = requests.post(
                    self.LEMONFOX_API_URL,
                    files=files,
                    data=data,
                    headers=headers,
                    timeout=30
                )
            
            if response.status_code != 200:
                raise RuntimeError(f"API error {response.status_code}: {response.text}")
            
            result = response.json()
            return result.get('text', '').strip()
            
        except requests.exceptions.RequestException as e:
            raise RuntimeError(f"API request failed: {str(e)}")
        except json.JSONDecodeError:
            raise RuntimeError(f"Invalid API response: {response.text}")
    
    def verify(
        self,
        timestamp: float,
        expected_text: str,
        window: float = 2.0,
        output_dir: Optional[str] = None,
        verbose: bool = False
    ) -> Dict:
        """
        Verify timestamp accuracy.
        
        Args:
            timestamp: Timestamp to verify (seconds)
            expected_text: Expected transcription text
            window: Window size before/after timestamp (seconds)
            output_dir: Optional directory to save extracted segment
            verbose: Print detailed diagnostics
        
        Returns:
            Verification result dictionary
        """
        # Validate timestamp
        if timestamp < 0:
            raise ValueError(f"Timestamp must be >= 0, got {timestamp}")
        if timestamp > self.duration:
            raise ValueError(f"Timestamp {timestamp}s exceeds audio duration {self.duration}s")
        
        # Calculate segment bounds
        start, end, duration = self._calculate_segment_bounds(timestamp, window)
        
        if verbose:
            print(f"Audio duration: {self.duration:.2f}s", file=sys.stderr)
            print(f"Target timestamp: {timestamp:.2f}s (±{window}s window)", file=sys.stderr)
            print(f"Segment: {start:.2f}s to {end:.2f}s (duration: {duration:.2f}s)", file=sys.stderr)
        
        # Extract audio segment
        if output_dir:
            os.makedirs(output_dir, exist_ok=True)
            segment_path = os.path.join(output_dir, f"segment_{timestamp:.1f}s.mp3")
            cleanup_segment = False
        else:
            # Use temporary file
            temp_fd, segment_path = tempfile.mkstemp(suffix='.mp3')
            os.close(temp_fd)
            cleanup_segment = True
        
        try:
            if verbose:
                print(f"Extracting segment to: {segment_path}", file=sys.stderr)
            
            self._extract_audio_segment(start, duration, segment_path)
            
            # Transcribe segment
            if verbose:
                print("Transcribing segment...", file=sys.stderr)
            
            actual_text = self._transcribe_segment(segment_path)
            
            if verbose:
                print(f"Expected: {expected_text}", file=sys.stderr)
                print(f"Actual: {actual_text}", file=sys.stderr)
            
            # Calculate similarity
            similarity = calculate_similarity(expected_text, actual_text)
            diagnosis, suggestion = diagnose_mismatch(expected_text, actual_text, similarity)
            
            # Build result
            result = {
                'timestamp': timestamp,
                'window': window,
                'segment_start': start,
                'segment_end': end,
                'segment_duration': duration,
                'expected_text': expected_text,
                'actual_text': actual_text,
                'match_score': similarity['final_score'],
                'diagnosis': diagnosis,
                'suggestion': suggestion,
                'metrics': {
                    'char_similarity': similarity['char_similarity'],
                    'token_similarity': similarity['token_similarity'],
                    'sequence_similarity': similarity['sequence_similarity']
                }
            }
            
            if output_dir:
                result['segment_path'] = segment_path
            
            return result
            
        finally:
            # Cleanup temporary file
            if cleanup_segment and os.path.exists(segment_path):
                os.unlink(segment_path)
    
    def get_audio_duration(self) -> float:
        """Get total audio duration in seconds."""
        return self.duration


def main():
    """CLI entry point."""
    parser = argparse.ArgumentParser(
        description='Verify audio timestamp accuracy by re-transcribing segments',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
Examples:
  # Basic verification
  %(prog)s --audio recording.mp3 --timestamp 125.5 --text "这段话应该在这个时间点"
  
  # Custom window size
  %(prog)s --audio recording.mp3 --timestamp 45.2 --text "你好" --window 1.5
  
  # Save extracted segment
  %(prog)s --audio recording.mp3 --timestamp 78.5 --text "Hello" --output-dir ./segments
  
  # Verbose output
  %(prog)s --audio recording.mp3 --timestamp 200.0 --text "Test" --verbose
        '''
    )
    
    parser.add_argument(
        '--audio',
        required=True,
        help='Path to audio file (mp3/wav/m4a)'
    )
    parser.add_argument(
        '--timestamp',
        type=float,
        required=True,
        help='Timestamp to verify (seconds, decimal)'
    )
    parser.add_argument(
        '--text',
        required=True,
        help='Expected transcription text'
    )
    parser.add_argument(
        '--window',
        type=float,
        default=2.0,
        help='Window size before/after timestamp (default: 2.0 seconds)'
    )
    parser.add_argument(
        '--output-dir',
        help='Directory to save extracted audio segment (optional)'
    )
    parser.add_argument(
        '--api-key',
        help='LemonFox API key (default: LEMONFOX_API_KEY env var)'
    )
    parser.add_argument(
        '--verbose',
        action='store_true',
        help='Print detailed diagnostics to stderr'
    )
    parser.add_argument(
        '--format',
        choices=['json', 'text'],
        default='json',
        help='Output format (default: json)'
    )
    
    args = parser.parse_args()
    
    try:
        # Initialize verifier
        verifier = TimestampVerifier(args.audio, args.api_key)
        
        # Perform verification
        result = verifier.verify(
            timestamp=args.timestamp,
            expected_text=args.text,
            window=args.window,
            output_dir=args.output_dir,
            verbose=args.verbose
        )
        
        # Output result
        if args.format == 'json':
            print(json.dumps(result, ensure_ascii=False, indent=2))
        else:
            # Text format
            print(f"Timestamp: {result['timestamp']}s")
            print(f"Match Score: {result['match_score']:.2f}")
            print(f"Diagnosis: {result['diagnosis']}")
            print(f"Suggestion: {result['suggestion']}")
            print(f"\nExpected: {result['expected_text']}")
            print(f"Actual:   {result['actual_text']}")
            print(f"\nMetrics:")
            print(f"  Character similarity: {result['metrics']['char_similarity']:.3f}")
            print(f"  Token similarity:     {result['metrics']['token_similarity']:.3f}")
            print(f"  Sequence similarity:  {result['metrics']['sequence_similarity']:.3f}")
        
        # Exit code based on match quality
        if result['match_score'] >= 0.85:
            sys.exit(0)  # High match
        elif result['match_score'] >= 0.70:
            sys.exit(1)  # Partial match
        else:
            sys.exit(2)  # Low/no match
        
    except Exception as e:
        print(f"Error: {str(e)}", file=sys.stderr)
        if args.verbose:
            import traceback
            traceback.print_exc()
        sys.exit(3)


if __name__ == '__main__':
    main()
