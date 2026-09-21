---
type: lesson
created: 2026-09-20
updated: 2026-09-20
tags: [python, sqlite, linux, gui]
project: SCCAnalyzer
---

# Long-running Python GUIs: close SQLite / yfinance fds or you will EMFILE

## Context
Linux GUI froze after screen lock; root cause was file-descriptor exhaustion from leaked sqlite connections and yfinance/peewee caches.

## Lesson
- Avoid `with sqlite3.connect(...)` held across long lifetimes in daemon/GUI code
- Use a shared helper that always closes (`app.sqlite_conn.connect`)
- Clean thread-local caches on worker exit (`app.yfinance_runtime`)
- Cap SSE/handler concurrency and raise `nofile` for relay services

## Rule for next time
Any 24/7 Python process + sqlite/network: budget fds explicitly; add a leak test early on Linux.

## Related
- SCCAnalyzer: `app/sqlite_conn.py`, `app/yfinance_runtime.py`, ntfy relay keepalive work
