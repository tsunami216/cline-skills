---
type: lesson
created: 2026-09-23
updated: 2026-09-23
tags: [tkinter, event-driven, ollama, ui-pattern, connection-testing]
project: Pentool
---

# Event-Driven Connection Panel Pattern (Test → Apply → Refresh)

## Context

Building the AI Chat tab's Ollama connection panel. The user needs to:
1. Enter a server URL
2. Test if it's reachable (without committing)
3. Apply + refresh model list (commit the change)

## Pattern

```
┌─────────────────────────────────────────────────────────────────────┐
│ [URL entry field]  [Test]  [Apply & Refresh]                        │
│ [Model dropdown]   [Tab context]                    [Clear]         │
├─────────────────────────────────────────────────────────────────────┤
│  (main content area)                                               │
├─────────────────────────────────────────────────────────────────────┤
│  Status bar: ✓ Connected — Ollama 0.9.x   (green/red/grey)         │
└─────────────────────────────────────────────────────────────────────┘
```

## Controller side (emits events)

```python
def ollama_test_connection(self, url: str):
    """Non-blocking: runs in daemon thread, emits ai_conn_ok or ai_conn_error."""
    def _test():
        try:
            with urllib.request.urlopen(f"{url}/api/version", timeout=5) as r:
                version = json.loads(r.read())["version"]
            self._emit("ai_conn_ok", version)
        except Exception as e:
            self._emit("ai_conn_error", str(e))
    threading.Thread(target=_test, daemon=True).start()

def ollama_set_url(self, url: str):
    """Persist URL + trigger model refresh."""
    self.ollama_config.base_url = url
    self.ollama_config.save()
    self.ai_load_models()

def ai_load_models(self):
    """Background thread fetches /api/tags, emits ai_models or ai_error."""
    def _load():
        try:
            with urllib.request.urlopen(f"{self.ollama_config.base_url}/api/tags") as r:
                models = [m["name"] for m in json.loads(r.read())["models"]]
            self._emit("ai_models", models)
        except Exception as e:
            self._emit("ai_error", str(e))
    threading.Thread(target=_load, daemon=True).start()
```

## UI side (handles events)

```python
def handle(self, kind, payload):
    if kind == "ai_conn_ok":
        self._set_status(f"✓ Connected — Ollama {payload}", color="#4ecdc4")
    elif kind == "ai_conn_error":
        self._set_status(f"✗ {payload}", color="#e74c3c")
    elif kind == "ai_models":
        self._populate_models(payload)
        self._set_status(f"✓ {len(payload)} models loaded", color="#4ecdc4")
    elif kind == "ai_error":
        self._set_status(f"✗ {payload}", color="#e74c3c")
```

## Key design decisions

| Decision | Why |
|----------|-----|
| Test ≠ Apply | User can test multiple URLs before committing one |
| Status bar with colors | Immediate visual feedback (green=ok, red=error, grey=neutral) |
| Daemon threads | UI never blocks; app can be closed mid-test |
| Config persistence on Apply | URL only saved when user confirms (not on Test) |
| Event queue | Thread-safe communication (same pattern as all other tabs) |
| `urllib` not `requests` | Zero extra deps; streams line-by-line for chat |

## Reusable for

- Any "server URL + test + apply" panel (API keys, webhook URLs, etc.)
- Database connection panels
- MQTT broker configuration
- Any external service that needs connectivity verification

## Key takeaway

> Separate **test** (read-only, non-persisting) from **apply** (committing + side effects).
> Use daemon threads for all network I/O. Emit events, don't callback directly.
> Color-code the status bar: green = success, red = error, grey = neutral.

## Related

- Project: [[../../1-Projects/Pentool/_project|Pentool]]
- Source: `pentool/controller.py` (ollama_test_connection, ollama_set_url, ai_load_models)
- Source: `pentool/ui/ai_chat_tab.py` (handle, _set_status, _on_test, _on_apply_url)
