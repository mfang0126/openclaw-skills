# 🧮 Calculator Skill

**The simplest way to make LLMs calculate without errors.**

## Why?

LLMs are statistical models - they predict text, not compute math. Even GPT-4 and Claude fail at basic arithmetic sometimes.

This skill solves that by offloading all calculations to Node.js - achieving **100% accuracy** with zero API costs.

## Quick Start

```bash
clawhub install calculator
./calculate.sh "1000 * 0.0016"
# 1.6 ✅
```

## Features

- ✅ **100% accurate** - Uses JavaScript math engine
- ⚡ **Zero latency** - Runs locally
- 💰 **Zero cost** - No API calls
- 📊 **Table mode** - Compare multiple calculations
- 🔢 **Full math support** - All JavaScript Math functions

## Examples

```bash
# Basic
./calculate.sh "100 + 200"

# Multiple
./calculate.sh "1+1" "2*2" "3**3"

# Table comparison
./calculate.sh --table "plan_a:100*0.5" "plan_b:100*0.3"
```

## The Rule

**If you're calculating, use this skill. No exceptions.**

LLMs should reason about math, not do it.

## License

MIT
