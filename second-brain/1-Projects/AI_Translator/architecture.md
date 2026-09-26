---
type: project
created: 2026-09-24
updated: 2026-09-24
tags: [ai-translator, architecture]
project: AI_Translator
---

# AI Translator — product architecture

## High-level shape

```
Mic (sounddevice)
  → VAD utterance collector (silence ~400–450 ms)
  → ASR (whisper.cpp Metal on MacOS / faster-whisper CUDA on main)
  → junk / duration / energy gates
  → Ollama (KO text)
  → SQLite repository + optional PDF export
```

**Principle:** Capture stays live; ASR and translation can lag. UI shows a **backlog**, not a blocked mic.

## Layers

| Layer | Role | Key modules |
|-------|------|-------------|
| UI | PyQt6 window | `src/ai_translator/ui/main_window.py` |
| Pipeline | Listen worker, queues, Pause | `pipeline/listening_worker.py` |
| VAD | Utterance segmentation | `vad/segmenter.py` |
| ASR | whisper.cpp wrapper | `asr/whisper_cpp_asr.py`, `asr/gates.py` |
| Translate | HTTP to local Ollama | `ollama/client.py` |
| Persist | SQLite | `db/schema.py`, `db/repository.py` |
| Export | PDF | `export/pdf_exporter.py` |

## Data locations

| Mode | SQLite |
|------|--------|
| Dev | `translations.db` in the launch cwd |
| Frozen `.app` | `~/Library/Application Support/AI_Translator/translations.db` |

## Branch split (do not mix)

| Branch | ASR | GPU |
|--------|-----|-----|
| `MacOS` | whisper.cpp / pywhispercpp | Metal |
| `main` | faster-whisper | CUDA |

## Packaging (macOS)

- `./install_deps.sh` then `./build.sh` → `dist/AI_Translator.app`
- Mic usage string in the bundle; ad-hoc `codesign`
- Ollama remains a **separate** install (`ollama pull …`)

## Reusable patterns

See `../../3-Resources/Lessons/` (Metal wheels vs PyPI, platform ASR on separate branches).
