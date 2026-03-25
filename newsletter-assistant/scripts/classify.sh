#!/bin/bash
# Classify only (no deletion)
# Usage: ./scripts/classify.sh
cd "$(dirname "$0")/.."
python3 src/newsletter_processor.py classify --input data/gmail-all --output data/results.json
