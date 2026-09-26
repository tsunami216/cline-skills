---
type: lesson
created: 2026-09-24
updated: 2026-09-24
tags: [python, venv, macos]
project: SCCAnalyzer
---

# Compare venvs with `sys.prefix`, not `os.path.samefile(executable)`

## Context

SCCAnalyzer keep-awake / venv detection broke when comparing interpreter paths with `os.path.samefile` on the executable (symlinks, PyInstaller, pythonw).

## What we learned

Use `sys.prefix` (the environment root) as the identity of the venv. Executable path equality is unstable across `python` vs `python3`, caffeinate wrappers, and frozen apps.

## Rule for next time

Any “are we in the project venv?” check: compare prefixes. Do not `samefile` two argv0s.

## Related

- SCCAnalyzer `alerts/keep_awake.py`
- [[../1-Projects/SCCAnalyzer/architecture|SCCAnalyzer architecture]]
