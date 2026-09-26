---
type: lesson
created: 2026-09-24
updated: 2026-09-24
tags: [git, branches, asr, macos, windows]
project: AI_Translator
---

# Keep platform ASR backends on separate branches

## Context

Same product, two stacks: macOS whisper.cpp/Metal vs Windows faster-whisper/CUDA. Mixing them on one branch produces broken installs and misleading README steps.

## What we learned

- `MacOS` = Metal + `./install_deps.sh` + `./build.sh`
- `main` = CUDA faster-whisper
- Shared product rules (Pause, SQLite path, Ollama not bundled) can stay conceptually aligned without sharing the ASR dependency tree

## Rule for next time

When native audio/ML backends diverge, split **branches** (or clearly isolated packages). Do not `#ifdef` two GPU stacks in one requirements file without a documented extra.

## Related

- [[../1-Projects/AI_Translator/_project|AI Translator status]]
- SCCAnalyzer uses the same idea: `MacOS` / `Ubuntu` / `Android` tips kept aligned, adapters isolated
