# Second Brain — agent operating contract

Vault root: `~/Documents/SecondBrain` (`$HOME/Documents/SecondBrain`)

## When to use this vault

- User asks to capture, remember, log a lesson, or search past decisions
- A durable lesson emerges that should survive beyond the current chat/repo
- User says “second brain”, “inbox”, “lesson learned”, “remember this”

## CRITICAL — example projects are READ-ONLY unless the user is in that repo

Notes under `1-Projects/SCCAnalyzer/`, `1-Projects/CursorChat/`, and other `1-Projects/*`
folders, plus lessons that mention those apps, are **worked examples / case studies**.

**When the user’s open workspace / active task is a different application:**

1. **Read** Second Brain lessons for patterns.
2. **Apply** those patterns only to the **current** project’s files.
3. **Do NOT** edit, commit, push, rebuild, or “fix” SCCAnalyzer, CursorChat, or any
   other example project listed in this vault.
4. **Do NOT** open or change paths under `/Users/philipkim/Documents/SCCAnalyzer`
   (or other example repos) just because a lesson cites them.
5. Paths like `agents/remote_queue.py` or `indicators/heartbeat.py` in a lesson are
   **illustrations** from the example app — map the idea to the equivalent files in
   the **current** codebase instead.

**Only** modify an example project (e.g. SCCAnalyzer) when **all** of these are true:

- The user’s workspace root **is** that project, **or**
- The user **explicitly** asked to change that named project in this turn.

If unclear, ask: “Apply this lesson to the current app only, or also change SCCAnalyzer?”

## Do not

- Store secrets, API keys, keystore passwords, or `.db` files here
- Dump entire chat transcripts without distilling
- Overwrite existing notes without asking when content would be lost
- Replace a repo’s `memory-bank/` — that stays the project source of truth
- Treat “Related: SCCAnalyzer: …” footnotes as a task list to edit that repo

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
project: ExampleApp   # optional — source of the lesson, NOT a mandate to edit that app
---
```

Prefer short, factual bullets. Link related notes with relative paths or `[[wikilinks]]`.

When writing new lessons, phrase **Rule for next time** as general guidance for *any*
future app. Put example-app paths under **Related / Origin example** only.

## Session habits

1. Prefer **search** (`Grep` / read) before creating a duplicate lesson.
2. On capture: write the note, confirm path, leave Inbox items in Inbox unless user asks to triage.
3. On “update memory bank” for a **repo**: still use that repo’s `memory-bank/`; optionally add a distilled lesson here if it is cross-project.
4. When applying a lesson: state which **current-project** files you will change; never default to the example repo.

## Templates

Use files under `templates/` when creating structured notes.
