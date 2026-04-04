#!/usr/bin/env python3
"""
Text Similarity Calculator
Handles Chinese/English mixed text with multiple similarity metrics.
"""

import re
from typing import Dict, List, Tuple


def tokenize_mixed_text(text: str) -> List[str]:
    """
    Tokenize mixed Chinese/English text.
    - CJK characters: individual tokens
    - English words: word-level tokens
    - Normalize whitespace
    
    Args:
        text: Input text (may contain Chinese, English, punctuation)
        
    Returns:
        List of tokens
    """
    # Normalize whitespace
    text = ' '.join(text.split())
    
    tokens = []
    current_word = []
    
    for char in text:
        if is_cjk(char):
            # Flush current English word if any
            if current_word:
                tokens.append(''.join(current_word))
                current_word = []
            # Add CJK character as individual token
            tokens.append(char)
        elif char.isalnum():
            # Build English word
            current_word.append(char.lower())
        else:
            # Punctuation or space - flush current word
            if current_word:
                tokens.append(''.join(current_word))
                current_word = []
    
    # Flush remaining word
    if current_word:
        tokens.append(''.join(current_word))
    
    return tokens


def is_cjk(char: str) -> bool:
    """Check if character is CJK (Chinese/Japanese/Korean)."""
    code = ord(char)
    return (
        (0x4E00 <= code <= 0x9FFF) or   # CJK Unified Ideographs
        (0x3400 <= code <= 0x4DBF) or   # CJK Extension A
        (0x20000 <= code <= 0x2A6DF) or # CJK Extension B
        (0xF900 <= code <= 0xFAFF) or   # CJK Compatibility Ideographs
        (0x3040 <= code <= 0x309F) or   # Hiragana
        (0x30A0 <= code <= 0x30FF) or   # Katakana
        (0xAC00 <= code <= 0xD7AF)      # Hangul
    )


def levenshtein_distance(s1: str, s2: str) -> int:
    """
    Calculate Levenshtein (edit) distance between two strings.
    Pure Python implementation (no dependencies).
    """
    if len(s1) < len(s2):
        return levenshtein_distance(s2, s1)
    
    if len(s2) == 0:
        return len(s1)
    
    previous_row = range(len(s2) + 1)
    for i, c1 in enumerate(s1):
        current_row = [i + 1]
        for j, c2 in enumerate(s2):
            # Cost of insertions, deletions, or substitutions
            insertions = previous_row[j + 1] + 1
            deletions = current_row[j] + 1
            substitutions = previous_row[j] + (c1 != c2)
            current_row.append(min(insertions, deletions, substitutions))
        previous_row = current_row
    
    return previous_row[-1]


def levenshtein_ratio(s1: str, s2: str) -> float:
    """
    Calculate similarity ratio based on Levenshtein distance.
    Returns value between 0 (completely different) and 1 (identical).
    """
    # Normalize whitespace and case for comparison
    s1 = ' '.join(s1.split()).lower()
    s2 = ' '.join(s2.split()).lower()
    
    if not s1 and not s2:
        return 1.0
    if not s1 or not s2:
        return 0.0
    
    distance = levenshtein_distance(s1, s2)
    max_len = max(len(s1), len(s2))
    
    return 1.0 - (distance / max_len)


def token_overlap_similarity(text1: str, text2: str) -> float:
    """
    Calculate word/token-level similarity using Jaccard index.
    Handles mixed Chinese/English text.
    
    Returns:
        Similarity score between 0 and 1
    """
    tokens1 = set(tokenize_mixed_text(text1))
    tokens2 = set(tokenize_mixed_text(text2))
    
    if not tokens1 and not tokens2:
        return 1.0
    if not tokens1 or not tokens2:
        return 0.0
    
    intersection = len(tokens1 & tokens2)
    union = len(tokens1 | tokens2)
    
    return intersection / union if union > 0 else 0.0


def sequence_matcher_similarity(text1: str, text2: str) -> float:
    """
    Calculate similarity using longest common subsequence approach.
    Better for handling insertions/deletions.
    """
    tokens1 = tokenize_mixed_text(text1)
    tokens2 = tokenize_mixed_text(text2)
    
    if not tokens1 and not tokens2:
        return 1.0
    if not tokens1 or not tokens2:
        return 0.0
    
    # Build LCS matrix
    m, n = len(tokens1), len(tokens2)
    dp = [[0] * (n + 1) for _ in range(m + 1)]
    
    for i in range(1, m + 1):
        for j in range(1, n + 1):
            if tokens1[i-1] == tokens2[j-1]:
                dp[i][j] = dp[i-1][j-1] + 1
            else:
                dp[i][j] = max(dp[i-1][j], dp[i][j-1])
    
    lcs_length = dp[m][n]
    max_length = max(m, n)
    
    return lcs_length / max_length if max_length > 0 else 0.0


