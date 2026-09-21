---
type: project
created: 2026-09-20
updated: 2026-09-20
tags: [cursor-chat, architecture]
project: CursorChat
---

# Cursor Chat — product architecture

## High-level shape

```
Compose UI  →  ChatViewModel  →  AgentRunCoordinator (app scope + FGS)
                      ↓                    ↓
                 Room / prefs        ChatRepository → CursorAgentsClient (OkHttp SSE)
                                           ↓
                                    api.cursor.com  (no-repo agents)
```

**Principle:** Persist locally first; cloud agent is a **durable remote session**. UI ViewModels must **not** own in-flight runs.

## Layers

| Layer | Role | Key files |
|-------|------|-----------|
| UI | Compose screens | `ui/chat`, `ui/list`, `ui/settings`, `ui/restore` |
| Run ownership | Survives Activity stop | `data/AgentRunCoordinator.kt`, `service/AgentRunService.kt` |
| Application | Orchestration | `data/ChatRepository.kt` |
| API | OkHttp, no Retrofit | `data/api/CursorAgentsClient.kt`, `Dtos.kt` |
| Local | History + cache | Room `ChatDatabase`, `ImageCache` |
| Secrets | API key | `ApiKeyStore` (EncryptedSharedPreferences) |

Manual DI in `CursorChatApp` (no Hilt).

## Cloud Agents constraints

- Prompt = **text + ≤5 images** (PNG/JPEG/GIF/WebP). **No PDF upload.**
- No-repo mode: omit `repos` / `env`; some models (Opus, Codex, o3) filtered out
- Compact/Clear: **new** `POST /v1/agents`, rebind Room row, cancel bootstrap, delete old agent
- Usage API has **no** real context-window field; UI assumes 200k; meter uses `inputTokens + outputTokens`

## Background / network (1.0.17)

- `viewModelScope` jobs die when the chat screen is destroyed → replies were lost in background
- Fix: app-scoped coordinator + `foregroundServiceType=dataSync`
- Transient IO (Wi‑Fi/cellular) → wait for network, re-open SSE / poll `GET /runs/{id}`; else Error + **Retry**

## Data / security

- Room `chat_database`; `fallbackToDestructiveMigration()` is a wipe risk — prefer explicit migrations
- API key never logged (OkHttp redacts Authorization)
- Release signing: gitignored `key.properties` + same keystore for updates (`adb install -r`)

## Reusable patterns

See `../../3-Resources/Lessons/` (context meter, FGS runs, Drive/PDF, agent wipe, Android 11 queries).
