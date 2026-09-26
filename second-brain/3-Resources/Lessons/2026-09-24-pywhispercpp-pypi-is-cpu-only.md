---
type: lesson
created: 2026-09-24
updated: 2026-09-24
tags: [macos, whisper, pip, metal, packaging]
project: AI_Translator
---

# PyPI `pywhispercpp` wheels are CPU-only

## Context

AI Translator on `MacOS` needs Metal ASR. `pip install pywhispercpp` from PyPI installs a CPU wheel. First Listen then looks “installed” but never uses the GPU.

## What we learned

- Use the repo `./install_deps.sh` (builds pywhispercpp with Metal; arm64-only on Apple Silicon).
- Do not document “pip install the ASR extra” as sufficient on Mac.
- Ollama is a **separate** process; do not assume the `.app` bundle includes it.

## Rule for next time

If a Mac ML wheel exists on PyPI and a from-source Metal build exists in-repo, treat PyPI as the **wrong** default. Script the GPU build.

## Related

- `~/Documents/AI_Translator/install_deps.sh`
- [[../1-Projects/AI_Translator/architecture|AI Translator architecture]]
