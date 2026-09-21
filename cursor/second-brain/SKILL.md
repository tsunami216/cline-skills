---
name: second-brain
description: >-
  Capture, search, triage, and log lessons in the local Second Brain vault at
  ~/Documents/SecondBrain (PARA). Use when the user says second brain, capture,
  inbox, lesson learned, remember this, triage notes, or asks for past decisions
  / historical lessons outside a single repo memory-bank.
---

# Second Brain

Vault: `~/Documents/SecondBrain` (expand `$HOME`; created by `scripts/install-local.sh`)  
Operating contract: read `AGENTS.md` in that vault first.

## Commands (natural language)

| User intent | Action |
|-------------|--------|
| Capture / remember | Write `0-Inbox/YYYY-MM-DD-slug.md` from `templates/inbox.md` |
| Lesson learned | Write `3-Resources/Lessons/YYYY-MM-DD-slug.md` from `templates/lesson.md` |
| Decision | Write under project or `3-Resources/` using `templates/decision.md` |
| Search / recall | `Grep` / `Glob` under the vault; quote paths in the answer |
| Triage inbox | Propose moves Inbox → Projects/Areas/Resources/Archive; ask before bulk moves |
| Project note | Update `1-Projects/<Name>/` |

## Rules

1. Search before creating duplicates.
2. No secrets in the vault.
3. Do not replace a git repo’s `memory-bank/` — distill cross-cutting lessons here instead.
4. Confirm the file path after writing.

## Quick paths

```
~/Documents/SecondBrain/0-Inbox/
~/Documents/SecondBrain/1-Projects/SCCAnalyzer/
~/Documents/SecondBrain/3-Resources/Lessons/
~/Documents/SecondBrain/AGENTS.md
```
