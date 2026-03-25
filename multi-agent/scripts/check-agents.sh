#!/bin/bash
# Check which agents are configured in openclaw.json
cat ~/.openclaw/openclaw.json | python3 -c "
import json, sys
cfg = json.load(sys.stdin)
agents = cfg.get('agents', {}).get('list', [])
if not agents:
    print('No agents found in openclaw.json')
else:
    print(f'Configured agents ({len(agents)}):')
    for a in agents:
        print(f\"  {a.get('emoji', '?')} {a.get('name')} ({a.get('id')})\")
"
