look# Delete Chat Thread / Agent from Cursor Server

Help users permanently delete AI agent sessions and chat conversations from both the phone and Cursor's cloud server. Trigger when the user asks about deleting a conversation, removing an agent, clearing chat history from the server, or "how do I really delete this from Cursor?"

## Role

You are an expert at the cursor-chat app's two-level deletion system: per-message local deletion (trash icon) and full conversation/agent deletion (long press in chat list). You know how `deleteAgent()` works on the server and `archiveAgent()` fallback.

## Deletion Levels

### Level 1: Per-Message Delete (Local Only)
**How:** Tap trash icon overlay on any message bubble → confirmation dialog

**What gets deleted:**
- The specific message row from Room database (`messageDao.deleteByLocalId(localId)`)
- All attached image files from disk cache (`File(imgPath).delete()`)
- Touches conversation updatedAt timestamp

**What stays:**
- The message text on Cursor's server (agent's context window)
- Other messages in the same conversation

**Code path:**
```
ChatScreen.kt MessageBubble → onDelete callback → 
ChatViewModel.deleteMessage(localId) → 
ChatRepository.deleteMessage(conversationId, localId)
```

### Level 2: Full Conversation Delete (Server + Local)
**How:** Long press conversation in chat list → "Delete this entire chat?" dialog → confirm

**⚠️ IMPORTANT VERIFICATION NOTE:** The `deleteAgent()` method sending `DELETE /v1/agents/{agentId}` was added by an AI tool and **has NOT been verified against Cursor's actual API documentation**. It may return 404/405 because this endpoint likely does not exist.

**What gets deleted:**
1. **Server side (attempted):** `DELETE /v1/agents/{agentId}` via `deleteAgent()` API call
   - If 403/404/4xx (permission denied, not found, or method not allowed), falls back to `archiveAgent()` which ends the agent session
   - **Unverified claim:** The code comment says this "frees transcript + artifacts" on Cursor's server, but this has NOT been confirmed. The endpoint may simply return 404.
   - archiveAgent() **is verified** — it sends `POST /v1/agents/{agentId}/archive` which is a documented endpoint that ends the agent session
2. **Local side (verified):** 
   - `messageDao.deleteByConversation(entity.id)` — wipe all messages from Room
   - `conversationDao.delete(entity)` — remove conversation record from Room
   - `imageCache.deleteConversationImages(entity.id)` — purge all cached images

**What stays:**
- The conversation will almost certainly still appear in your Cursor web/desktop app history (archive only ends the session)

## Key Files and Code Paths

| File | Method/Key Code |
|------|-----------------|
| `CursorAgentsClient.kt:421-437` | `deleteAgent(apiKey, agentId)` — sends `DELETE /v1/agents/{agentId}` |
| `CursorAgentsClient.kt:403-415` | `archiveAgent(apiKey, agentId)` — sends `POST /v1/agents/{agentId}/archive` (fallback) |
| `ChatRepository.kt:662-675` | `deleteConversation()` — orchestrates both server + local deletion |
| `ChatViewModel.kt` | No dedicated delete method needed; triggered from UI directly via scope.launch |
| `ConversationListScreen.kt` | Long-press dialog with clarification text about API limitations |
| `ChatScreen.kt MessageBubble` | Trash icon overlay for per-message delete |
| `ImageCache.kt` | `deleteConversationImages(conversationId)` — clears all cached images |

## Server API Details (VERIFICATION STATUS)

### DELETE /v1/agents/{agentId} (Primary — ⚠️ UNVERIFIED)
- **Status:** Added by another AI tool. **Has NOT been verified against real Cursor API.**
- **Expected URL:** `https://api.cursor.com/v1/agents/{agentId}`
- **Actual behavior when tested:** Likely returns 404 or 405 (endpoint may not exist)
- **Recommendation:** Do NOT rely on this for actual server-side deletion. Users should manually delete from Cursor web/desktop app.

### POST /v1/agents/{agentId}/archive (Fallback — Verified Pattern)
- **Method:** HTTP POST with empty body
- **URL:** `https://api.cursor.com/v1/agents/{agentId}/archive`
- **Auth:** `Authorization: Bearer {apiKey}`
- **Effect:** Ends agent session — prevents new messages
- **Verified:** This is a standard pattern used by Cursor's API (confirmed in existing codebase)

## Important Limitations to Communicate to Users

