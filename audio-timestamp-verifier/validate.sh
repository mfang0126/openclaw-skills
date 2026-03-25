#!/bin/bash
# Validation script for audio-timestamp-verifier skill
# Run this to verify your installation is complete and working

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔍 Validating Audio Timestamp Verifier Installation"
echo "=================================================="
echo ""

# Check if we're in the right directory
if [ ! -f "SKILL.md" ]; then
    echo -e "${RED}❌ Error: Run this script from the audio-timestamp-verifier directory${NC}"
    echo "   cd ~/.openclaw/skills/audio-timestamp-verifier"
    exit 1
fi

# 1. Check Python
echo -n "1. Checking Python 3... "
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
    echo -e "${GREEN}✅ $PYTHON_VERSION${NC}"
else
    echo -e "${RED}❌ Python 3 not found${NC}"
    exit 1
fi

# 2. Check ffmpeg
echo -n "2. Checking ffmpeg... "
if command -v ffmpeg &> /dev/null; then
    FFMPEG_VERSION=$(ffmpeg -version | head -n1 | cut -d' ' -f3)
    echo -e "${GREEN}✅ $FFMPEG_VERSION${NC}"
else
    echo -e "${RED}❌ ffmpeg not found${NC}"
    echo "   Install: brew install ffmpeg (macOS) or sudo apt install ffmpeg (Linux)"
    exit 1
fi

# 3. Check ffprobe
echo -n "3. Checking ffprobe... "
if command -v ffprobe &> /dev/null; then
    echo -e "${GREEN}✅${NC}"
else
    echo -e "${RED}❌ ffprobe not found (should come with ffmpeg)${NC}"
    exit 1
fi

# 4. Check Python requests module
echo -n "4. Checking requests module... "
if python3 -c "import requests" 2>/dev/null; then
    echo -e "${GREEN}✅${NC}"
else
    echo -e "${RED}❌ requests module not found${NC}"
    echo "   Install: pip3 install requests"
    exit 1
fi

# 5. Check API key
echo -n "5. Checking LEMONFOX_API_KEY... "
if [ -z "$LEMONFOX_API_KEY" ]; then
    echo -e "${YELLOW}⚠️  Not set in environment${NC}"
    echo "   Set with: export LEMONFOX_API_KEY=\"your-key-here\""
    echo "   (Required for actual API calls)"
else
    KEY_PREFIX=$(echo "$LEMONFOX_API_KEY" | cut -c1-10)
    echo -e "${GREEN}✅ Set (${KEY_PREFIX}...)${NC}"
fi

# 6. Check file structure
echo -n "6. Checking file structure... "
REQUIRED_FILES=(
    "SKILL.md"
    "README.md"
    "INSTALL.md"
    "SUMMARY.md"
    "scripts/verify_timestamp.py"
    "scripts/text_similarity.py"
)

MISSING=0
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo -e "${RED}❌ Missing: $file${NC}"
        MISSING=$((MISSING + 1))
    fi
done

if [ $MISSING -eq 0 ]; then
    echo -e "${GREEN}✅ All files present${NC}"
else
    echo -e "${RED}❌ $MISSING files missing${NC}"
    exit 1
fi

# 7. Check script permissions
echo -n "7. Checking script permissions... "
if [ -x "scripts/verify_timestamp.py" ] && [ -x "scripts/text_similarity.py" ]; then
    echo -e "${GREEN}✅ Scripts are executable${NC}"
else
    echo -e "${YELLOW}⚠️  Scripts not executable${NC}"
    echo "   Fix with: chmod +x scripts/*.py"
fi

# 8. Test text similarity module
echo -n "8. Testing text similarity calculator... "
TEST_OUTPUT=$(python3 scripts/text_similarity.py 2>&1)
if echo "$TEST_OUTPUT" | grep -q "Text Similarity Test Cases"; then
    echo -e "${GREEN}✅ Working${NC}"
    
    # Extract a sample score
    SAMPLE_SCORE=$(echo "$TEST_OUTPUT" | grep "Score:" | head -n1 | awk '{print $2}')
    echo "   Sample: First test case score = $SAMPLE_SCORE (expected: 1.000)"
else
    echo -e "${RED}❌ Test failed${NC}"
    echo "$TEST_OUTPUT"
    exit 1
fi

# 9. Test verify_timestamp module import
echo -n "9. Testing verify_timestamp module... "
TEST_IMPORT=$(python3 -c "import sys; sys.path.insert(0, 'scripts'); from verify_timestamp import TimestampVerifier; print('OK')" 2>&1)
if echo "$TEST_IMPORT" | grep -q "OK"; then
    echo -e "${GREEN}✅ Imports successfully${NC}"
else
    echo -e "${RED}❌ Import failed${NC}"
    echo "$TEST_IMPORT"
    exit 1
fi

# 10. Check documentation completeness
echo -n "10. Checking documentation... "
DOC_CHECKS=(
    "SKILL.md:LemonFox"
    "README.md:Quick Start"
    "INSTALL.md:Installation"
    "SUMMARY.md:Summary"
)

DOC_MISSING=0
for check in "${DOC_CHECKS[@]}"; do
    file=$(echo $check | cut -d: -f1)
    keyword=$(echo $check | cut -d: -f2)
    if ! grep -q "$keyword" "$file" 2>/dev/null; then
        echo -e "${RED}❌ $file missing '$keyword'${NC}"
        DOC_MISSING=$((DOC_MISSING + 1))
    fi
done

if [ $DOC_MISSING -eq 0 ]; then
    echo -e "${GREEN}✅ Documentation complete${NC}"
else
    echo -e "${YELLOW}⚠️  Some documentation issues${NC}"
fi

# Summary
echo ""
echo "=================================================="
echo "📊 Validation Summary"
echo "=================================================="

# Count checks
TOTAL_CHECKS=10
echo "Total checks: $TOTAL_CHECKS"
echo ""

# Final status
echo "Installation Status:"
if [ -z "$LEMONFOX_API_KEY" ]; then
    echo -e "${YELLOW}⚠️  READY (API key not set - required for actual usage)${NC}"
    echo ""
    echo "To complete setup:"
    echo "  export LEMONFOX_API_KEY=\"$LEMONFOX_API_KEY\""
    echo ""
    echo "Then test with an actual audio file:"
    echo "  python3 scripts/verify_timestamp.py --audio audio.mp3 --timestamp 10.0 --text \"test\""
else
    echo -e "${GREEN}✅ FULLY READY${NC}"
    echo ""
    echo "Try it out:"
    echo "  python3 scripts/verify_timestamp.py \\"
    echo "    --audio /path/to/audio.mp3 \\"
    echo "    --timestamp 125.5 \\"
    echo "    --text \"这是一个测试\" \\"
    echo "    --verbose"
fi

echo ""
echo "📚 Documentation:"
echo "  Quick Start: README.md"
echo "  Installation: INSTALL.md"
echo "  Full Docs: SKILL.md"
echo "  Usage Guide: examples/usage_guide.md"
echo "  Overview: SUMMARY.md"

echo ""
echo -e "${GREEN}🎉 Validation complete!${NC}"
