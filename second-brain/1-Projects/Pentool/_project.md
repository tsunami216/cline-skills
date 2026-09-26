---
type: project
created: 2026-09-23
updated: 2026-09-25
tags: [pentesting, desktop, python, tkinter, nmap, ollama, pyinstaller, macos]
project: Pentool
---

# Pentool — current status

**Repo:** `/Users/philipkim/Documents/pentool`
**GitHub:** https://github.com/tsunami216/pentool
**Branch:** `main`

## Versions

| Component | Version |
|-----------|---------|
| App | **0.1.0** (`__init__.py`) |
| Python | 3.14 (Homebrew) |
| nmap | 7.991 (`/opt/homebrew/bin/nmap`) |
| Ollama | remote at `http://192.168.1.22:11434` (gemma4:e4b, 8 models) |
| Packaging | PyInstaller via `build.sh` → `dist/Pentool.app` |

## What it is

Python **tkinter** desktop GUI for authorized penetration testing — 9 tabs:

1. **Network** — nmap port scan + service version + CVE matching
2. **Android** — APK security audit (permissions, exported components, certs)
3. **Reports** — HTML export with severity summary
4. **Exploits** — Type-specific CVE dispatch (Zerologon, EternalBlue, SSH, SMB, Telnet, UPnP)
5. **Payloads** — Reverse shells (bash/python) + PHP webshells
6. **Privesc** — SUID, sudo NOPASSWD, kernel CVEs, cron, writable dirs
7. **Recon** — Host discovery, port scan, service enumeration
8. **Terminal** — PTY-based post-exploitation shell
9. **AI Chat** — Ollama LLM assistant (explains findings, suggests next steps)

## Shipped (as of 2026-09-23)

- All 9 tabs with working backends
- AI Chat: Ollama connection panel (URL entry, Test, Apply & Refresh)
- AI Chat: persistent config at `~/.config/pentool/config.json`
- AI Chat: **verified working** — 5s response from gemma4:e4b via `/api/chat`
- macOS network permission: `build.sh` → Pentool.app with `NSLocalNetworkUsageDescription`
- Pre-flight network check (`core/network_check.py`) — warns if nmap blocked
- Event-driven UI (controller → queue → tab.handle())
- Two-phase nmap (fast port check → `-sV` on open ports only)
- Finding dataclass as universal output across all engines
- Auth gate ("I own this target") before every action
- **Build fixes**: PEP 668 (venv), androguard/frida (exclude), optional imports (try/except)

## Key files

| File | Purpose |
|------|---------|
| `main.py` | Entry point — Tk window, tab notebook, controller wiring |
| `controller.py` | Orchestrator — worker threads, event emission, Ollama integration |
| `build.sh` | PyInstaller build → Pentool.app (venv-based, PEP 668 safe, frida excluded) |
| `core/network_check.py` | Pre-flight nmap + socket check for macOS |
| `core/ollama_config.py` | OllamaConfig dataclass (base_url, default_model) |
| `ui/ai_chat_tab.py` | AI Chat tab (connection panel, streaming, history) |
| `ui/panel.py` | FindingsPanel base class (all other tabs) |

## Build issues resolved

| Issue | Fix |
|-------|-----|
| PEP 668 (`externally-managed-environment`) | `.build-venv/` in `build.sh` |
| `androguard.pentest` → `import frida` (missing) | `--hidden-import androguard.core.apk` + `--exclude-module frida` |
| `core.network_check` import crash (optional deps) | try/except in `main.py` |

## Open / next

1. **Raw Python AI Chat:** ensure launch interpreter has `httpx` (`run.sh` check + install, or prefer `.build-venv`) — see lesson below
2. Stop mislabeling `ImportError: httpx` as Local Network in `controller.py`
3. Unit tests for core engines
4. Unify Recon tab with `core/recon_engine.py`
5. Logging / audit trail
6. Windows `.exe` packaging
7. Windows privesc: real checks (currently WinPEAS recommendation only)

## Do not

- Run nmap against targets you don't own
- Commit config JSON with API keys or bearer tokens
- Build with system `pip install` — always use `.build-venv/` (PEP 668)
- Use `--collect-all` for packages with heavy optional submodules — use `--hidden-import` + `--exclude-module`
- Assume Ollama is at `localhost` — Pentool uses remote `192.168.1.22:11434`
- Treat AI Chat “Ollama not reachable” under raw Python as a Local Network / `build.sh` problem until `import httpx` succeeds on that interpreter

## Related Second Brain notes

- [[architecture]] → `architecture.md` (this folder)
- Lesson: [[../../3-Resources/Lessons/2026-09-25-pentool-raw-python-ai-chat-httpx|Raw Python AI Chat = missing httpx (not Local Network)]]
- Lesson: [[../../3-Resources/Lessons/2026-09-23-macos-local-network-permission|macOS Local Network Permission (.app only)]]
- Lesson: [[../../3-Resources/Lessons/2026-09-23-pep668-externally-managed-environment|PEP 668 (externally-managed-environment)]]
- Lesson: [[../../3-Resources/Lessons/2026-09-23-optional-import-resilience|Optional Import Resilience]]
- Lesson: [[../../3-Resources/Lessons/2026-09-23-event-driven-connection-panel|Event-Driven Connection Panel]]
- Lesson: [[../../3-Resources/Lessons/2026-09-23-pyinstaller-collect-all-vs-hidden-import|PyInstaller --collect-all vs --hidden-import]]
- Related project: [[../OllamaConfigurator/_project|Ollama Configurator]] (same PyInstaller pattern)
