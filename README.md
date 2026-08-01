# Cursor Chat Skills

Portable skill files for Cursor Copilot. Each `.md` file defines a skill that enhances AI assistant behavior in Cursor.

## Structure

- `skills/` — individual skill definitions
- `rules/` — behavioral rules for AI instances

## Skills

| File | Description |
|------|-------------|
| [cursor-workspace-images.md](skills/cursor-workspace-images.md) | Download and display AI-generated images from Cursor workspace into the Android app |
| [delete-agent.md](skills/delete-agent.md) | Delete chat threads/agents from Cursor server (with verification warnings for unverified endpoints) |

## Rules

| File | Description |
|------|-------------|
| [api-verification.md](rules/api-verification.md) | Mandatory protocol: check official documentation before claiming third-party API behavior |

## Installation

1. Clone this repository into Cursor's global `.cursor/skills/` directory:
   ```bash
   mkdir -p ~/.cursor/skills
   git clone https://github.com/tsunami216/cursor-chat-skills.git ~/.cursor/skills/cursor-chat-skills
   ```
2. Open Cursor — skills are automatically loaded on relevant prompts.

## License

MIT