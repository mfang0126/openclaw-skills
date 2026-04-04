#!/usr/bin/env python3
"""
Update sender memory from user corrections.

Usage:
    python3 learn.py <sender_email> <correct_category>
    python3 learn.py "noreply@uber.com" "trash"
    
    # Batch corrections from JSON
    echo '[{"sender":"a@b.com","category":"act"}]' | python3 learn.py --batch
"""
import json
import sys
import os
from pathlib import Path

MEMORY_DIR = Path(__file__).parent.parent / "memory"


def load_memory(account_id="mfang0126"):
    path = MEMORY_DIR / f"gmail-{account_id}.json"
    if path.exists():
        with open(path) as f:
            return json.load(f)
    return {"account": f"{account_id}@gmail.com", "version": "2.0", "senders": {}}


def save_memory(memory, account_id="mfang0126"):
    path = MEMORY_DIR / f"gmail-{account_id}.json"
    with open(path, "w") as f:
        json.dump(memory, f, indent=2, ensure_ascii=False)


def update_sender(memory, sender_addr, correct_category):
    """Update a sender's classification in memory."""
    sender_addr = sender_addr.lower().strip()
    senders = memory.setdefault("senders", {})
    
    if sender_addr in senders:
        info = senders[sender_addr]
        breakdown = info.setdefault("breakdown", {})
        
        # Add correction
        breakdown[correct_category] = breakdown.get(correct_category, 0) + 1
        
        # Recalculate
        total = sum(breakdown.values())
        dominant = max(breakdown, key=breakdown.get)
        dominant_count = breakdown[dominant]
        
        if len(breakdown) == 1:
            info["category"] = dominant
            info["confidence"] = 1.0
            info["mixed"] = False
        elif dominant_count / total >= 0.8:
            info["category"] = dominant
            info["confidence"] = round(dominant_count / total, 2)
            info["mixed"] = True
        else:
            info["category"] = "mixed"
            info["confidence"] = 0
            info["mixed"] = True
        
        info["count"] = total
        action = "updated"
    else:
        senders[sender_addr] = {
            "category": correct_category,
            "confidence": 1.0,
            "count": 1,
            "mixed": False,
            "breakdown": {correct_category: 1},
        }
        action = "added"
    
    return memory, action


def main():
    memory = load_memory()
    
    if "--batch" in sys.argv:
        corrections = json.load(sys.stdin)
        for c in corrections:
            memory, action = update_sender(memory, c["sender"], c["category"])
            print(f"  {action}: {c['sender']} → {c['category']}")
    elif len(sys.argv) >= 3:
        sender = sys.argv[1]
        category = sys.argv[2]
        if category not in ("read", "track", "act", "trash"):
            print(f"Error: invalid category '{category}'. Use: read/track/act/trash")
            sys.exit(1)
        memory, action = update_sender(memory, sender, category)
        print(f"{action}: {sender} → {category}")
    else:
        print("Usage: python3 learn.py <sender_email> <category>")
        print("       echo '[{\"sender\":\"a@b.com\",\"category\":\"act\"}]' | python3 learn.py --batch")
        sys.exit(1)
    
    save_memory(memory)
    print("Memory saved.")


if __name__ == "__main__":
    main()
