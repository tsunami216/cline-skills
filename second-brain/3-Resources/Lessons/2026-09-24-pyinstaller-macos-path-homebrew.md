# Lesson: PyInstaller .app bundles have a minimal PATH

**Date:** 2026-09-24
**Project:** Pentool
**Tag:** packaging, macos, pyinstaller, path

## The Problem

When a PyInstaller-compiled `.app` bundle is launched from Finder or Dock, the
`PATH` environment variable is minimal:

```
/usr/bin:/bin:/usr/sbin:/sbin
```

This does **not** include Homebrew's `/opt/homebrew/bin` (Apple Silicon) or
`/usr/local/bin` (Intel). So `shutil.which("nmap")`, `shutil.which("nikto")`,
etc. all return `None` even though the tools are installed.

Running from Terminal works fine because the shell sets up the full PATH before
launching the process.

## Symptom

- App says "nmap not found. Install with: brew install nmap" — but it IS installed
- Only happens in the compiled `.app`, not in `python3 main.py`
- Affects ALL external tools not in `/usr/bin` or `/bin`

## The Fix

Add a `core/tool_paths.py` module that augments PATH at startup:

```python
EXTRA_PATH_DIRS = [
    "/opt/homebrew/bin",      # Homebrew Apple Silicon
    "/opt/homebrew/sbin",
    "/usr/local/bin",         # Homebrew Intel
    "/usr/local/sbin",
    "/usr/bin",
    "/bin",
    "/usr/sbin",
    "/sbin",
]

def ensure_path() -> None:
    """Call once at app startup. Modifies os.environ['PATH'] globally."""
    current = os.environ.get("PATH", "").split(":")
    for d in reversed(EXTRA_PATH_DIRS):
        if d not in current:
            current.insert(0, d)
    os.environ["PATH"] = ":".join(current)
```

Then in `main.py`, call `ensure_path()` before anything else:

```python
from core.tool_paths import ensure_path
ensure_path()
```

For extra safety, also provide a `subprocess_env()` helper that returns a
dict with augmented PATH, and pass it to every `subprocess.run(..., env=env)`.

## Why This Matters

This is a **universal problem** for any macOS GUI app built with PyInstaller
that shells out to Homebrew-installed tools. It affects:
- nmap (network scanning)
- nikto (web scanning)
- git (if installed via Homebrew instead of Xcode CLT)
- Any other `brew install` tool

## Alternatives Considered

| Approach | Problem |
|----------|---------|
| Hardcode `/opt/homebrew/bin/nmap` | Breaks on Intel Macs, not portable |
| Use `shutil.which` with fallback list | Works but repetitive across 8+ call sites |
| Symlink into `/usr/bin` | Requires sudo, not portable |
| **`ensure_path()` at startup** | Clean, one-time, fixes all subprocess calls globally |

## Key Insight

`os.environ["PATH"]` is process-global. Setting it once at startup fixes ALL
subsequent `shutil.which()` and `subprocess.run()` calls in the process.
No need to pass `env=` to every single subprocess call (though doing so is
defense-in-depth).

## Files

- `/Users/philipkim/Documents/pentool/core/tool_paths.py` — the fix
- `/Users/philipkim/Documents/pentool/main.py` — calls `ensure_path()`

## Tags

#pyinstaller #macos #path #homebrew #app-bundle #subprocess #shutil.which