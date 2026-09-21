# Second Brain — agent operating contract

Vault root: `~/Documents/SecondBrain` (`$HOME/Documents/SecondBrain`)

## When to use this vault

- User asks to capture, remember, log a lesson, or search past decisions
- A durable lesson emerges that should survive beyond the current chat/repo
- User says “second brain”, “inbox”, “lesson learned”, “remember this”

## Do not

- Store secrets, API keys, keystore passwords, or `.db` files here
- Dump entire chat transcripts without distilling
- Overwrite existing notes without asking when content would be lost
- Replace SCCAnalyzer `memory-bank/` — that stays the project source of truth

## Routing rules

| Content | Destination |
|---------|-------------|
| Fleeting thought / link / paste | `0-Inbox/YYYY-MM-DD-slug.md` |
| Active project work | `1-Projects/<Project>/` |
| Ongoing life/work area | `2-Areas/<Area>/` |
| Reusable lesson / postmortem | `3-Resources/Lessons/YYYY-MM-DD-slug.md` |
| Tool how-to / cheatsheet | `3-Resources/Tools/` |
| Articles / courses | `3-Resources/Learning/` |
| Finished / inactive | `4-Archive/` |

## Note contract

Every new note should have YAML frontmatter:

```yaml
---
type: lesson|inbox|project|area|decision|meeting|daily
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: [example]
project: SCCAnalyzer   # optional
---
```

Prefer short, factual bullets. Link related notes with relative paths or `[[wikilinks]]`.

## Session habits

1. Prefer **search** (`Grep` / read) before creating a duplicate lesson.
2. On capture: write the note, confirm path, leave Inbox items in Inbox unless user asks to triage.
3. On “update memory bank” for a **repo**: still use that repo’s `memory-bank/`; optionally add a distilled lesson here if it is cross-project.

## Templates

Use files under `templates/` when creating structured notes.
