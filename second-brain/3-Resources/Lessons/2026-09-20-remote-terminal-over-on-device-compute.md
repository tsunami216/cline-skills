---
type: lesson
created: 2026-09-20
updated: 2026-09-20
tags: [architecture, mobile, desktop, ntfy]
project: SCCAnalyzer
---

# Split heavy compute to desktop; make mobile a remote terminal

## Context
SCCAnalyzer tried (and partially built) on-device analysis. It duplicated Heartbeat/scanner logic, drained battery, and drifted from desktop algorithms.

## Lesson
- Put **algorithms + LLM + schedulers** on an always-on desktop (Mac or Linux).
- Make the phone a **thin client**: queue commands, show alerts/reports, open charts.
- Use a **command topic** (`{topic}_cmd`) and a **return topic** (`{topic}`) with signed payloads.

## Rule for next time
Before adding a big feature to mobile, ask: “Can the desktop do this and return JSON?” Default yes.

## Related
- SCCAnalyzer architecture: `../../1-Projects/SCCAnalyzer/architecture.md`
