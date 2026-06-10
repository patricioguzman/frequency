# Frequency

**Offline beatmaking app for Android — no samples, pure synthesis.**

Two-deck DJ interface with procedural audio generation. Everything runs locally in a WebView — zero network, zero external files, zero ads.

## Features

- **5 synth patterns**: Kick, Hi-Hats, Snare, Bass, Pad — generated in real-time with Web Audio API
- **2 independent decks** with play/stop/cue, pitch ±8%, 3-band EQ
- **Crossfader** with equal-power curve
- **FX chain**: Filter (lowpass), Delay, Reverb — all with adjustable parameters
- **Sync B→A** by BPM
- **20 KB APK** — everything is code, no assets

## How it works

All audio is synthesized procedurally in JavaScript using oscillators, noise functions, envelopes, and filters. The WebView loads a single HTML file from the APK's assets — no HTTP server, no internet permission needed.

## Build

```bash
./build.sh                    # uses /tmp/debug.keystore
./build.sh path/to/release.jks myalias
```

Requires:
- Android SDK (build-tools + platform)
- Java 8+

## Install

```bash
adb install -r frequency.apk
```

## Screenshot

Two-deck view with pattern selector, pitch, EQ, crossfader, and FX panel. Tap the screen to start audio (required by browser autoplay policy).

## License

MIT
