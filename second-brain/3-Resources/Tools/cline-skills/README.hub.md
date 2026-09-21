# Cline Skills

Portable skill files for **Cline** and **Cursor** that work across all projects and machines.

Repository: https://github.com/tsunami216/cline-skills

## Quick install (new machine)

```bash
# 1) Clone (or pull) the hub
mkdir -p ~/Documents
git clone https://github.com/tsunami216/cline-skills.git ~/Documents/cline-skills
# or: cd ~/Documents/cline-skills && git pull

# 2) Install into Cursor global skills + rules
bash ~/Documents/cline-skills/scripts/install-local.sh
```

`install-local.sh` links/copies:

| Source in this repo | Local destination |
|---------------------|-------------------|
| `cursor/*/SKILL.md` | `~/.cursor/skills/<name>/SKILL.md` |
| `skills/*.md` | available under `~/.cursor/skills/cline-skills/skills/` |
| `rules/*.md` | `~/.cursor/rules/` and (optional) `~/Documents/Cline/Rules/` |

## Structure

```
skills/     Flat Cline-compatible skill markdown
rules/      Universal behavioral rules
cursor/     Native Cursor Agent skills (SKILL.md folders)
scripts/    install-local.sh — sync this repo → this machine
```

## Skills

| File | Description |
|------|-------------|
| [validate-changes.md](skills/validate-changes.md) | After code updates: acceptance criteria → targeted tests/smoke → Proven/Untested/Blocked report |
| [cursor-workspace-images.md](skills/cursor-workspace-images.md) | Download/display Cursor workspace generated images |
| [delete-agent.md](skills/delete-agent.md) | Delete Cursor chat threads/agents (with API verification warnings) |
| [android-app-signing.md](skills/android-app-signing.md) | Android release signing workflow |
| [ollama-image-generator.md](skills/ollama-image-generator.md) | Ollama image generation helpers |
| [memory-bank.md](skills/memory-bank.md) | Update/follow Memory Bank: scan all six core files every time |

## Cursor-native skills

| Folder | Description |
|--------|-------------|
| [cursor/validate-changes](cursor/validate-changes/SKILL.md) | Same as validate-changes, Cursor Agent format |
| [cursor/execution-review](cursor/execution-review/SKILL.md) | Plan gap/risk review; patch same plan file in place |
| [cursor/memory-bank](cursor/memory-bank/SKILL.md) | Memory Bank: read/update all six files on initialize/update/follow |

## Rules

| File | Description |
|------|-------------|
| [api-verification.md](rules/api-verification.md) | Check official docs before claiming third-party API behavior |
| [execution-review.md](rules/execution-review.md) | Execution-review rule (Cline flat form) |

## Updating from a machine that edited local skills

1. Edit `~/.cursor/skills/<name>/SKILL.md` (or Cline Rules)
2. Copy back into this repo (`cursor/` and/or `skills/` / `rules/`)
3. Update this README table if you added a skill
4. `git commit && git push`
5. On other machines: `git pull && bash scripts/install-local.sh`

## License

MIT
