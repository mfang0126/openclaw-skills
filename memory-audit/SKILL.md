---
name: memory-audit
description: Audit and review agent memory files for quality, staleness, duplicates, and gaps. Use when user says "audit memory", "check memory", "review memory files", "what's in memory", "clean up memory", "check my memories", or "find duplicate memories".
---

# Memory Audit

**Pattern: Reviewer** (Google ADK) — Load → Analyze → Report → Recommend

Audits mem0 memories stored in Qdrant, detecting duplicates, contradictions, and staleness. Outputs a structured report.

## USE FOR
- "audit my memory"
- "check memory files"
- "review memory"
- "what's stored in memory?"
- "clean up memory"
- "find duplicate memories"
- "are there contradictions in my memory?"
- "memory health check"

## REQUIRES
- Python 3.10+
- Qdrant running on localhost:6333
- `GLM_API_KEY` environment variable (for contradiction detection)
- `pip install -r requirements.txt`

## When to Use

Use this skill whenever the user wants to inspect, clean, or review their agent's stored memories. Especially useful after extended use when memory drift or duplication may occur.

Trigger keywords: audit memory, check memory, memory quality, memory cleanup, duplicate memories, stale memory.

**Don't use when:** You're looking for a specific memory or fact (just search directly). This skill audits *quality*, not retrieves content.

## Prerequisites

- Qdrant vector database running: `docker ps | grep qdrant`
- Collection `memories` exists in Qdrant
- Python 3.10+ installed: `python3 --version`
- Dependencies installed: `pip install -r ~/.openclaw/skills/memory-audit/requirements.txt`
- GLM API key set: `echo $GLM_API_KEY`

## Quick Start

```bash
# Run full memory audit
cd ~/.openclaw/skills/memory-audit
./run.sh

# View results
cat ~/.openclaw/workspace/memory-audit-report.md
```

## Instructions

### What the Audit Does

1. **Pull memories** — Fetch all vectors + payloads from Qdrant (`localhost:6333`, collection `memories`)
2. **Group by topic** — Cluster memories by keyword similarity
3. **Flag duplicates** — Cosine similarity > 0.85 within same topic
4. **Detect contradictions** — Use GLM-4.7 to compare conflicting entries
5. **Generate report** — Output structured Markdown to `~/.openclaw/workspace/memory-audit-report.md`

### Interpreting Results

| Section | Meaning |
|---------|---------|
| `## Duplicates` | Memories that say essentially the same thing |
| `## Contradictions` | Memories that conflict with each other |
| `## Topics` | Grouped view of all memory entries |
| `## Recommendations` | Suggested deletions or merges |

## Example

**User says:** "check my memory for duplicates" → Steps: run `./run.sh` audit script → Output: JSON/Markdown report with duplicates, contradictions, recommendations → Reply: "Found 7 duplicates and 2 contradictions. Report saved to `~/.openclaw/workspace/memory-audit-report.md`. Recommend deleting 5 redundant entries."

```bash
$ ./run.sh

🔍 Fetching memories from Qdrant...
📦 Found 143 memories across 12 topics
🔁 Flagging duplicates...  → 7 duplicates found
⚡ Detecting contradictions... → 2 contradictions found
📝 Report saved to: ~/.openclaw/workspace/memory-audit-report.md

Memory Health: ⚠️  Needs attention (7 duplicates, 2 contradictions)
```

**Sample report output:**
```markdown
## Duplicates (7)
- [ID: abc123] "User prefers dark mode" ↔ [ID: def456] "User likes dark themes" (similarity: 0.91)
  → Recommendation: Keep abc123, delete def456

## Contradictions (2)
- [ID: ghi789] "User works in Python" ↔ [ID: jkl012] "User primarily uses JavaScript"
  → Manual review required
```

## Error Handling

| Error | Cause | Fix |
|-------|-------|-----|
| `Connection refused: localhost:6333` | Qdrant not running | `docker start qdrant` |
| `Collection 'memories' not found` | Empty or uninitialized memory | Verify agent has stored memories |
| `GLM_API_KEY not set` | Missing env var | Set in `~/.openclaw/openclaw.json` |
| `ModuleNotFoundError` | Missing Python deps | `pip install -r requirements.txt` |
| `Python 3.10+ required` | Old Python version | Upgrade or use `python3.10` explicitly |

## Scripts

| Script | Purpose |
|--------|---------|
| `run.sh` | Main entry point — installs deps and runs audit |
| `memory-audit.py` | Core Python audit logic |
| `requirements.txt` | Python dependencies |
