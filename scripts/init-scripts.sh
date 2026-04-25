#!/bin/bash
npx skills add BvdMerwe/trogteam -y -g

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

mkdir -p "$REPO_ROOT/.trogteam"

# Try repo-local skills/ first, fall back to ~/.agents/skills/
if [ -f "$REPO_ROOT/skills/grug/scripts/run-grug-loop.sh" ]; then
  GRUG_SRC="$REPO_ROOT/skills/grug/scripts"
else
  GRUG_SRC="$HOME/.agents/skills/grug/scripts"
fi
if [ -f "$REPO_ROOT/skills/grunk/scripts/run-grunk-loop.sh" ]; then
  GRUNK_SRC="$REPO_ROOT/skills/grunk/scripts"
else
  GRUNK_SRC="$HOME/.agents/skills/grunk/scripts"
fi

cp -f "$GRUG_SRC/"*.sh "$REPO_ROOT/.trogteam/"
cp -f "$GRUNK_SRC/"*.sh "$REPO_ROOT/.trogteam/"
chmod +x "$REPO_ROOT/.trogteam/"*.sh
echo ".trogteam/ ready (grug from $GRUG_SRC, grunk from $GRUNK_SRC)"