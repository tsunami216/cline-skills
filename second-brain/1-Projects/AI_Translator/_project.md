---
type: project
created: 2026-09-24
updated: 2026-09-24
tags: [ai-translator, macos, pyqt6, whisper, ollama]
project: AI_Translator
---

# AI Translator — current status

**Repo:** `/Users/philipkim/Documents/AI_Translator`  
**Branch (this Mac):** `MacOS` @ `540bd54`  
**Windows/CUDA:** `main` (faster-whisper)

## What it is

Offline **EN speech → KO text** desktop app: microphone → ASR → Ollama Korean translation → SQLite + PDF export.

## Versions / stack

| Item | Live |
|------|------|
| UI | PyQt6 |
| macOS ASR | whisper.cpp via **pywhispercpp** (Metal; not the CPU-only PyPI wheel) |
| Windows ASR | faster-whisper / CUDA (`main`) |
| Translate | Ollama (`translategemma:4b` in docs) — **not bundled** in the `.app` |
| Data | SQLite `translations.db` |

## Shipped (as of 2026-09-24)

- Listen pipeline with VAD phrase-break (~400–450 ms silence)
- Backlog status (`Backed up: N`) clears when queues catch up (`540bd54`)
- macOS `.app` via `./build.sh` (mic entitlement, ad-hoc sign; not notarized)
- Pause clears listen queues (in-flight translate may finish)

## Open / next

- Feature plan still draft: session memory threads, icon, local API usage, clickable links (`.plan/features-enhancement.plan.md`)
- Developer ID + notarization if sharing the `.app` off this Mac

## Do not

- `pip install pywhispercpp` alone on Mac — those wheels are CPU-only; use `./install_deps.sh`
- Bundle Ollama inside the app
- Treat phrase-break delay as translation latency (ASR + Ollama run after the chunk)

## Related

- [[architecture]] → `architecture.md`
- Repo has **no** `memory-bank/`; this vault is the distilled architecture
- Lessons under `../../3-Resources/Lessons/`