def calculate_similarity(text1: str, text2: str, weights: Dict[str, float] = None) -> Dict:
    """
    Calculate comprehensive similarity between two texts.
    Uses multiple metrics and returns weighted final score.
    
    Args:
        text1: First text (expected)
        text2: Second text (actual)
        weights: Optional custom weights for metrics
                 Default: {'char': 0.4, 'token': 0.3, 'sequence': 0.3}
    
    Returns:
        {
            'char_similarity': float,      # Character-level (Levenshtein)
            'token_similarity': float,     # Token overlap (Jaccard)
            'sequence_similarity': float,  # LCS-based
            'final_score': float,          # Weighted average
            'metrics_detail': dict         # Additional details
        }
    """
    if weights is None:
        weights = {'char': 0.4, 'token': 0.3, 'sequence': 0.3}
    
    # Calculate individual metrics
    char_sim = levenshtein_ratio(text1, text2)
    token_sim = token_overlap_similarity(text1, text2)
    sequence_sim = sequence_matcher_similarity(text1, text2)
    
    # Weighted final score
    final_score = (
        weights.get('char', 0.4) * char_sim +
        weights.get('token', 0.3) * token_sim +
        weights.get('sequence', 0.3) * sequence_sim
    )
    
    # Additional metrics for diagnostics
    tokens1 = tokenize_mixed_text(text1)
    tokens2 = tokenize_mixed_text(text2)
    
    return {
        'char_similarity': round(char_sim, 3),
        'token_similarity': round(token_sim, 3),
        'sequence_similarity': round(sequence_sim, 3),
        'final_score': round(final_score, 3),
        'metrics_detail': {
            'text1_length': len(text1),
            'text2_length': len(text2),
            'text1_tokens': len(tokens1),
            'text2_tokens': len(tokens2),
            'length_ratio': round(len(text2) / len(text1), 2) if len(text1) > 0 else 0,
            'token_ratio': round(len(tokens2) / len(tokens1), 2) if len(tokens1) > 0 else 0
        }
    }


def diagnose_mismatch(text1: str, text2: str, similarity: Dict) -> Tuple[str, str]:
    """
    Diagnose why texts don't match and provide suggestions.
    
    Args:
        text1: Expected text
        text2: Actual text
        similarity: Result from calculate_similarity()
    
    Returns:
        (diagnosis_level, suggestion_text)
    """
    score = similarity['final_score']
    detail = similarity['metrics_detail']
    
    # High match
    if score >= 0.85:
        return 'HIGH_MATCH', f'Timestamp is accurate ({int(score * 100)}% match)'
    
    # Check for silence/empty
    if not text2.strip():
        return 'SILENCE', 'Segment contains no speech - timestamp may be in a pause or silence'
    
    if not text1.strip():
        return 'EMPTY_EXPECTED', 'Expected text is empty - cannot verify'
    
    # Analyze length ratios
    length_ratio = detail['length_ratio']
    
    # Partial match
    if score >= 0.70:
        if length_ratio > 1.3:
            return 'PARTIAL_MATCH', f'Minor drift detected ({int(score * 100)}% match). Actual text is longer - may include adjacent speech. Try narrower window or check ±0.5s'
        elif length_ratio < 0.7:
            return 'PARTIAL_MATCH', f'Minor drift detected ({int(score * 100)}% match). Actual text is shorter - may be cut off. Try wider window or check ±0.5s'
        else:
            return 'PARTIAL_MATCH', f'Minor differences detected ({int(score * 100)}% match). Could be transcription variations or slight drift. Check ±0.5s'
    
    # Low match
    if score >= 0.50:
        if similarity['token_similarity'] > 0.6:
            return 'LOW_MATCH', f'Significant drift detected ({int(score * 100)}% match). Words overlap but order differs - timestamp likely off by 1-3 seconds. Search in wider range (±2s)'
        else:
            return 'LOW_MATCH', f'Significant mismatch ({int(score * 100)}% match). Content differs substantially. Check if timestamp is off by 2-5 seconds or verify expected text'
    
    # No match
    if similarity['token_similarity'] < 0.2:
        return 'NO_MATCH', f'No meaningful match ({int(score * 100)}% match). Either wrong timestamp (off by >5s) or incorrect expected text. Try searching in ±10s range'
    else:
        return 'NO_MATCH', f'Very low match ({int(score * 100)}% match). Timestamp or text likely incorrect. Manual review recommended'


def main():
    """Test similarity calculations with examples."""
    test_cases = [
        # Perfect match
        ("我想预约明天下午两点的门诊", "我想预约明天下午两点的门诊"),
        # Minor difference
        ("我想预约明天下午两点的门诊", "我想预约明天下午2点的门诊"),
        # Partial match
        ("这是一个测试", "这是一个测试句子"),
        # Mixed language
        ("这个是 medical certificate", "这个是medical certificate"),
        # Low match
        ("你好世界", "再见朋友"),
        # No match
        ("完全不同的内容", "Completely different content"),
    ]
    
    print("Text Similarity Test Cases\n" + "="*60)
    for i, (text1, text2) in enumerate(test_cases, 1):
        print(f"\nCase {i}:")
        print(f"  Text 1: {text1}")
        print(f"  Text 2: {text2}")
        
        result = calculate_similarity(text1, text2)
        diagnosis, suggestion = diagnose_mismatch(text1, text2, result)
        
        print(f"  Score: {result['final_score']:.3f}")
        print(f"    - Character: {result['char_similarity']:.3f}")
        print(f"    - Token: {result['token_similarity']:.3f}")
        print(f"    - Sequence: {result['sequence_similarity']:.3f}")
        print(f"  Diagnosis: {diagnosis}")
        print(f"  Suggestion: {suggestion}")


if __name__ == '__main__':
    main()