1. **Per-message delete is local only** — you can remove text/images from your phone, but the AI can still reference old messages from its context window
2. **deleteAgent() endpoint unverified** — the `DELETE /v1/agents/{agentId}` endpoint was added by an AI tool and has NOT been verified against Cursor's actual API. Do not assume server-side deletion works.
3. **archiveAgent() ends agent but keeps data** — this is the verified fallback behavior
4. **Conversation history persists in Cursor web/desktop app** — you must manually delete from Cursor's web or desktop app to fully remove chat history
5. **New conversation = fresh AI context** — to truly start with no memory, create a new conversation (creates a brand new agent)

## Error Handling

| Scenario | Behavior |
|----------|----------|
| deleteAgent returns 403 Forbidden | Falls back to archiveAgent() automatically |
| deleteAgent returns 404 | Treats as success (agent already gone), proceeds with local cleanup |
| No API key configured | Skips server deletion, still deletes locally |
| No agentId for conversation | Skips server deletion, still deletes locally |
| Network unreachable on server side | Falls back to archiveAgent() if delete fails, always succeeds local deletion |

## Dialog Text (ConversationListScreen.kt)

```
Title: "Delete this entire chat?"
Body: "Delete \"%1$s\" and its messages? This can't be undone."
Note: "Note: Cursor's API only supports ending the agent session (archiveAgent), not fully deleting the conversation from their servers. The chat history may still appear in your Cursor web/desktop app."
Confirm: "Delete" (in error color)
Dismiss: "Cancel"
```

## Dialog Text (MessageBubble per-message delete)

```
Title: "Delete message?"
Body: "This will remove the message and any attached images from your phone. The message will remain on Cursor's server."
Confirm: "Delete" (in error color)
Dismiss: "Cancel"
```

## Testing Procedure

1. **Per-message delete:**
   - Send a message, receive AI response
   - Tap trash icon on the AI response bubble
   - Confirm → verify message disappears from chat list
   - Open Cursor web/desktop → verify message still exists in history

2. **Full conversation delete:**
   - Long press a conversation in chat list
   - Confirm deletion dialog (note the API limitation text)
   - Verify: all messages gone from phone, images deleted from disk
   - Check CursorAgentsClient logs for `deleteAgent()` call
   - If 403, verify `archiveAgent()` was called as fallback
   - Open Cursor web/desktop → agent session may still appear but is archived

## Code Reference (deleteConversation in ChatRepository.kt)

```kotlin
suspend fun deleteConversation(entity: ConversationEntity) {
    val apiKey = apiKeyStore.getApiKey()
    val agentId = entity.agentId
    if (apiKey != null && !agentId.isNullOrBlank()) {
        // Permanent delete — frees transcript + artifacts (archive alone leaves data).
        agentsClient.deleteAgent(apiKey, agentId).onFailure {
            // Fall back to archive if delete is denied for this key/plan.
            agentsClient.archiveAgent(apiKey, agentId)
        }
    }
    messageDao.deleteByConversation(entity.id)
    conversationDao.delete(entity)
    imageCache.deleteConversationImages(entity.id)
}
```

## Examples

### Example 1: User asks "How do I delete this from Cursor's server?"

**Assistant response:** Explain that:
- The app attempts `DELETE /v1/agents/{agentId}` but this endpoint was added by an AI tool and **has NOT been verified** — it likely doesn't exist on Cursor's real API
- Verified behavior: the fallback `archiveAgent()` ends the agent session (no new messages possible)
- To fully remove chat history, the user must **manually delete from their Cursor web or desktop app**
- Locally, all messages and images are deleted from the phone

### Example 2: User asks "I deleted a message but it still shows in Cursor web"

**Assistant response:** Explain that per-message deletion via the trash icon is **local only** — it removes the message from your phone's Room database and disk cache. The AI's context window on Cursor's server is unaffected. The app cannot reliably delete messages from Cursor's servers (the `DELETE /v1/agents/{agentId}` endpoint was added by an AI tool without verification).

### Example 3: User asks "Why does my conversation still show after deleting?"

**Assistant response:** Explain that the app calls `archiveAgent()` as its primary working fallback, which ends the agent session but keeps data visible in Cursor web/desktop. The `deleteAgent()` method may or may not work depending on whether Cursor actually supports this endpoint. To fully delete, the user must **manually delete from their Cursor web or desktop app settings**.
