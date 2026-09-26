---
type: lesson
created: 2026-09-23
updated: 2026-09-23
tags: [python, pip, pep668, homebrew, venv, build]
project: Pentool
---

# PEP 668 — Homebrew Python "externally-managed-environment"

## Problem

Running `pip install` on Homebrew Python 3.14 (macOS) fails:

```
error: externally-managed-environment
× This environment is externally managed
╰─> To install Python packages system-wide, try brew install
```

This affects **any** build script that does `pip install` directly on the system Python.

## Root cause

PEP 668 (Python 3.11+) marks the Homebrew-managed Python as "externally managed."
The intent: prevent `pip install` from breaking the Homebrew-managed environment.
Homebrew owns the Python installation and its site-packages.

## Solutions (ranked)

### 1. Virtual environment (BEST — used by Pentool build.sh)

```bash
python3 -m venv .build-venv
.build-venv/bin/pip install -r requirements.txt
.build-venv/bin/pip install pyinstaller
.build-venv/bin/python -m PyInstaller ...
```

**Why:** Isolated, reproducible, no system pollution. The venv is gitignored.

### 2. `pipx` (for CLI tools only)

```bash
brew install pipx
pipx install pyinstaller
```

**Why:** `pipx` creates an isolated venv per tool. Good for CLI utilities, NOT for app dependencies.

### 3. `--break-system-packages` (DANGER)

```bash
pip install --break-system-packages pyinstaller
```

**Why NOT:** Can break Homebrew's Python. Only use in throwaway containers.

### 4. `break-system-packages = true` in pip.conf (PERMANENT DANGER)

```ini
# ~/.config/pip/pip.conf
[global]
break-system-packages = true
```

**Why NOT:** Permanently disables the protection. All future `pip install` will hit system Python.

## Pattern for build scripts

```bash
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$ROOT/.build-venv"

# Create venv if missing
if [[ ! -f "$VENV_DIR/bin/python" ]]; then
  python3 -m venv "$VENV_DIR"
fi

# Use venv's pip (not system pip)
VENV_PIP="$VENV_DIR/bin/pip"
VENV_PYTHON="$VENV_DIR/bin/python"

"$VENV_PIP" install -q --upgrade pip
"$VENV_PIP" install -q -r requirements.txt
"$VENV_PIP" install -q pyinstaller

# Build with venv Python
"$VENV_PYTHON" -m PyInstaller ...
```

## Key takeaway

> On Homebrew macOS Python, **never** `pip install` into the system environment.
> Always create a venv for builds. Add `.build-venv/` to `.gitignore`.

## Related

- Lesson: [[2026-09-23-macos-local-network-permission|macOS Local Network Permission]]
- Project: [[../../1-Projects/Pentool/_project|Pentool]]
- Source: `pentool/build.sh`
