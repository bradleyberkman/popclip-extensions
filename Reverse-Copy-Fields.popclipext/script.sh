#!/bin/zsh
# Parse numbered markdown list, copy each value to clipboard in reverse order
# so Alfred clipboard history shows them in paste order (field 1 at top).

lines=()
while IFS= read -r line; do
  # Match lines starting with "N. **Label:** Value"
  if [[ "$line" =~ ^[0-9]+\.\  ]]; then
    # Strip the "N. **Label:** " prefix
    val="${line#*\*\* }"
    lines+=("$val")
  fi
done <<< "$POPCLIP_TEXT"

n=${#lines[@]}
if [ $n -eq 0 ]; then
  exit 1
fi

# Copy in reverse order: last field first, so clipboard history ends up
# with field 1 as most recent (top of Alfred clipboard viewer)
for ((i=n; i>=1; i--)); do
  printf '%s' "${lines[$i]}" | pbcopy
  if [ $i -gt 1 ]; then
    sleep 1
  fi
done
