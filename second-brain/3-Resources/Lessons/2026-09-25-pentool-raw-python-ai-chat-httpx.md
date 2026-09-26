---
type: lesson
created: 2026-09-25
updated: 2026-09-25
tags: [pentool, ollama, httpx, python, run.sh, misdiagnosis, local-network, ai-chat]
project: Pentool
---

# Pentool AI Chat: raw Python “no LAN” is usually missing httpx

## Audience

Small / weaker coding models. Read this **before** changing `build.sh`,
entitlements, or Local Network Settings when the user says:

> AI Chat tab cannot reach Ollama when running raw Python (`python3 main.py` / `./run.sh`)

**Different problem from the `.app` Local Network fix.** Do not mix them up.

## Two launch modes (pick one)

| Mode | How user launches | What controls LAN access |
|------|-------------------|---------------------------|
| **A. Compiled `.app`** | `open dist/Pentool.app` or `/Applications/Pentool.app` | macOS Local Network TCC + entitlements + Info.plist → see [[2026-09-23-macos-local-network-permission]] |
| **B. Raw Python** | `./run.sh` or `python3 main.py` | Usually **deps / which interpreter**, NOT Local Network |

Apple TN3179: **command-line tools started from Terminal** (and their children)
are auto-allowed for Local Network. So Terminal-launched `python3` should be
able to TCP to `192.168.1.22` without a Local Network toggle.

## Symptom that fools models

AI Chat status / error looks like:

- “Ollama not reachable at `http://192.168.1.22:11434`”
- “System Settings → Privacy & Security → Local Network → Enable Pentool”

That text lives in `controller.py` (`ai_load_models`). It was written for the
**`.app`** case. For raw Python it is often a **lie** — the real failure is
`ModuleNotFoundError: No module named 'httpx'` (or similar) swallowed / mislabeled.

## Root cause (verified 2026-09-25)

Commit switched Ollama from stdlib **`urllib`** → **`httpx`**.

| Interpreter | Typical launch | `httpx`? | AI Chat |
|-------------|----------------|----------|---------|
| Homebrew `python3` (3.14) | `python3 main.py` | **NO** | fails |
| Project `venv/` | `venv/bin/python main.py` | **NO** (if not installed) | fails |
| `.build-venv/` | after `./build.sh` | YES | works |
| Framework Python 3.12 | `./run.sh` (often picks this) | YES (if previously pip’d) | works |
| `Pentool.app` | Finder / `open` | bundled via `--collect-all httpx` | works (after Local Network grant) |

`run.sh` only checks `_tkinter` + `androguard`. It does **not** check `httpx`
and does **not** prefer `.build-venv`.

In `controller.py`, `import httpx` is often **outside** the `try` that maps
failures to friendly errors → worker thread can die, or empty model list →
UI blames Local Network.

## Diagnose (run these; do not skip)

From repo root `/Users/philipkim/Documents/pentool`:

```bash
# 1) Which Python will run?
./run.sh --check
which python3
python3 -c 'import sys; print(sys.executable)'

# 2) Is httpx installed THERE?
python3 -c 'import httpx; print(httpx.__version__)'
./run.sh --check | xargs -I{} {} -c 'import httpx; print("httpx OK", httpx.__version__)'

# 3) Can THIS machine reach Ollama at all? (Terminal = LAN allowed)
curl -sS -m 3 http://192.168.1.22:11434/api/version

# 4) Same check via the interpreter’s httpx (only if import works)
python3 -c 'import httpx; print(httpx.get("http://192.168.1.22:11434/api/version", timeout=5).text)'
```

### Decision tree

```
curl to Ollama fails?
  YES → network/Ollama server problem (not Pentool code)
  NO  → continue

httpx import fails on the interpreter the user launches?
  YES → THIS LESSON (missing dep). Fix below. Do NOT edit build.sh entitlements.
  NO  → httpx get /api/tags works?
          YES → UI/event bug or wrong base_url in ~/.config/pentool/config.json
          NO  → real connect error; check URL/firewall; only then consider TCC
                (and only if NOT launched from Terminal)
```

## How to fix (choose one path)

### Fix path 1 — Make raw Python use a complete env (preferred for `./run.sh`)

Goal: the launcher Python must have **everything in `requirements.txt`**, including `httpx`.

**Option 1a — Install into the interpreter `run.sh` already picks:**

```bash
PY=$(./run.sh --check)
"$PY" -m pip install -r requirements.txt
# If PEP 668 blocks system pip:
"$PY" -m pip install --user -r requirements.txt
# or create/use a venv (1b)
```

**Option 1b — Point `run.sh` at `.build-venv` (has deps after `./build.sh`):**

Edit `run.sh` candidate list so **`.build-venv/bin/python` is preferred** when it
exists and imports succeed, e.g. check:

```bash
"$c" -c 'import _tkinter, androguard, httpx'
```

not only `_tkinter, androguard`.

Minimal candidate addition (conceptually):

```bash
candidates=(
  "$HERE/.build-venv/bin/python"
  "/Library/Frameworks/Python.framework/Versions/3.12/bin/python3"
  # ... existing ...
)
```

Then:

```bash
./build.sh   # creates .build-venv + installs requirements + httpx
./run.sh     # should pick .build-venv if listed first and import check includes httpx
```

**Option 1c — Project venv:**

```bash
python3 -m venv venv
./venv/bin/pip install -r requirements.txt
./venv/bin/python main.py
```

### Fix path 2 — Stop misdiagnosing ImportError as Local Network

In `controller.py` methods `get_ollama_models`, `run_ai`, `ollama_test_connection`:

1. Put `import httpx` **inside** the `try`.
2. On `ImportError`, emit a clear message:

```text
httpx is not installed in this Python.
Install:  <interpreter> -m pip install httpx
Or run:   ./run.sh after installing requirements.txt
Or use:   open dist/Pentool.app
```

Do **not** tell the user to open Local Network Settings for an `ImportError`.

### Fix path 3 — User only needs the `.app`

If they only care about the packaged app:

```bash
./build.sh
cp -R dist/Pentool.app /Applications/
open /Applications/Pentool.app
# Click Allow on Local Network prompt
```

That path is covered by [[2026-09-23-macos-local-network-permission]].  
It does **not** fix raw `python3 main.py` without httpx.

## Hard rules for agents (do not violate)

1. **If launch is raw Python and `import httpx` fails → install httpx / fix run.sh. Stop.**
2. **Do not** “fix” raw-Python AI Chat by editing entitlements, `NSLocalNetworkUsageDescription`, or ATS.
3. **Do not** assume Homebrew `python3` == `./run.sh` Python. Always print `sys.executable`.
4. **Do not** treat “Ollama not reachable” UI copy as proof of Local Network denial.
5. For `.app` LAN failures only, follow [[2026-09-23-macos-local-network-permission]].

## Quick verification after fix

```bash
PY=$(./run.sh --check)
"$PY" -c 'import httpx; print(httpx.get("http://192.168.1.22:11434/api/tags", timeout=5).status_code)'
./run.sh
# AI Chat tab → status should show “Ollama ready — N model(s)”
# Test button → “Connected — Ollama …”
```

## Related

- [[2026-09-23-macos-local-network-permission]] — `.app` Local Network / entitlements (different bug)
- [[2026-09-23-pep668-externally-managed-environment]] — why system `pip install` may fail
- Project: [[../../1-Projects/Pentool/_project|Pentool]]
- Repo: `/Users/philipkim/Documents/pentool`
- Files: `run.sh`, `requirements.txt`, `controller.py`, `ui/ai_chat_tab.py`, `.build-venv/`
