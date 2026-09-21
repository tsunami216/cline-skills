---
type: project
created: 2026-09-20
updated: 2026-09-20
tags: [sccanalyzer, architecture]
project: SCCAnalyzer
---

# SCCAnalyzer — product architecture

## High-level shape

```
┌─────────────────────┐     ntfy {topic}_cmd      ┌──────────────────────────┐
│ Android companion   │ ─────────────────────────►│ Desktop (Mac or Linux)   │
│ Agent / Alerts /    │                           │ RemoteAnalysisQueue      │
│ Reports / Markets   │ ◄─────────────────────────│ TaskManager + Ollama     │
│ (terminalMode)      │   signed JSON on {topic}  │ Heartbeat v3 + RAG       │
└─────────────────────┘                           └──────────────────────────┘
```

**Principle:** Phone is a **remote terminal**; desktop is the **always-on brain**.

## Layers

| Layer | Role | Key modules |
|-------|------|-------------|
| Desktop UI | Tk/`ttk` tabs | `StockChartApp.py`, `ui/*` |
| Analysis | Screening, desk DAG, chat actions | `agents/task_manager.py`, `agents/chat_actions.py` |
| Heartbeat | Weekly Stage geometry | `indicators/heartbeat.py` |
| Remote queue | FIFO jobs from phone | `agents/remote_queue.py` |
| Alerts / schedule | Triggers + push | `alerts/notify.py`, `alerts/launchd.py`, `alerts/jobs.py` |
| Knowledge | Local RAG | `ai/ingest.py`, `ai/knowledge.py`, `knowledge.db` |
| Android | Compose terminal | `RemoteCommandClient`, `AlertPushManager`, Room |

## Transport (ntfy)

| Channel | Direction | Payload |
|---------|-----------|---------|
| `{topic}_cmd` | Phone → desktop | Analyze, multi-symbol, chat, `clear_pending`, `heartbeat_cycle` |
| `{topic}` | Desktop → phone | Alerts, signed `agent_report` attachments, `heartbeat_cycle_status` |
| LAN relay | Optional | Same topics on LAN IP for Wi‑Fi phones |
| Auth | Both | Bearer ntfy token; HMAC **signing_secret** on reports/commands |

**Identity lives in `alerts.db`**, not `ai_settings.json`. Export ZIP historically omits `alerts.db` — copy secrets deliberately on Mac→Linux cutover.

## Data locations

| OS | User data |
|----|-----------|
| macOS | `~/Library/Application Support/SCCAnalyzer/` |
| Linux | `~/.config/sccanalyzer/` |
| Android | Room `sccanalyzer.db` + EncryptedSharedPreferences |

Override desktop: `SCCANALYZER_SETTINGS_DIR`.

## Branch / release model

- Product branches: `MacOS`, `Ubuntu`, `Android` — keep tips aligned after merges
- Desktop packaged via PyInstaller (`build_app.sh` → `dist/SCCAnalyzer.app`) — still **Tkinter**, not PySide
- Android release: Gradle `assembleRelease` + shared keystore (`key.properties` / cursor_chat jks)

## Companion product decisions

- **terminalMode=true:** no on-device S&P scanner / portfolio vault UI
- Agent is home; Heartbeat runs on desktop when phone requests it
- Reports are JSON (+ local PDF export), not Mac-pushed PDFs

## Reusable pattern (other programs)

See `../../3-Resources/Lessons/` for distilled cross-product lessons (remote-terminal split, pairing secrets, fd hygiene, memory bank vs second brain).
