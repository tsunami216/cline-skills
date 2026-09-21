---
type: lesson
created: 2026-09-20
updated: 2026-09-20
tags: [cursor, cloud-agents, tokens, metering]
project: CursorChat
---

# Cloud Agents usage: do not use cacheReadTokens as context fill

## Context
Cursor Chat’s context meter used billing usage from `GET /v1/agents/{id}/usage`. After one tool-heavy turn the bar showed ~200k full.

## What went wrong / what we learned
`cacheReadTokens` **re-counts the same prompt** across each internal tool/reasoning step. A ~15k prompt with many steps can report ~180k+ cache reads. That is **billing/internal**, not conversation window fill.

Honest footprint: **`inputTokens + outputTokens`**. Assumed window 200k is a display guess — the API does not expose a real context limit.

## Rule for next time
Any Cloud Agents client meter: never add `cacheReadTokens` into % fill. Document the 200k assumption.

## Related
- Cursor Chat: `ChatRepository.contextTokensOf`, commit `4ba7d43`
- Project: `../../1-Projects/CursorChat/_project.md`
