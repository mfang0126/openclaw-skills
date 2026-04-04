#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
pip install -q -r requirements.txt 2>/dev/null
python memory-audit.py "$@"
