# Installation Guide

## Quick Install

```bash
# 1. Install system dependencies
brew install ffmpeg  # macOS
# OR
sudo apt install ffmpeg  # Linux

# 2. Install Python dependencies
pip3 install requests

# 3. Set API key
export LEMONFOX_API_KEY="TOYPp7Ug75QTlcRWxOp8mo8GLylB3LaV"

# 4. Verify installation
cd ~/.openclaw/skills/audio-timestamp-verifier
python3 scripts/text_similarity.py
```

## Detailed Setup

### System Requirements

- **Operating System:** macOS, Linux, or WSL2
- **Python:** 3.7 or higher
- **ffmpeg:** Latest version
- **Network:** Internet access for LemonFox API

### Step-by-Step

#### 1. Install ffmpeg

**macOS (Homebrew):**
```bash
brew install ffmpeg
```

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install ffmpeg
```

**Fedora/RHEL:**
```bash
sudo dnf install ffmpeg
```

**Verify:**
```bash
ffmpeg -version
ffprobe -version
```

#### 2. Install Python Dependencies

**Required:**
```bash
pip3 install requests
```

**Optional (faster text similarity):**
```bash
pip3 install python-Levenshtein
```

**Verify:**
```bash
python3 -c "import requests; print('✅ requests installed')"
```

#### 3. Configure API Key

**Option A: Environment Variable (Recommended)**
```bash
# Add to ~/.bashrc or ~/.zshrc
export LEMONFOX_API_KEY="TOYPp7Ug75QTlcRWxOp8mo8GLylB3LaV"

# Reload shell
source ~/.bashrc  # or ~/.zshrc
```

**Option B: Pass via CLI**
```bash
python3 scripts/verify_timestamp.py --api-key "TOYPp7Ug75QTlcRWxOp8mo8GLylB3LaV" ...
```

**Option C: Create config file**
```bash
echo "LEMONFOX_API_KEY=TOYPp7Ug75QTlcRWxOp8mo8GLylB3LaV" > ~/.openclaw_api.env

# Load in scripts
source ~/.openclaw_api.env
```

#### 4. Test Installation

```bash
cd ~/.openclaw/skills/audio-timestamp-verifier

# Test similarity calculator
python3 scripts/text_similarity.py

# Expected output: Test cases with similarity scores
```

## Verification Checklist

- [ ] ffmpeg installed and in PATH
- [ ] Python 3.7+ available
- [ ] requests module installed
- [ ] LEMONFOX_API_KEY set
- [ ] Text similarity tests pass
- [ ] Can access skill directory

## Common Issues

### "ffmpeg: command not found"

**Solution:**
```bash
# Install ffmpeg first
brew install ffmpeg  # macOS
sudo apt install ffmpeg  # Linux

# Add to PATH if needed
export PATH="/usr/local/bin:$PATH"
```

### "No module named 'requests'"

**Solution:**
```bash
pip3 install requests

# If pip3 not found
python3 -m pip install requests

# If permission denied
pip3 install --user requests
```

### "API key required"

**Solution:**
```bash
# Set environment variable
export LEMONFOX_API_KEY="TOYPp7Ug75QTlcRWxOp8mo8GLylB3LaV"

# Verify it's set
echo $LEMONFOX_API_KEY

# Make permanent in ~/.bashrc or ~/.zshrc
echo 'export LEMONFOX_API_KEY="TOYPp7Ug75QTlcRWxOp8mo8GLylB3LaV"' >> ~/.bashrc
```

### "Permission denied" when running scripts

**Solution:**
```bash
# Make scripts executable
chmod +x scripts/*.py

# Or run with python3
python3 scripts/verify_timestamp.py ...
```

### Python version too old

**Solution:**
```bash
# Check current version
python3 --version

# Install newer Python (macOS)
brew install python@3.11

# Update alternatives (Linux)
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1
```

## Optional Enhancements

### 1. Install Faster Levenshtein

```bash
pip3 install python-Levenshtein
```

Benefits: 10-50x faster text similarity calculation

### 2. Create Shell Alias

```bash
# Add to ~/.bashrc or ~/.zshrc
alias verify-ts='python3 ~/.openclaw/skills/audio-timestamp-verifier/scripts/verify_timestamp.py'

# Usage
verify-ts --audio audio.mp3 --timestamp 125.5 --text "测试"
```

### 3. Install jq for JSON Processing

```bash
# macOS
brew install jq

# Linux
sudo apt install jq

# Usage with verification
python3 scripts/verify_timestamp.py ... | jq '.match_score'
```

### 4. Set up Autocomplete (bash)

```bash
# Create completion script
cat > ~/.openclaw-verify-completion.bash << 'EOF'
_verify_timestamp_complete() {
    local cur prev opts
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="--audio --timestamp --text --window --output-dir --api-key --verbose --format"
    
    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
}

complete -F _verify_timestamp_complete verify_timestamp.py
EOF

# Source in ~/.bashrc
echo "source ~/.openclaw-verify-completion.bash" >> ~/.bashrc
```

## Uninstallation

```bash
# Remove skill
rm -rf ~/.openclaw/skills/audio-timestamp-verifier

# Remove Python dependencies (if not used elsewhere)
pip3 uninstall requests python-Levenshtein

# ffmpeg should be kept (used by other tools)
```

## Next Steps

After installation:
1. Read `README.md` for quick usage
2. Review `SKILL.md` for full documentation
3. Check `examples/usage_guide.md` for real-world scenarios
4. Try the test cases in `scripts/text_similarity.py`

## Support

For issues:
1. Check this installation guide
2. Review `SKILL.md` troubleshooting section
3. Verify all dependencies are installed
4. Test with simple case before complex audio
