---
type: lesson
created: 2026-09-23
updated: 2026-09-25
tags: [macos, network, nmap, permissions, pyinstaller, pep668, httpx, entitlements, codesign, ats]
project: Pentool
---

# macOS Local Network Permission — Complete Fix (Verified Working)

## Problem

Pentool compiled with PyInstaller could **not** reach Ollama at `http://192.168.1.22:11434`
or run nmap scans. No error, no prompt — just silent network failure.

SCCAnalyzer (same machine, same Ollama) worked fine.

**Scope of THIS lesson:** the packaged **`.app` only**. If AI Chat fails under
**raw** `python3 main.py` / `./run.sh`, that is usually **missing `httpx`**, not
Local Network — see [[2026-09-25-pentool-raw-python-ai-chat-httpx]].

## Root Cause (4 Compounding Issues)

| # | Issue | Why it broke things |
|---|-------|-------------------|
| 1 | **No `--osx-entitlements-file` in PyInstaller** | PyInstaller signed the bundle *without* entitlements during build |
| 2 | **Missing `disable-library-validation`** | PyInstaller bundles third-party `.dylib` files; macOS restricts without this |
| 3 | **Silent codesign fallback** (`|| true`) | Failed entitlements signing silently fell back to no entitlements |
| 4 | **Missing `NSAppTransportSecurity`** | macOS blocks cleartext HTTP to LAN even after Local Network granted |

## The Complete Fix (All 4 Required)

### 1. `packaging/macos/entitlements.plist`

```xml
<dict>
    <key>com.apple.security.app-sandbox</key>
    <false/>
    <key>com.apple.security.network.client</key>
    <true/>
    <key>com.apple.security.cs.disable-library-validation</key>
    <true/>
</dict>
```

- `app-sandbox = false` — NOT sandboxed. Sandbox ON + no network entitlement = dead LAN
- `network.client = true` — **THE** key that enables LAN access
- `disable-library-validation = true` — Required for PyInstaller (SCCAnalyzer has this too)

### 2. `build.sh` — PyInstaller invocation

```bash
--osx-entitlements-file "$ENTITLEMENTS"
```

Passes entitlements **into PyInstaller's own signing step**. Without this, PyInstaller
signs without entitlements and post-build re-sign may not take effect.

### 3. `build.sh` — Post-build signing (NO fallback)

```bash
# WRONG (silent failure):
codesign --force --deep --sign - --entitlements "$ENTITLEMENTS" "$APP_PATH" 2>/dev/null || true

# RIGHT (hard fail):
codesign --force --deep --sign - --entitlements "$ENTITLEMENTS" "$APP_PATH"
```

### 4. `build.sh` — Info.plist via plistlib (not PlistBuddy)

```python
info["NSLocalNetworkUsageDescription"] = "Pentool scans hosts on your local network..."
info["NSAppTransportSecurity"] = {
    "NSAllowsLocalNetworking": True,
    "NSAllowsArbitraryLoads": True,
}
```

**Why plistlib over PlistBuddy:** Chained `PlistBuddy -c "Add ..."` for nested dicts
silently fails if the parent dict doesn't exist. `plistlib` is atomic and reliable.

### 5. `build.sh` — Post-build verification

```bash
codesign --verify --deep --strict "$APP_PATH"
codesign -d --entitlements - "$APP_PATH" | grep "network.client"
codesign -d --entitlements - "$APP_PATH" | grep "disable-library-validation"
```

If either is missing → **build fails**. No silent success for a broken app.

### 6. `build.sh` — Clear quarantine

```bash
xattr -cr "$APP_PATH" 2>/dev/null || true
```

## What Does NOT Work (Tried and Failed)

| Approach | Why it failed |
|----------|--------------|
| `NSLocalNetworkUsageDescription` alone | No prompt without entitlements; ATS still blocks cleartext |
| `codesign ... \|\| true` fallback | Silently produces app with no entitlements |
| PlistBuddy chained Adds for nested dicts | Silently fails if parent dict doesn't exist |
| `--hidden-import httpx` | Doesn't bundle submodules — use `--collect-all httpx` |
| Adding entitlements only in post-build step | PyInstaller's own signing overwrites them |

## httpx vs urllib (`.app` packaging only)

Switched Ollama API calls from `urllib` to `httpx`. For the **`.app`**, use
`--collect-all httpx` (not `--hidden-import httpx`) so submodules are bundled.

For **raw Python**, bundling does nothing — the launch interpreter must have
`httpx` installed. See [[2026-09-25-pentool-raw-python-ai-chat-httpx]].

## TCC Identity Stability

macOS Local Network permission is tied to: **CFBundleIdentifier + code signature + path**

- **Always use a stable path**: `cp -R dist/Pentool.app /Applications/`
- **Don't run from `dist/`** after rebuilding — signature changes, TCC treats as new app
- **Lost the grant?**: System Settings → Privacy & Security → Local Network → toggle OFF then ON
- **Bundle ID must be stable**: `com.tsunami216.pentool` (don't change it)

## Verification Checklist (Run After Every Build)

```bash
find dist/Pentool.app -path "*/httpx/__init__.py" | head -1
codesign -d --entitlements - dist/Pentool.app 2>&1 | grep -A2 "network\|library-validation"
plutil -p dist/Pentool.app/Contents/Info.plist | grep -A3 "NSAppTransport"
codesign --verify --deep --strict dist/Pentool.app && echo "OK"
```

## Key Takeaway

> macOS Local Network access for PyInstaller .app bundles requires **ALL FOUR**:
> 1. `--osx-entitlements-file` in PyInstaller (signs WITH entitlements during build)
> 2. `network.client` + `disable-library-validation` in entitlements.plist
> 3. `NSLocalNetworkUsageDescription` + `NSAppTransportSecurity` in Info.plist
> 4. No silent fallback on codesign — build must **fail** if entitlements missing
>
> Missing any one = silent network failure. No error. No prompt. Just dead.

## Related

- **Raw Python AI Chat / missing httpx (different bug):** [[2026-09-25-pentool-raw-python-ai-chat-httpx]]
- Project: [[../../1-Projects/Pentool/_project|Pentool]]
- Pattern source: [[../../1-Projects/OllamaConfigurator/_project|Ollama Configurator]] (works because it has all 4)
- Pattern source: [[../../1-Projects/SCCAnalyzer/_project|SCCAnalyzer]] (works, has `disable-library-validation`)
- Repo: `/Users/philipkim/Documents/pentool/build.sh`
- Entitlements: `/Users/philipkim/Documents/pentool/packaging/macos/entitlements.plist`
