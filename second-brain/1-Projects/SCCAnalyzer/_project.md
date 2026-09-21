---
type: project
created: 2026-09-20
updated: 2026-09-20
tags: [sccanalyzer, status]
project: SCCAnalyzer
---

# SCCAnalyzer — current status

**Repo:** `/Users/philipkim/Documents/SCCAnalyzer`  
**Branch (this Mac):** `MacOS` @ `ee93ddd`  
**Keep aligned:** `MacOS` / `Ubuntu` / `Android`

## Versions

| Component | Version |
|-----------|---------|
| Desktop | `3.17` (Tkinter / PyInstaller) |
| Android | **1.10.1** / versionCode **40** (installed on Fold) |
| Heartbeat geometry | Weekly **v3** (`indicators/heartbeat.py`); `daily_v2()` for regressions |

## What it is

Heavy **desktop analysis engine** (macOS + Linux) + slim **Android remote terminal**. Phone queues work to the desktop over ntfy; desktop does Ollama/RAG/Heartbeat; phone shows alerts/reports/charts.

## Shipped (as of 2026-09-20)

- Weekly Heartbeat v3 + remote `heartbeat_cycle` from phone
- Android slim companion (Agent home; Scan/Portfolio/Investment Trend UI removed)
- Multi-symbol remote queue (≤10), `clear_pending`, chat GUI actions
- Linux unattended host (systemd timer + remote-queue service, linger)
- Knowledge PDF sources in git (`knowledge_sources/`); `knowledge.db` local only
- Weekend manual Heartbeat force-run UX fix (`ee93ddd`)

## Open / next

1. Rebuild Mac `.app` with `./build_app.sh` when shipping packaged desktop
2. Confirm live pairing: `android_signing_secret` ≠ `android_ntfy_token`
3. Residual security P0 (topic hygiene, SSRF allowlist, Room encryption deferred)

## Do not

- Commit `*.db` / secrets / keystores
- Auto-start `ollama serve` from the app
- Use `pkexec` in setup scripts
- Generate new pairing on Linux if phone already paired to Mac identity (desync)

## Related Second Brain notes

- [[architecture]] → `architecture.md` (this folder)
- Lessons under `../../3-Resources/Lessons/` (reusable across programs)
- Git project memory: repo `memory-bank/` (tip-specific; not a substitute for this vault)
