#!/bin/zsh
# Speak the selection. Long text is split at sentence ends and each piece is
# generated then played in turn, so no ffmpeg is needed. PopClip kills this
# script (and afplay with it) when you click the spinner.
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

MAX_CHUNK=9500
TEXT="$POPCLIP_TEXT"
TEXT_LEN=${#TEXT}

alert() { osascript -e "display alert \"ElevenLabs TTS\" message \"$1\"" 2>/dev/null; }

# ── Resolve keys. PopClip options first; the ~/.config/tts files only when
#    the "Read keys from ~/.config/tts" option is switched on.
API_KEY="${POPCLIP_OPTION_API_KEY:-}"
OPENAI_KEY="${POPCLIP_OPTION_OPENAI_API_KEY:-}"
if [[ "${POPCLIP_OPTION_CONFIG_FILE_KEYS:-0}" == "1" ]]; then
  [[ -z "$API_KEY" && -f "$HOME/.config/tts/elevenlabs_api_key" ]] && API_KEY=$(<"$HOME/.config/tts/elevenlabs_api_key")
  [[ -z "$OPENAI_KEY" && -f "$HOME/.config/tts/openai_api_key" ]] && OPENAI_KEY=$(<"$HOME/.config/tts/openai_api_key")
fi
if [[ -z "$API_KEY" && -z "$OPENAI_KEY" ]]; then
  alert "No API key set. Open PopClip > Extensions > ElevenLabs TTS and enter a key."
  exit 1
fi

VOICE_ID="${POPCLIP_OPTION_VOICE_ID:-21m00Tcm4TlvDq8ikWAM}"
MODEL_ID="${POPCLIP_OPTION_MODEL_ID:-eleven_flash_v2_5}"
SPEED="${POPCLIP_OPTION_SPEED:-1.05}"
STABILITY="${POPCLIP_OPTION_STABILITY:-0.30}"
SIMILARITY="${POPCLIP_OPTION_SIMILARITY:-0.75}"

# ── Providers. Each writes MP3 to $2 and prints the HTTP status code.
call_elevenlabs() {
  local text="$1" outfile="$2" body
  body=$(python3 -c '
import sys, json
print(json.dumps({
  "text": sys.argv[1],
  "model_id": sys.argv[2],
  "output_format": "mp3_44100_128",
  "voice_settings": {
    "stability": float(sys.argv[3]),
    "similarity_boost": float(sys.argv[4]),
    "speed": float(sys.argv[5])
  }
}))' "$text" "$MODEL_ID" "$STABILITY" "$SIMILARITY" "$SPEED")
  curl -s -X POST "https://api.elevenlabs.io/v1/text-to-speech/${VOICE_ID}/stream" \
    -H "xi-api-key: $API_KEY" -H "Content-Type: application/json" \
    -d "$body" -o "$outfile" -w "%{http_code}" 2>/dev/null
}

call_openai() {
  local text="$1" outfile="$2" escaped
  escaped=$(printf '%s' "$text" | python3 -c 'import sys,json; sys.stdout.write(json.dumps(sys.stdin.read()))')
  curl -s -o "$outfile" -w "%{http_code}" \
    -H "Authorization: Bearer $OPENAI_KEY" -H "Content-Type: application/json" \
    -d "{\"model\":\"tts-1\",\"input\":$escaped,\"voice\":\"nova\"}" \
    "https://api.openai.com/v1/audio/speech" 2>/dev/null
}

# ElevenLabs first; OpenAI only if that fails and a key is present.
generate() {
  local text="$1" outfile="$2" code="000"
  [[ -n "$API_KEY" ]] && code=$(call_elevenlabs "$text" "$outfile")
  if [[ "$code" != "200" && -n "$OPENAI_KEY" ]]; then
    code=$(call_openai "$text" "$outfile")
  fi
  [[ "$code" == "200" && -s "$outfile" ]]
}

# Split long text at sentence ends so no request exceeds MAX_CHUNK characters.
split_chunks() {
  local offset=0 chunk clen i c
  CHUNKS=()
  while [[ $offset -lt $TEXT_LEN ]]; do
    chunk="${TEXT:$offset:$MAX_CHUNK}"
    clen=${#chunk}
    if [[ $clen -eq $MAX_CHUNK && $((offset + clen)) -lt $TEXT_LEN ]]; then
      for ((i=clen-1; i>=0; i--)); do
        c="${chunk:$i:1}"
        if [[ "$c" == "." || "$c" == "!" || "$c" == "?" ]]; then
          chunk="${chunk:0:$((i+1))}"; clen=$((i+1)); break
        fi
      done
    fi
    CHUNKS+=("$chunk")
    offset=$((offset + clen))
  done
}

WORK="/tmp/popclip_tts_play_$$"
mkdir -p "$WORK"
trap 'rm -rf "$WORK"' EXIT

split_chunks
idx=0
for chunk in "${CHUNKS[@]}"; do
  out="$WORK/part_$idx.mp3"
  if ! generate "$chunk" "$out"; then
    alert "Audio request failed (part $((idx+1))). Check your keys and quota."
    exit 1
  fi
  afplay "$out"
  idx=$((idx+1))
done
