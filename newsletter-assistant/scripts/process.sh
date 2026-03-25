#!/bin/bash
# Full pipeline: classify → extract → archive → delete
# Usage: ./scripts/process.sh [--dry-run]
cd "$(dirname "$0")/.."
python3 src/newsletter_processor.py process --input data/gmail-all --delete "$@"
