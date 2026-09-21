---
type: lesson
created: 2026-09-20
updated: 2026-09-20
tags: [android, intents, package-visibility]
project: CursorChat
---

# Android 11+: declare VIEW queries or browsers look missing

## Context
http(s) links in Cursor Chat failed to open on Android 11+.

## What went wrong / what we learned
`resolveActivity` returns null for browsers unless the app declares `<queries>` for `VIEW` + `http`/`https` (and other schemes like `geo`). Then `startActivity` in `runCatching`.

Also strip trailing markdown (`)**`, `*`, `_`) from detected URLs.

## Rule for next time
Any app that opens web/map links: add `<queries>` intents; don’t trust `resolveActivity` alone.

## Related
- Cursor Chat: `AndroidManifest.xml`, `sanitizeDetectedUrl` (`3ac7210`, `8c8288c`)
