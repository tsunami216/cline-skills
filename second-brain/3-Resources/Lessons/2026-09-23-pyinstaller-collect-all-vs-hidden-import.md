---
title: PyInstaller --collect-all vs --hidden-import (heavy optional deps)
date: 2026-09-23
project: Pentool
tags: [pyinstaller, packaging, androguard, frida, macos, build]
status: lesson-learned
---

# PyInstaller --collect-all vs --hidden-import

## Problem

`--collect-all androguard` in a PyInstaller build script pulls in **every** submodule of androguard, including `androguard.pentest` which imports `frida` — a massive optional dependency that isn't installed.

**Error:**
```
ModuleNotFoundError: No module named 'frida'
  File "/.../androguard/pentest.py", line 47, in <module>
    import frida
```

## Root Cause

PyInstaller's `--collect-all` scans ALL submodules of the package and tries to import them at analysis time. If any submodule has an unconditional `import` of a missing dependency, the build fails.

`androguard` has this structure:
```
androguard/
├── core─ apk.py          ← WE USE THIS
│   ├── analysis.py     ← WE USE THIS
│   └── ...
└── pentest.py          ← imports frida (NOT needed, NOT installed)
```

## Solution

**Before (broken):**
```bash
--collect-all androguard
```

**After (working):**
```bash
# Only include what we actually use
--hidden-import androguard.core.apk
--hidden-import androguard.core.analys
**Error:**
```
ModuleNotFoundError: No module named 'frida'
  File "/.../androguard/pentest.py", line 47, in <module
## Key Principles

1. **Prefer specific over broad**: `--hidden-import` for specific modules > `--collect-all` for whole packages
2. **`--collect-all` is a sledgehammer**: It forces PyInstaller to import every submodule during analysis. If ANY submodule has a missing dep, the build crashes.
3. **`--exclude-module` is your friend**: Even if you use `--collect-all`, adding `--exclude-module` for known bad submodules can save the build.
4. **Test in isolation first**: Before building, verify which submodules you actually use:
   ```bash
   python3 -c "import androguard.core.apk; print('ok')"
   python3 -c "imp```

## Solution

**Before (broken):**
```bash
--collect-all androg```

## When to use --collect-all

Only when the package genuinely needs data files, templates, or resources from ALL submodules (e.g., `--collect-all nltk` for corpora). For code-only packages, use `--hidden-import` for the specific modules  File "/.../androguard/pentest.py", line 4 `build.sh` — androguard APK analysis
- **Any PyInstaller project**: packages with optional/heavy submodules
- **Similar patterns**: `requests` (doesn't have this issue), but packages like `wandb`, `mlflow`, `airflow` all have optional submodules that `--collect-all` would pull in
