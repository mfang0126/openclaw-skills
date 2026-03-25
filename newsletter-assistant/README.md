# newsletter-assistant

> AI-powered newsletter classification, extraction, and archiving system for Gmail. Three-layer classification with Active Learning for near-zero cost after training.

## Install

```bash
pip install -r ~/.openclaw/skills/newsletter-assistant/requirements.txt
himalaya account add  # configure Gmail
export GLM_API_KEY="your-api-key"
```

## Usage

```bash
# Full pipeline: classify → extract → archive → delete
newsletter-assistant process --input data/gmail-all --delete

# Classify only (safe, no deletion)
newsletter-assistant classify --input data/gmail-all --output data/results.json

# Extract and archive
newsletter-assistant extract --input data/results.json --output data/archive
```

## How It Works

**Pattern: Pipeline** (Google ADK)

```
Gmail (via Himalaya CLI)
  → Fetch emails
  → [Layer 1] Memory System (70% hit rate) — known sender lookup
  → [Layer 2] Pattern Matching (30% hit rate) — domain/subject rules
  → [Layer 3] AI Fallback (GLM-4.7) — semantic classification
  → Extract clean Markdown content (readability-lxml)
  → Archive locally: EML + MD + JSON
  → Delete from Gmail (with --delete flag)
```

## Design Decisions

- **Three-layer classification**: Memory first (free), patterns second (free), AI last (paid). After initial training, AI cost drops to ~$0.
- **Active Learning**: AI classifications auto-populate the memory DB — each run makes future runs cheaper.
- **Himalaya for Gmail access**: Headless CLI tool, no GUI or OAuth browser flow needed.
- **readability-lxml for extraction**: Strips ads/nav, extracts main article content as clean Markdown.

## Cost Analysis

| Stage | Emails | AI Calls | Cost |
|-------|--------|----------|------|
| Training batch | 50 | 50 | ~$0.50 |
| Production (after training) | 1000 | ~0 | ~$0 |
| Total | 1050 | 50 | **~$0.50** |

## Active Learning Flow

```
Batch 1 (50 emails):
  - AI classifies all → build memory DB
  - Cost: ~$0.50

Batch 2+ (500 emails):
  - Memory matches 70%, pattern matches 30%
  - AI calls: 0
  - Cost: $0 ✅
```

## Project Structure

```
newsletter-assistant/
├── src/
│   ├── memory_classifier.py     # Layer 1: memory lookup
│   ├── ai_classifier.py          # Layer 3: GLM fallback
│   ├── content_extractor.py      # HTML → Markdown
│   ├── newsletter_processor.py   # Full pipeline orchestrator
│   ├── gmail_deleter.py          # Gmail deletion via Himalaya
│   └── active_learning.py        # Feed AI results back to memory
├── data/
│   ├── memory-database.json      # Sender → classification cache
│   ├── newsletter-index.json     # Searchable index
│   └── archive/                  # Local storage (EML + MD + JSON)
└── docs/
    └── REFLEXION_LOG.md          # Lessons learned
```

## Limitations

- Gmail only (no Outlook, Yahoo, etc. — yet)
- Requires initial training batch (50 emails) for Active Learning to kick in
- Himalaya required for Gmail headless access
- `readability-lxml` works best on HTML-heavy newsletters; plain-text emails may need manual review

## Related Skills

- None currently
