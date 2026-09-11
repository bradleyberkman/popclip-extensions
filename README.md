# PopClip extensions

Four extensions for [PopClip](https://pilotmoon.com/popclip/) on macOS. I built them for my own workflow.

## Install

Download or clone this repo, then double-click a `.popclipext` folder. PopClip asks to install it. Options live under PopClip > Extensions > the extension name.

## What each one does

**Seq Clip.** Select a numbered markdown list such as `1. **Name:** Jane` and it pushes each value to the clipboard in reverse order. With a clipboard history manager (I use Alfred) item 1 lands in slot 1, item 2 in slot 2, so you can paste a form field by field. Handles bold labels, plain labels, and bare values.

**Reverse Copy Fields.** The same idea with a one-second gap between copies, for history managers that miss rapid writes. Only the `N. **Label:** value` form.

**ElevenLabs TTS.** Reads the selection aloud through ElevenLabs. Long text is split at sentence ends and played piece by piece. Click the PopClip spinner to stop.

**ElevenLabs TTS → iCloud.** Same generation, but saves an MP3 to a folder (default is `TTS_Inbox` in iCloud Drive) and posts a notification. Text over 9500 characters needs `ffmpeg` to join the pieces (`brew install ffmpeg`).

## Keys

The two TTS extensions need your own ElevenLabs API key, entered in the extension's options. Nothing is bundled. An OpenAI key is optional; if you add one, any failed ElevenLabs request (quota, auth, outage) retries through OpenAI's `tts-1` voice `nova`.

Keys are read only from PopClip option fields. There is an off-by-default option, "Read keys from ~/.config/tts", which lets empty fields fall back to `~/.config/tts/elevenlabs_api_key` and `~/.config/tts/openai_api_key` if you prefer keeping keys in files.

Voice, model, speed, stability, and similarity are options too. The default voice is ElevenLabs' premade Rachel; swap in your own voice ID.

## License

MIT, see [LICENSE](LICENSE).
