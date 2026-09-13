#!/usr/bin/env bash
# Install/sync cline-skills onto this machine for Cursor + Cline.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CURSOR_SKILLS="${HOME}/.cursor/skills"
CURSOR_RULES="${HOME}/.cursor/rules"
CLINE_RULES="${HOME}/Documents/Cline/Rules"

mkdir -p "$CURSOR_SKILLS" "$CURSOR_RULES"

echo "Installing Cursor-native skills from $ROOT/cursor ..."
if [[ -d "$ROOT/cursor" ]]; then
  for skill_dir in "$ROOT/cursor"/*; do
    [[ -d "$skill_dir" && -f "$skill_dir/SKILL.md" ]] || continue
    name="$(basename "$skill_dir")"
    dest="$CURSOR_SKILLS/$name"
    mkdir -p "$dest"
    cp "$skill_dir/SKILL.md" "$dest/SKILL.md"
    echo "  ✓ ~/.cursor/skills/$name/SKILL.md"
  done
fi

# Keep a clone/checkout pointer for flat skills under ~/.cursor/skills/cline-skills
LINK="$CURSOR_SKILLS/cline-skills"
if [[ -L "$LINK" || -d "$LINK" ]]; then
  if [[ "$(cd "$LINK" 2>/dev/null && pwd -P)" != "$(pwd -P "$ROOT")" ]]; then
    echo "Note: $LINK already exists; leaving it in place."
  fi
else
  ln -s "$ROOT" "$LINK"
  echo "  ✓ linked ~/.cursor/skills/cline-skills → $ROOT"
fi

echo "Installing rules into ~/.cursor/rules ..."
if [[ -d "$ROOT/rules" ]]; then
  cp "$ROOT/rules/"*.md "$CURSOR_RULES/" 2>/dev/null || true
  echo "  ✓ copied rules → ~/.cursor/rules/"
fi

if [[ -d "$CLINE_RULES" || -d "$(dirname "$CLINE_RULES")" ]]; then
  mkdir -p "$CLINE_RULES"
  # Flat skills + rules for Cline Rules folder
  if [[ -d "$ROOT/skills" ]]; then
    cp "$ROOT/skills/"*.md "$CLINE_RULES/" 2>/dev/null || true
  fi
  if [[ -d "$ROOT/rules" ]]; then
    cp "$ROOT/rules/"*.md "$CLINE_RULES/" 2>/dev/null || true
  fi
  echo "  ✓ synced → ~/Documents/Cline/Rules/"
fi

echo "Done. Restart Cursor/Cline or start a new agent chat to pick up skills."
