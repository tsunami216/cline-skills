# Second Brain

Local Markdown vault for cross-project history, lessons, and capture.
Agents (Cursor / Claude) should treat this folder as durable memory outside any single repo.

**Path:** `/Users/philipkim/Documents/SecondBrain`

## Structure (PARA)

| Folder | Purpose |
|--------|---------|
| `0-Inbox/` | Quick capture — unsorted thoughts, links, dumps |
| `1-Projects/` | Active work with an end state (e.g. SCCAnalyzer) |
| `2-Areas/` | Ongoing responsibilities (health, finance, career) |
| `3-Resources/` | Evergreen reference — `Lessons/`, `Tools/`, `Learning/` |
| `4-Archive/` | Completed / inactive |
| `templates/` | Note scaffolds |

## How to use (humans)

1. Dump raw thoughts into `0-Inbox/`.
2. Periodically triage Inbox → Projects / Areas / Resources / Archive.
3. Put durable “never forget this again” notes in `3-Resources/Lessons/`.
4. Keep project-specific living notes under `1-Projects/<Name>/`.

## How to use (agents)

See `AGENTS.md` (operating contract) and the Cursor skill `~/.cursor/skills/second-brain/SKILL.md`.

**Important:** Project folders and lessons that mention SCCAnalyzer / CursorChat / etc.
are **examples**. Agents must apply those lessons to the **current** app — not open
or edit the example repos — unless the user is working in that repo or asked by name.

## Relation to repo `memory-bank/`

- **Repo `memory-bank/` / `.memory-bank/`** = current project state for that codebase (git-tracked).
- **This Second Brain** = personal / cross-project memory (not tied to one git tip).

Do not duplicate entire memory-bank here; link or distill lessons instead.

## All programs (except Pentool)

Start here: `3-Resources/programs-index.md`

## SCCAnalyzer entry points (updated 2026-09-24)

- Status: `1-Projects/SCCAnalyzer/_project.md`
- Architecture: `1-Projects/SCCAnalyzer/architecture.md`
- Reusable lessons index: `3-Resources/SCCAnalyzer-patterns-index.md`

## Cursor Chat entry points (updated 2026-09-24)

- Status: `1-Projects/CursorChat/_project.md`
- Architecture: `1-Projects/CursorChat/architecture.md`
- Reusable lessons index: `3-Resources/CursorChat-patterns-index.md`

## Ollama Configurator (updated 2026-09-24)

- Status: `1-Projects/OllamaConfigurator/_project.md`
- Architecture: `1-Projects/OllamaConfigurator/architecture.md`

## AI Translator (added 2026-09-24)

- Status: `1-Projects/AI_Translator/_project.md`
- Architecture: `1-Projects/AI_Translator/architecture.md`
- Lessons index: `3-Resources/AI_Translator-patterns-index.md`

## Skill Builder (added 2026-09-24)

- Status: `1-Projects/SkillBuilder/_project.md`
- Architecture: `1-Projects/SkillBuilder/architecture.md`
- Lessons index: `3-Resources/SkillBuilder-patterns-index.md`

## Tools

- Personal skills snapshot: `3-Resources/Tools/cline-skills/`
