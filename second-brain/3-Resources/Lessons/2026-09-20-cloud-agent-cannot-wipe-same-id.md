---
type: lesson
created: 2026-09-20
updated: 2026-09-20
tags: [cursor, cloud-agents, compact]
project: CursorChat
---

# Cloud agent memory cannot be cleared on the same agentId

## Context
Compact / Clear context in Cursor Chat needed a “fresh” model memory.

## What went wrong / what we learned
There is **no** in-place wipe of an existing Cloud Agent’s conversation. Same `agentId` keeps prior context.

Reset path: create a **new** agent with a short seed (or “Ready.”), rebind the local conversation row, **cancel the bootstrap run** immediately (don’t wait on a long first stream), delete/archive the old agent.

## Rule for next time
Product “clear context” = new agent + local wipe. Keep the same Room conversation id so the user doesn’t navigate away.

## Related
- Cursor Chat: `compactConversation` / `clearConversationContext` / `replaceAgentSession` (`39b8c16`)
