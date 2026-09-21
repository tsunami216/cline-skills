---
type: lesson
created: 2026-09-20
updated: 2026-09-20
tags: [git, branches, release]
project: SCCAnalyzer
---

# Keep platform branches tip-aligned; prune agent junk branches

## Context
Cursor auto-opened dozens of `cursor/missing-test-coverage-*` draft PRs. Platform work lived on `MacOS` / `Ubuntu` / `Android`.

## Lesson
- Treat **MacOS / Ubuntu / Android** (and `main` if needed) as the only long-lived product branches  
- After merging desktop algorithm work, **fast-forward** sibling branches the same day  
- Delete abandoned agent branches and close draft PRs — they are not product history  
- Source can be ahead of the **packaged** Mac `.app` / Play install until you rebuild/sign

## Rule for next time
After any cross-platform merge: `MacOS` → push → FF `Android`/`Ubuntu` (or reverse) before context-switching.

## Related
- SCCAnalyzer branch hygiene session 2026-09-19
