# Cline Skills

Portable skill files for Cline/Copilot that work **across all projects**, not tied to any single codebase.

## Quick Install (works in ALL Cline projects)

```bash
# Clone the skills repository into Cline's global skills directory
mkdir -p ~/.cursor/skills
git clone https://github.com/tsunami216/cline-skills.git ~/.cursor/skills/cline-skills

# Copy rules to Cline's global rules directory
mkdir -p ~/.cursor/rules
cp ~/.cursor/skills/cline-skills/rules/*.md ~/.cursor/rules/
```

After installation, skills and rules are **automatically available in every project** you open in Cline/Cursor.

## Structure

- `skills/` — individual skill definitions (domain-specific behaviors)
- `rules/` — behavioral rules that apply universally to all AI instances

## Skills

| File | Description |
|------|-------------|
| [cursor-workspace-images.md](skills/cursor-workspace-images.md) | Download and display AI-generated images from Cursor workspace into the Android app. Trigger: image generation, "Generated again" text, workspace file mentions. |
| [delete-agent.md](skills/delete-agent.md) | Delete chat threads/agents from Cursor server with verification warnings for unverified endpoints. Trigger: "how do I delete this", "remove agent", "clear chat history". |

## Rules

| File | Description |
|------|-------------|
| [api-verification.md](rules/api-verification.md) | **Mandatory protocol**: check official documentation before claiming third-party API behavior. Requires `[UNVERIFIED]` prefix on unverified claims, `⚠️ UNVERIFIED` markers in code, and recommends manual verification. |

## How Skills Work

Skills are loaded by Cline/Cursor Copilot when relevant prompts are detected. Each `.md` file defines:

1. **Trigger conditions** — what user messages or code patterns activate this skill
2. **Role definition** — what knowledge/context the AI should have when active
3. **Instructions** — step-by-step guidance for responding to the user
4. **Examples** — Q&A pairs showing correct behavior

## Cross-Project Compatibility

These skills are **not specific to any single project**. They work in any project because:

- Skills live in `~/.cursor/skills/` (global), not inside any project folder
- The `api-verification.md` rule loads universally across all Cline/Cursor sessions
- Future projects auto-inherit these skills when installed globally

## Adding New Skills

To contribute a new skill:

1. Create a `.md` file following the same structure as existing skills
2. Place it in the `skills/` directory
3. Update this README's table with a description
4. Commit and push to this repository

## Repository

https://github.com/tsunami216/cline-skills