#!/bin/bash
# Seq Clip — push values from a numbered markdown list to clipboard sequentially
# so Alfred history puts list item 1 at ⌘1, item 2 at ⌘2, etc.
#
# Selection format expected:
#   1. **Field:** value
#   2. **Field:** value (may span lines until next "N. ")
#
# Falls back to "N. value" without bold field labels.

python3 <<'PYEOF'
import os, re, subprocess, time, sys

text = os.environ.get('POPCLIP_TEXT', '').strip()
if not text:
    print('No selection')
    sys.exit(0)

# Split on each "N. " starting a new item
items = re.split(r'\n(?=\d+\.\s+)', text)
values = []
for item in items:
    item = item.strip()
    if not item:
        continue
    # Pattern A: N. **Field:** value (markdown bold label)
    m = re.match(r'^\d+\.\s+\*\*[^*]+:\*\*\s*(.+)', item, re.DOTALL)
    if not m:
        # Pattern B: N. Field: value (plain label, label assumed <40 chars)
        m = re.match(r'^\d+\.\s+[^:\n]{1,40}:\s*(.+)', item, re.DOTALL)
    if not m:
        # Pattern C: N. value (no label at all)
        m = re.match(r'^\d+\.\s+(.+)', item, re.DOTALL)
    if m:
        values.append(m.group(1).strip())

if not values:
    print('No numbered items parsed')
    sys.exit(0)

# Push in REVERSE order: oldest pbcopy goes first → most recent (= ⌘1) is item 1.
for v in reversed(values):
    p = subprocess.Popen(['pbcopy'], stdin=subprocess.PIPE)
    p.communicate(v.encode('utf-8'))
    time.sleep(0.3)

print(f'{len(values)} values pushed (item 1 → ⌘1)')
PYEOF
