#!/usr/bin/env python3
"""Memory Audit Tool - Scans Qdrant memories for duplicates and contradictions."""

import json
import os
import sys
from collections import defaultdict
from datetime import datetime
from itertools import combinations
from pathlib import Path

import numpy as np
from qdrant_client import QdrantClient
from openai import OpenAI

# --- Config ---
QDRANT_HOST = "localhost"
QDRANT_PORT = 6333
COLLECTION = "memories"
SIMILARITY_THRESHOLD = 0.85
REPORT_PATH = Path.home() / ".openclaw/workspace/memory-audit-report.md"

GLM_BASE_URL = "https://api.z.ai/api/coding/paas/v4"
GLM_API_KEY = os.environ.get("GLM_API_KEY", "")
GLM_MODEL = "glm-4.7"

# Topic keywords for grouping
TOPIC_KEYWORDS = {
    "project": ["project", "repo", "codebase", "workspace", "openclaw", "clawhub"],
    "tool": ["tool", "mcp", "plugin", "extension", "cli", "command"],
    "model": ["model", "llm", "claude", "gpt", "glm", "sonnet", "opus", "haiku"],
    "discord": ["discord", "bot", "server", "channel", "guild"],
    "telegram": ["telegram", "tg", "bot"],
    "website": ["website", "site", "domain", "mingfang", "deploy", "vercel", "astro", "next"],
    "memory": ["memory", "mem0", "qdrant", "vector", "embedding"],
    "agent": ["agent", "multi-agent", "subagent", "orchestr"],
    "config": ["config", "setting", "env", "key", "api"],
    "personal": ["preference", "style", "tone", "language", "chinese", "english"],
}


def cosine_similarity(a, b):
    a, b = np.array(a), np.array(b)
    dot = np.dot(a, b)
    norm = np.linalg.norm(a) * np.linalg.norm(b)
    return dot / norm if norm > 0 else 0.0


def get_memory_text(payload):
    """Extract readable text from a memory payload."""
    # mem0 stores memory text in various fields
    for key in ["memory", "data", "text", "content"]:
        if key in payload and isinstance(payload[key], str):
            return payload[key]
    # Fallback: serialize the whole payload
    return json.dumps(payload, ensure_ascii=False, default=str)


def classify_topic(text):
    """Assign a memory to topic groups based on keyword matching."""
    text_lower = text.lower()
    topics = []
    for topic, keywords in TOPIC_KEYWORDS.items():
        if any(kw in text_lower for kw in keywords):
            topics.append(topic)
    return topics if topics else ["uncategorized"]


def find_duplicates(grouped_memories, all_vectors):
    """Find memory pairs with cosine similarity > threshold within same topic."""
    duplicates = []
    seen_pairs = set()
    for topic, mem_ids in grouped_memories.items():
        if len(mem_ids) < 2:
            continue
        for id_a, id_b in combinations(mem_ids, 2):
            pair_key = tuple(sorted([str(id_a), str(id_b)]))
            if pair_key in seen_pairs:
                continue
            seen_pairs.add(pair_key)
            if id_a in all_vectors and id_b in all_vectors:
                sim = cosine_similarity(all_vectors[id_a], all_vectors[id_b])
                if sim > SIMILARITY_THRESHOLD:
                    duplicates.append((id_a, id_b, sim, topic))
    # Sort by similarity descending
    duplicates.sort(key=lambda x: x[2], reverse=True)
    return duplicates


def detect_contradictions(grouped_memories, all_payloads, glm_client):
    """Use GLM-4.7 to detect contradictions within topic groups."""
    contradictions = []
    for topic, mem_ids in grouped_memories.items():
        if len(mem_ids) < 2:
            continue
        # Build list of memories in this topic
        entries = []
        for mid in mem_ids:
            text = get_memory_text(all_payloads[mid])
            entries.append({"id": str(mid), "text": text})

        if len(entries) > 30:
            # Too many - sample to keep API costs reasonable
            entries = entries[:30]

        prompt = (
            "You are a memory consistency checker. Below are memories stored about the same topic.\n"
            "Identify any CONTRADICTIONS - memories that state conflicting facts.\n"
            "Only flag clear contradictions, not just different aspects of the same topic.\n\n"
            "Memories:\n"
        )
        for e in entries:
            prompt += f"- [ID: {e['id']}] {e['text']}\n"
        prompt += (
            "\nRespond in JSON array format. Each element: "
            '{"id_a": "...", "id_b": "...", "reason": "brief explanation", "suggested_delete": "id to delete or null"}\n'
            "If no contradictions, respond with empty array: []\n"
            "Respond ONLY with the JSON array, no other text."
        )

        try:
            resp = glm_client.chat.completions.create(
                model=GLM_MODEL,
                messages=[{"role": "user", "content": prompt}],
                temperature=0.1,
                max_tokens=2000,
            )
            content = resp.choices[0].message.content.strip()
            # Parse JSON from response
            if content.startswith("```"):
                content = content.split("\n", 1)[1].rsplit("```", 1)[0].strip()
            items = json.loads(content)
            for item in items:
                item["topic"] = topic
                contradictions.append(item)
        except Exception as e:
            print(f"  Warning: GLM contradiction check failed for topic '{topic}': {e}", file=sys.stderr)

    return contradictions


