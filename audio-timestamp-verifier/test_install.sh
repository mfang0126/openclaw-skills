#!/bin/bash
# Test installation of Audio Timestamp Verifier

echo "================================"
echo "Audio Timestamp Verifier - Installation Test"
echo "================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0

# Test 1: Python version
echo -n "Checking Python version... "
if command -v python3 &> /dev/null; then
    PY_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
    echo -e "${GREEN}✓${NC} Python $PY_VERSION"
else
    echo -e "${RED}✗${NC} Python 3 not found"
    ((ERRORS++))
fi

# Test 2: ffmpeg
echo -n "Checking ffmpeg... "
if command -v ffmpeg &> /dev/null; then
    FF_VERSION=$(ffmpeg -version 2>&1 | head -n1 | awk '{print $3}')
    echo -e "${GREEN}✓${NC} ffmpeg $FF_VERSION"
else
    echo -e "${RED}✗${NC} ffmpeg not found"
    echo "   Install: brew install ffmpeg (macOS) or apt-get install ffmpeg (Linux)"
    ((ERRORS++))
fi

# Test 3: ffprobe
echo -n "Checking ffprobe... "
if command -v ffprobe &> /dev/null; then
    echo -e "${GREEN}✓${NC} Available"
else
    echo -e "${RED}✗${NC} ffprobe not found (comes with ffmpeg)"
    ((ERRORS++))
fi

# Test 4: Python dependencies
echo -n "Checking Python dependencies... "
if python3 -c "import requests" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} requests installed"
else
    echo -e "${RED}✗${NC} requests not installed"
    echo "   Install: pip3 install -r requirements.txt"
    ((ERRORS++))
fi

echo -n "Checking python-Levenshtein (optional)... "
if python3 -c "import Levenshtein" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Installed (faster similarity)"
else
    echo -e "${YELLOW}○${NC} Not installed (will use fallback)"
    echo "   Recommended: pip3 install python-Levenshtein"
fi

# Test 5: API key
echo -n "Checking LEMONFOX_API_KEY... "
if [ -n "$LEMONFOX_API_KEY" ]; then
    echo -e "${GREEN}✓${NC} Set (${#LEMONFOX_API_KEY} chars)"
else
    echo -e "${YELLOW}○${NC} Not set"
    echo "   Set with: export LEMONFOX_API_KEY='your-key'"
fi

# Test 6: Scripts executable
echo -n "Checking script permissions... "
if [ -x "scripts/verify_timestamp.py" ] && [ -x "scripts/text_similarity.py" ]; then
    echo -e "${GREEN}✓${NC} Executable"
else
    echo -e "${YELLOW}○${NC} Not executable, fixing..."
    chmod +x scripts/*.py
    echo -e "${GREEN}✓${NC} Fixed"
fi

# Test 7: Text similarity module
echo -n "Testing text_similarity module... "
TEST_OUTPUT=$(python3 scripts/text_similarity.py "Hello world" "Hello world" 2>&1)
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Working"
else
    echo -e "${RED}✗${NC} Failed"
    echo "$TEST_OUTPUT"
    ((ERRORS++))
fi

echo ""
echo "================================"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ All critical checks passed!${NC}"
    echo ""
    echo "Ready to use. Try:"
    echo "  python3 scripts/verify_timestamp.py --help"
else
    echo -e "${RED}✗ Found $ERRORS error(s). Please fix before using.${NC}"
    exit 1
fi
echo "================================"
