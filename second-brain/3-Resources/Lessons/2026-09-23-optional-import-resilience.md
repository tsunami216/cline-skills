---
type: lesson
created: 2026-09-23
updated: 2026-09-23
tags: [python, tkinter, imports, resilience, optional-dependencies]
project: Pentool
---

# Optional Import Pattern — App Must Launch Even If Non-Critical Modules Fail

## Problem

Adding a new module (e.g., `core/network_check.py`) and importing it unconditionally in `main.py`
caused the **entire app to crash** if the import failed (missing dependency, path issue, etc.).
The user couldn't even open the AI Chat tab to talk to Ollama.

## The Bad Pattern

```python
# main.py — crashes if network_check has any issue
from pentool.core.network_check import run_check, show_macos_network_warning
```

If `pentool.core.network_check` fails to import (wrong path, missing dep, syntax error),
the entire app dies before the Tk window even appears.

## The Fix

```python
# main.py — app always launches, network check is a bonus
try:
    from pentool.core.network_check import (
        run_check as _run_net_check,
        show_macos_network_warning as _show_net_warn,
    )
except ImportError:
    _run_net_check = None
    _show_net_warn = None

def _check_network_permissions(root):
    if _run_net_check is None:
        return  # graceful no-op
    try:
        result = _run_net_check()
        if not result.ok and _show_net_warn is not None:
            _show_net_warn(root)
    except Exception:
        pass  # never block app launch
```

## Rules

1. **Core imports** (controller, UI tabs) — let them fail loudly. If the app can't run without them, crash is correct.
2. **Enhancement imports** (network check, analytics, telemetry) — wrap in `try/except ImportError`, set to `None`, guard the call site.
3. **Always catch `Exception` at the call site** — even if the import succeeded, the function might fail at runtime (socket timeout, missing nmap, etc.)
4. **Never let a non-critical feature block the app from starting**

## When to use

| Module type | Pattern |
|------------|---------|
| Core (controller, UI, theme) | Direct import — crash is correct |
| Enhancement (network check, logging, analytics) | `try/except ImportError` + `None` guard |
| Optional backend (Ollama, database) | Lazy import inside the function that uses it |

## Key takeaway

> A "nice to have" module must never prevent the app from launching.
> Wrap optional imports in `try/except`, guard call sites with `None` checks,
> and catch runtime exceptions at the call site.

## Related

- Project: [[../../1-Projects/Pentool/_project|Pentool]]
- Source: `pentool/main.py` lines 58-77
