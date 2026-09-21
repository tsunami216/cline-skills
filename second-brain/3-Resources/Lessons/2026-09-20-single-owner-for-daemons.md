---
type: lesson
created: 2026-09-20
updated: 2026-09-20
tags: [ollama, linux, systemd, ops]
project: SCCAnalyzer
---

# Don’t let the app and systemd both own Ollama / remote listeners

## Context
GUI and systemd both tried to run remote-queue / Ollama serve, causing dual listeners and overnight instability.

## Lesson
- **User’s terminal** owns `ollama serve`  
- App may **stop loaded models**, never start/restart the daemon  
- Disable system/user ollama units in unattended setup scripts  
- If a systemd `remote-queue` unit is active, GUI must **not** start a second SSE listener

## Rule for next time
One owner per long-lived socket/service. Encode the guard in code + docs.

## Related
- SCCAnalyzer: `ui/ollama_control.py`, `agents/remote_queue.py`, `scripts/enable_unattended_linux.py`
