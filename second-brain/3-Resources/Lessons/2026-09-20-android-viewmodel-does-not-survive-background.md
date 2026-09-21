---
type: lesson
created: 2026-09-20
updated: 2026-09-20
tags: [android, coroutines, sse, foreground-service]
project: CursorChat
---

# Do not own long SSE/network jobs in ViewModel scope

## Context
Cursor Chat lost in-flight AI replies when the user backgrounded the app after sending.

## What went wrong / what we learned
`viewModelScope` is cancelled when the chat `ViewModel` is cleared (leave screen / process stop). OkHttp SSE dies with the job. Android may also kill the process without a foreground service.

Fix: **Application-scoped** coordinator + **dataSync FGS** while a run is in flight. Persist partial/final replies in Room. On Wi‑Fi↔cellular, treat socket errors as transient: wait for network, reconnect SSE / poll run status, else show **Retry**.

## Rule for next time
User-requested network work that must finish off-screen: not `viewModelScope`. Use app/process scope + FGS (or WorkManager if deferrable). `onCleared` must not cancel the cloud run.

## Related
- Cursor Chat 1.0.17: `AgentRunCoordinator`, `AgentRunService`, commit `f60558e`
- Project: `../../1-Projects/CursorChat/architecture.md`