def generate_report(all_payloads, grouped_memories, duplicates, contradictions):
    """Generate the markdown audit report."""
    today = datetime.now().strftime("%Y-%m-%d")
    lines = [
        f"# Memory Audit Report - {today}",
        "",
        "## Summary",
        f"- Total memories: {len(all_payloads)}",
        f"- Potential duplicates: {len(duplicates)} pairs",
        f"- Potential contradictions: {len(contradictions)}",
        "",
    ]

    # Contradictions
    if contradictions:
        lines.append("## \U0001f534 Contradictions (review urgently)")
        lines.append("")
        by_topic = defaultdict(list)
        for c in contradictions:
            by_topic[c["topic"]].append(c)
        for topic, items in by_topic.items():
            lines.append(f"### Topic: {topic}")
            for c in items:
                id_a, id_b = c["id_a"], c["id_b"]
                text_a = get_memory_text(all_payloads.get(id_a, {})) if id_a in all_payloads else "?"
                text_b = get_memory_text(all_payloads.get(id_b, {})) if id_b in all_payloads else "?"
                lines.append(f'- [ID: {id_a}] "{text_a[:120]}"')
                lines.append(f'- [ID: {id_b}] "{text_b[:120]}"')
                lines.append(f"  - Reason: {c.get('reason', 'N/A')}")
                if c.get("suggested_delete"):
                    lines.append(f"  - Suggested action: `memory_forget` ID {c['suggested_delete']}")
                lines.append("")
    else:
        lines.append("## \U0001f534 Contradictions")
        lines.append("None detected.")
        lines.append("")

    # Duplicates
    if duplicates:
        lines.append("## \U0001f7e1 Duplicates (similar content)")
        lines.append("")
        for id_a, id_b, sim, topic in duplicates:
            text_a = get_memory_text(all_payloads.get(id_a, {}))[:120]
            text_b = get_memory_text(all_payloads.get(id_b, {}))[:120]
            lines.append(f"### Similarity: {sim:.3f} (topic: {topic})")
            lines.append(f'- [ID: {id_a}] "{text_a}"')
            lines.append(f'- [ID: {id_b}] "{text_b}"')
            lines.append(f"  - Consider deleting one with `memory_forget`")
            lines.append("")
    else:
        lines.append("## \U0001f7e1 Duplicates")
        lines.append("None detected.")
        lines.append("")

    # All memories by topic
    lines.append("## \u2705 All memories by topic")
    lines.append("")
    for topic in sorted(grouped_memories.keys()):
        mem_ids = grouped_memories[topic]
        lines.append(f"### {topic} ({len(mem_ids)} memories)")
        for mid in mem_ids:
            text = get_memory_text(all_payloads.get(mid, {}))[:150]
            lines.append(f'- [ID: {mid}] "{text}"')
        lines.append("")

    return "\n".join(lines)


def main():
    print("Memory Audit Tool")
    print("=" * 40)

    # Connect to Qdrant
    print("Connecting to Qdrant...")
    client = QdrantClient(host=QDRANT_HOST, port=QDRANT_PORT)

    # Check collection exists
    try:
        info = client.get_collection(COLLECTION)
        total = info.points_count
        print(f"Collection '{COLLECTION}': {total} points")
    except Exception as e:
        print(f"Error: Cannot access collection '{COLLECTION}': {e}", file=sys.stderr)
        sys.exit(1)

    if total == 0:
        print("No memories found. Nothing to audit.")
        sys.exit(0)

    # Pull all memories with vectors
    print("Fetching all memories...")
    all_payloads = {}
    all_vectors = {}
    offset = None
    batch_size = 100
    while True:
        results, next_offset = client.scroll(
            collection_name=COLLECTION,
            limit=batch_size,
            offset=offset,
            with_payload=True,
            with_vectors=True,
        )
        for point in results:
            pid = str(point.id)
            all_payloads[pid] = point.payload or {}
            if point.vector is not None:
                # Handle named vectors
                if isinstance(point.vector, dict):
                    # Use the first available vector
                    for v in point.vector.values():
                        all_vectors[pid] = v
                        break
                else:
                    all_vectors[pid] = point.vector
        if next_offset is None:
            break
        offset = next_offset

    print(f"Fetched {len(all_payloads)} memories ({len(all_vectors)} with vectors)")

    # Group by topic
    print("Grouping by topic...")
    grouped = defaultdict(list)
    for pid, payload in all_payloads.items():
        text = get_memory_text(payload)
        topics = classify_topic(text)
        for t in topics:
            grouped[t].append(pid)

    for topic in sorted(grouped.keys()):
        print(f"  {topic}: {len(grouped[topic])} memories")

    # Find duplicates
    print("Scanning for duplicates...")
    duplicates = find_duplicates(grouped, all_vectors)
    print(f"  Found {len(duplicates)} duplicate pairs")

    # Detect contradictions with GLM
    print("Checking for contradictions (via GLM-4.7)...")
    glm_client = OpenAI(base_url=GLM_BASE_URL, api_key=GLM_API_KEY)
    contradictions = detect_contradictions(grouped, all_payloads, glm_client)
    print(f"  Found {len(contradictions)} contradictions")

    # Generate report
    print("Generating report...")
    report = generate_report(all_payloads, grouped, duplicates, contradictions)
    REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
    REPORT_PATH.write_text(report, encoding="utf-8")
    print(f"Report saved to {REPORT_PATH}")
    print("Done!")


if __name__ == "__main__":
    main()
