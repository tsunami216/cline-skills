---
type: project
created: 2026-09-23
updated: 2026-09-23
tags: [pentool, architecture, tkinter, nmap, ollama]
project: Pentool
---

# Pentool — architecture

## Layout

```
pentool/
  main.py              # Entry point — Tk window, tabs, controller, network check
  controller.py        # Orchestrator — worker threads, events, Ollama integration
  build.sh             # PyInstaller → dist/Pentool.app (venv-based)
  run.sh               # Dev launcher — picks Python with Tk + androguard
  report.py            # HTML report generation
  requirements.txt     # nmap, paramiko, PyInstaller, pycryptodome, androguard

  ui/                  # 9 tkinter tabs + shared panel
    panel.py           # FindingsPanel base (progress, tree, status, events)
    network_tab.py
    android_tab.py
    reports_tab.py
    exploits_tab.py
    payloads_tab.py
    privesc_tab.py
    recon_tab.py
    terminal_tab.py
    ai_chat_tab.py     # Standalone (NOT FindingsPanel) — own event handling
    theme.py           # ttk colors, button styles

  core/                # Engines (called by controller)
    exploit_engine.py  # Two-phase nmap + CVE dispatch
    priv_esc.py        # SUID, sudo, kernel, cron, writable dirs
    recon_engine.py    # nmap XML parsing
    payload_gen.py     # Reverse shells + webshells
    terminal.py        # PTY shell
    post_exploit.py    # Persistence, recon commands
    ollama_config.py   # OllamaConfig (base_url, default_model)
    network_check.py   # Pre-flight macOS network permission check

  engines/             # Higher-level scan engines
    base.py            # Finding dataclass + Severity enum
    network.py         # nmap scan + CVE matching
    android.py         # APK audit
    code.py            # Vulnerability scanner
    auth_audit.py      # Credential exposure audit

  payloads/            # EDB downloader, nikto wrapper
  reports/             # HTML/Markdown renderer
  utils/               # auth_gate.py
  tests/               # test_auth_audit.py
  memory-bank/         # 6-file project memory
```

## Data flow

```
User action (tab button)
  → Controller.run_*()
    → _run() spawns worker thread
      → Engine (nmap, androguard, etc.)
        → Emits Finding dataclass via self._emit()
          → Controller.events queue (thread-safe)
            → main.py drain() (100ms poll)
              → tab.handle(kind, payload)
                → UI update (tree row, status, progress)
```

## AI Chat flow

```
User types question
  → AIChatTab._on_send()
    → Controller.run_ai(prompt, tab_context, model)
      → Worker thread:
        → Builds system prompt (tab desc + current findings)
        → urllib.request.urlopen(POST /api/chat, stream=True)
        → Emits ai_chunk(token) per line
        → Emits ai_done(full_text)
      → AIChatTab.handle("ai_chunk", token) → appends to ScrolledText
      → AIChatTab.handle("ai_done", text) → enables input
```

## Ollama config

- `core/ollama_config.py`: `OllamaConfig` dataclass
- Persists to `~/.config/pentool/config.json`
- Override path: `PENTOOL_CONFIG` env var
- Pattern mirrors `ollama-configurator/config.py`

## macOS network permission

```
build.sh
  → python3 -m venv .build-venv
  → .build-venv/bin/pip install -r requirements.txt + pyinstaller
  → .build-venv/bin/python -m PyInstaller --windowed --osx-bundle-identifier com.tsunami216.pentool
  → PlistBuddy: Add NSLocalNetworkUsageDescription to Info.plist
  → codesign --force --deep --sign - (ad-hoc)
  → dist/Pentool.app

First launch:
  → macOS: "Pentool would like to find and connect to devices on your local network"
  → User clicks Allow
  → nmap works permanently
```

## Key patterns

| Pattern | Where | Why |
|---------|-------|-----|
| Finding dataclass | `engines/base.py` | Universal output shape across all engines |
| FindingsPanel | `ui/panel.py` | Shared UI: progress bar, severity tree, status bar |
| Worker thread | `controller._run()` | UI stays responsive during scans |
| Event queue | `controller.events` | Thread-safe communication (queue.Queue) |
| Two-phase nmap | `core/exploit_engine.py` | Fast first pass → `-sV` only on open ports |
| Optional import | `main.py` | `network_check` wrapped in try/except |
| Venv build | `build.sh` | PEP 668 safe (Homebrew Python) |
| Config persistence | `core/ollama_config.py` | JSON at `~/.config/pentool/config.json` |

## Threading model

- Main thread: Tk event loop + `drain()` (100ms poll of event queue)
- Worker threads: one per user action (scan, exploit, AI chat)
- AI Chat: dedicated thread for streaming urllib reads
- Ollama model load: background thread (non-blocking)
- Network check: synchronous at startup (max 3s socket timeout)
