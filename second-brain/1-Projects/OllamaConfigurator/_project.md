---
type: project
created: 2026-09-20
updated: 2026-09-24
tags: [ollama, desktop, python, customtkinter, pyinstaller]
project: OllamaConfigurator
---

# Ollama Configurator — current status

**Repo:** `/Users/philipkim/Documents/ollama-configurator`  
**GitHub:** https://github.com/tsunami216/ollama-configurator (private)  
**Branch:** `main` (single branch for macOS + Windows packaging)

## Versions

| Component | Version |
|-----------|---------|
| App | **1.0.0** (`ollama_configurator.__version__`) |
| Packaging | PyInstaller; macOS `.app` via `build.sh`, Windows `.exe` via `build.ps1` / `build.bat` |

## What it is

Python **CustomTkinter** desktop GUI to manage a **local or remote** Ollama HTTP API:

- Test connection, list / pull / delete models
- Running models via `GET /api/ps` (GPU/CPU **memory placement**, context length, totals)
- Unload / reload / warm-load (not OS process restart)

Settings: `~/.config/ollama-configurator/config.json` (Windows: `%APPDATA%\…`). Optional Bearer + insecure TLS for proxied remotes.

## Shipped (as of 2026-09-20)

- Core GUI + httpx client
- Remote `/api/ps` enriched view (processor %, VRAM vs RAM bytes, context)
- macOS icon (`.icns`) + Windows `.ico` / `file_version_info.txt`
- `build.sh` patches `Info.plist` so Finder shows **1.0.0** (not PyInstaller default 0.0.0)
- Windows packaging scripts on `main` (build `.exe` on a Windows PC)

## Open / next

1. Build/smoke-test Windows `.exe` on a real Windows machine
2. Optional: code signing / installer (out of scope so far)
3. Optional: UI tip that `/api/ps` ≠ live GPU SM util / `nvidia-smi`

## Do not

- Treat Unload/Reload as remote `systemctl` restart
- Commit config JSON with bearer tokens
- Expect cross-compile of Windows `.exe` from macOS
- Confuse `ollama ps` GPU% (memory placement) with `nvidia-smi` Util%

## Related Second Brain notes

- [[architecture]] → `architecture.md` (this folder)
- Lesson: [[../../3-Resources/Lessons/2026-09-20-ollama-vram-context-gpu-cpu|Ollama VRAM / context / GPU vs CPU]]
- Lesson: [[../../3-Resources/Lessons/2026-09-24-pyinstaller-macos-bundle-version-plist|PyInstaller macOS bundle version]]
- Git tip `1a129a2` (Finder version 0.0.0 fix)
- Hardware context: Linux dual **5060 Ti** (~32 GB total VRAM) for remote Ollama
