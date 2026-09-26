---
type: project
created: 2026-09-20
updated: 2026-09-24
tags: [cursor-chat, android, compose, cloud-agents]
project: CursorChat
---

# Cursor Chat — current status

**Repo:** `/Users/philipkim/Documents/cursor_chat`  
**GitHub:** https://github.com/tsunami216/cursor-chat  
**Branch:** `main` (tip around `f60558e` as of 2026-09-18)

## Versions

| Component | Version |
|-----------|---------|
| App | **1.0.17** / versionCode **18** (signed install over 1.0.16 on Fold `SM_F956U`) |
| Package | `com.cursorchat.app` |
| API | Cursor Cloud Agents `api.cursor.com` (no-repo mode) |

## What it is

Native **Jetpack Compose** chat client for Cursor Cloud Agents. User pastes a Cursor API key; first message creates a **no-repo** cloud agent; follow-ups use runs + SSE. Local history in Room; key in EncryptedSharedPreferences.

## Shipped (as of 2026-09-20)

- Streaming chat, photos, restore of marked cloud sessions
- Context meter (honest footprint: input + output tokens, **not** `cacheReadTokens`)
- Fast Compact / Clear context (new agent, cancel bootstrap, delete old agent)
- Link sanitization + Android 11+ `<queries>` for http(s)
- Background send/stream: `AgentRunCoordinator` + `AgentRunService` (dataSync FGS)
- Network drop recovery (Wi‑Fi ↔ cellular / AP roam) + Retry UI

## Open / next

1. PDF + Google Drive analysis plan (execution-reviewed, **not implemented**): `/Users/philipkim/.cursor/plans/pdf_drive_analysis_3e33715d.plan.md`
2. Drive needs in-app Google Sign-In + `drive.readonly`; Agents API still cannot take raw PDFs
3. Optional: split god files `ChatScreen.kt` / `ChatRepository.kt`

## Do not

- Commit API keys, `key.properties`, or `.jks`
- Count `cacheReadTokens` as conversation fill
- Cancel cloud runs in `ViewModel.onCleared()` (backgrounding used to drop replies)
- Treat Credential Manager ID-token sign-in as Drive access
- Wipe cloud memory in-place on the same `agentId` (must create a new agent)

## Related Second Brain notes

- [[architecture]] → `architecture.md` (this folder)
- Lessons under `../../3-Resources/Lessons/` (Cloud Agents + Android)
- Repo memory: `.memory-bank/` (lessons + status) **and** Cline-style `memory-bank/` (six-file snapshot). Git tip `f60558e` (background runs + network recover). `.memory-bank/status.md` still says 1.0.16 in places — treat **1.0.17 / 18** as shipped.
