# memory-audit

> Audit mem0 agent memories stored in Qdrant for duplicates, contradictions, and staleness.

## Install

Already installed at `~/.openclaw/skills/memory-audit/`. Requires Python 3.10+ and Qdrant.

```bash
pip install -r ~/.openclaw/skills/memory-audit/requirements.txt
```

## Usage

```bash
cd ~/.openclaw/skills/memory-audit
./run.sh
```

## How It Works

**Pattern: Reviewer** (Google ADK)

```
Qdrant (localhost:6333)
  → Fetch all memory vectors + payloads
  → Group by topic keywords
  → [Check] Cosine similarity > 0.85 → Flag duplicates
  → [Check] GLM-4.7 contradiction detection → Flag conflicts
  → Generate Markdown report
  → Save to ~/.openclaw/workspace/memory-audit-report.md
```

## Design Decisions

- **Qdrant-native**: Reads directly from vector DB — no file parsing, works with any mem0 setup
- **GLM-4.7 for contradictions**: Cheaper than GPT-4, sufficient for semantic conflict detection
- **Cosine similarity threshold 0.85**: Tuned to catch near-duplicates without false positives on related (but distinct) memories
- **Report to workspace**: Output lands in the agent's workspace so it can be read back in the same session

## Output

Report file: `~/.openclaw/workspace/memory-audit-report.md`

Sections:
| Section | Content |
|---------|---------|
| Summary | Total memories, topics, issues found |
| Duplicates | Pairs with similarity scores + keep/delete advice |
| Contradictions | Conflicting pairs flagged for manual review |
| Topics | Full grouped view of all memories |
| Recommendations | Prioritized cleanup actions |

## Limitations

- Only works with Qdrant backend (not Chroma, Pinecone, etc.)
- Contradiction detection requires `GLM_API_KEY` — costs ~$0.01/run
- Very large memory collections (1000+) may be slow on first run
- Does not auto-delete — report only, human confirms changes

## Scripts

| Script | Purpose |
|--------|---------|
| `run.sh` | Entry point: install deps + run audit |
| `scripts/run.sh` | Same as above (SOP-standard location) |
| `memory-audit.py` | Core audit logic |

## Related Skills

- None currently (standalone maintenance tool)
