---
type: lesson
created: 2026-09-24
updated: 2026-09-24
tags: [pyinstaller, macos, packaging]
project: OllamaConfigurator
---

# PyInstaller macOS `.app` version is not your Python `__version__`

## Context

Ollama Configurator showed **0.0.0** in Finder until `build.sh` patched `Info.plist` (`CFBundleShortVersionString` / `CFBundleVersion`). Runtime UI already read `ollama_configurator.__version__` = 1.0.0.

## What we learned

- Three version surfaces: Python `__version__`, Windows `file_version_info.txt`, macOS plist
- PyInstaller defaults the bundle to 0.0.0 unless you pass version metadata **and/or** patch plist after the build

## Rule for next time

When shipping a Mac `.app`, verify Finder version, not only the in-app About box. Patch plist in `build.sh` (or pass `--osx-bundle-identifier` + version args) in the same script that runs PyInstaller.

## Related

- `~/Documents/ollama-configurator/build.sh`
- SCCAnalyzer `./build_app.sh` has the same packaged-vs-source lag (Heartbeat v3 in source until rebuild)
