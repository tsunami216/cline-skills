---
type: resource
created: 2026-09-20
updated: 2026-09-20
tags: [skills, cursor, cline]
---

# Personal Cline / Cursor skills (snapshot)

Copied from `~/Documents/cline-skills` plus live `~/.cursor/skills` you actually use.
**Canonical live hub remains:** https://github.com/tsunami216/cline-skills (`~/Documents/cline-skills`).

This folder is a **Second Brain snapshot** so other programs/machines can read the skill text even if Cursor skill paths differ.

## Native Cursor skills (`cursor/*/SKILL.md`)

| Skill | Use |
|-------|-----|
| `memory-bank` | Six-file project memory (`memory-bank/` in a repo) |
| `validate-changes` | After code changes: tests/smoke + Proven/Untested/Blocked |
| `execution-review` | Review a plan against the repo before/during implementation |
| `second-brain` | Capture/search this vault (`~/Documents/SecondBrain`) |

## Flat Cline copies (`skills/`, `rules/`)

- `validate-changes.md`, `memory-bank.md`
- `android-app-signing.md` — SCCAnalyzer/CursorChat release APK path
- `ollama-image-generator.md`, `cursor-workspace-images.md`, `delete-agent.md`
- Rules: `api-verification.md`, `execution-review.md`
- `scripts/install-local.sh` — install hub → `~/.cursor/skills` + Cline Rules

## On another machine

```bash
git clone https://github.com/tsunami216/cline-skills.git ~/Documents/cline-skills
bash ~/Documents/cline-skills/scripts/install-local.sh
# Plus copy second-brain skill from this vault:
#   ~/.cursor/skills/second-brain/SKILL.md
```

Do **not** treat marketplace symlinks under `~/.cursor/skills` (AWS, SAP, etc.) as “your” skills — those were omitted.
