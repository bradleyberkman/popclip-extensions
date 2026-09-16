# PopClip extensions

Three extensions for [PopClip](https://pilotmoon.com/popclip/) on macOS. I built them for my own workflow.

## Before installing

You need macOS and [PopClip](https://pilotmoon.com/popclip/), which is a separate app. All three extensions also call `python3`; check `python3 --version` in Terminal.

Seq Clip works best with a clipboard history manager. It overwrites the current clipboard with each extracted value; without history, only the final copied value remains. Sensitive selections may also remain in your history manager.

## Install

Download this repository with **Code > Download ZIP** and unzip it, or clone it with Git. Then double-click a `.popclipext` folder. PopClip asks to install it. Options live under PopClip > Extensions > the extension name.

## What each one does

**Seq Clip.** Select a numbered markdown list such as `1. **Name:** Jane` and it pushes each value to the clipboard in reverse order, with a one-second gap so clipboard history managers do not miss rapid writes. With a clipboard history manager (I use Alfred) item 1 lands in slot 1, item 2 in slot 2, so you can paste a form field by field. Handles bold labels, plain labels, and bare values.

**ElevenLabs TTS.** Reads the selection aloud through ElevenLabs. Long text is split at sentence ends and played piece by piece. Click the PopClip spinner to stop.

**ElevenLabs TTS → iCloud.** Same generation, but saves an MP3 to a folder (default is `TTS_Inbox` in iCloud Drive) and posts a notification. Text over 9500 characters needs `ffmpeg` to join the pieces (`brew install ffmpeg`).

## Keys

Enter your own ElevenLabs API key in each TTS extension's options. Nothing is bundled. An OpenAI key is optional; if you add one, a failed ElevenLabs request retries through OpenAI's `tts-1` voice `nova`. An OpenAI key alone also works.

Keys are read only from PopClip option fields. There is an off-by-default option, "Read keys from ~/.config/tts", which lets empty fields fall back to `~/.config/tts/elevenlabs_api_key` and `~/.config/tts/openai_api_key` if you prefer keeping keys in files.

Voice, model, speed, stability, and similarity are options too. The default voice is ElevenLabs' premade Rachel; swap in your own voice ID.

## Speech privacy and costs

Speech generation sends the selected text to ElevenLabs. If you configure OpenAI, it receives the text when ElevenLabs fails or when no ElevenLabs key is set. Provider API usage is billed to your accounts; these extensions do not set a spending cap. Leave the OpenAI key empty if you do not want automatic fallback to another provider.

The Save extension keeps generated MP3s until you remove them. Its default folder is in iCloud Drive, so files can sync to your other devices. Choose a local folder in its options if that is not what you want. Play uses temporary audio files and removes them when the script exits normally.

## Troubleshooting and contributions

If an action does nothing, first check the Python requirement above. For speech errors, check the key, voice ID, model access, and provider quota. Saving more than 9500 characters also requires `ffmpeg` on the extension's PATH. The scripts include the usual Apple silicon and Intel Homebrew paths.

Report bugs through this repository's Issues tab. Include the extension name, macOS and PopClip versions, and a small non-sensitive example selection. Do not include API keys or private text. For changes, keep the extension's `Config.yaml` or `Config.json` and script together and describe how you tested installation and the action in PopClip.

## License

MIT, see [LICENSE](LICENSE).
