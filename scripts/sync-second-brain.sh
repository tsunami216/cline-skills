#!/usr/bin/env bash
# Sync Second Brain vault between this machine and the cline-skills repo snapshot.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPO_VAULT="$ROOT/second-brain"
LOCAL_VAULT="${HOME}/Documents/SecondBrain"

usage() {
  echo "Usage: $0 export|import|status"
  echo "  export  ~/Documents/SecondBrain → repo second-brain/"
  echo "  import  repo second-brain/ → ~/Documents/SecondBrain (creates dest if missing;"
  echo "          existing dest: copies only missing files, no overwrite)"
  echo "  status  compare file lists"
}

export_vault() {
  if [[ ! -d "$LOCAL_VAULT" ]]; then
    echo "No local vault at $LOCAL_VAULT"
    exit 1
  fi
  mkdir -p "$REPO_VAULT"
  rsync -a --delete --exclude '.DS_Store' --exclude '.obsidian' --exclude '.git' \
    "$LOCAL_VAULT/" "$REPO_VAULT/"
  echo "Exported → $REPO_VAULT"
}

import_vault() {
  if [[ ! -d "$REPO_VAULT" ]]; then
    echo "No repo snapshot at $REPO_VAULT"
    exit 1
  fi
  mkdir -p "$LOCAL_VAULT"
  rsync -a --ignore-existing --exclude '.DS_Store' --exclude '.obsidian' \
    "$REPO_VAULT/" "$LOCAL_VAULT/"
  echo "Imported missing files → $LOCAL_VAULT"
}

status_vault() {
  echo "repo:  $REPO_VAULT"
  echo "local: $LOCAL_VAULT"
  python3 - <<PY
import os
repo = os.path.expanduser("$REPO_VAULT")
local = os.path.expanduser("$LOCAL_VAULT")

def files(root):
    out = set()
    if not os.path.isdir(root):
        return out
    for dirpath, _, names in os.walk(root):
        for n in names:
            if n == ".DS_Store":
                continue
            rel = os.path.relpath(os.path.join(dirpath, n), root)
            out.add(rel)
    return out
r, l = files(repo), files(local)
print(f"counts repo={len(r)} local={len(l)}")
only_r = sorted(r - l)
only_l = sorted(l - r)
if only_r:
    print("in repo only:", ", ".join(only_r[:20]), ("..." if len(only_r) > 20 else ""))
if only_l:
    print("local only:", ", ".join(only_l[:20]), ("..." if len(only_l) > 20 else ""))
if not only_r and not only_l:
    print("in sync")
PY
}

cmd="${1:-}"
case "$cmd" in
  export) export_vault ;;
  import) import_vault ;;
  status) status_vault ;;
  *) usage; exit 1 ;;
esac
