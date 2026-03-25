#!/bin/bash
# Usage: render.sh <input.mmd> [output.png]
INPUT="$1"
if [ -z "$INPUT" ]; then
  echo "Usage: render.sh <input.mmd> [output.png]"
  exit 1
fi
OUTPUT="${2:-${INPUT%.mmd}.png}"
mmdc -i "$INPUT" -o "$OUTPUT" -b white -w 1600 -H 800
echo "Rendered: $OUTPUT"
