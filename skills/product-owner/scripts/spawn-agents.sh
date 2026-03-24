#!/usr/bin/env bash
set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel 2>/dev/null || (cd "$SCRIPT_DIR/../.." && pwd))"

# Both models are required — fail early with a clear message
if [ -z "${TL_MODEL:-}" ] || [ -z "${ENG_MODEL:-}" ]; then
  echo "Error: TL_MODEL and ENG_MODEL must both be set before spawning agents."
  echo ""
  echo "Usage:"
  echo "  TL_MODEL=<model> ENG_MODEL=<model> bash .tech-team/spawn-agents.sh"
  echo ""
  echo "Example:"
  echo "  TL_MODEL=claude-sonnet-4-5 ENG_MODEL=claude-haiku-3-5 bash .tech-team/spawn-agents.sh"
  exit 1
fi

# Create .tech-team directory if it doesn't exist
TECH_TEAM_DIR="$SKILL_DIR/.tech-team"
mkdir -p "$TECH_TEAM_DIR"

# Copy loop scripts from skills/ to .tech-team/
TL_SOURCE="$SKILL_DIR/skills/tech-lead/scripts/run-tl-loop.sh"
ENG_SOURCE="$SKILL_DIR/skills/engineer/scripts/run-eng-loop.sh"
TL_TARGET="$TECH_TEAM_DIR/run-tl-loop.sh"
ENG_TARGET="$TECH_TEAM_DIR/run-eng-loop.sh"

if [ ! -f "$TL_SOURCE" ]; then
  echo "Error: TL source script not found at $TL_SOURCE"
  exit 1
fi
if [ ! -f "$ENG_SOURCE" ]; then
  echo "Error: Engineer source script not found at $ENG_SOURCE"
  exit 1
fi

cp -f "$TL_SOURCE" "$TL_TARGET"
cp -f "$ENG_SOURCE" "$ENG_TARGET"

# Make loop scripts executable
chmod +x "$TL_TARGET"
chmod +x "$ENG_TARGET"

echo "Scripts synced from skills/ to .tech-team/"

echo "Spawning TL loop (model: $TL_MODEL)..."
echo "Spawning Engineer loop (model: $ENG_MODEL)..."

if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS: use osascript to open new Terminal windows, passing model env vars through
  osascript -e "tell application \"Terminal\" to do script \"TL_MODEL='$TL_MODEL' bash '$TL_TARGET'\""
  osascript -e "tell application \"Terminal\" to do script \"ENG_MODEL='$ENG_MODEL' bash '$ENG_TARGET'\""
else
  # Linux: try gnome-terminal, fall back to xterm
  # Note: gnome-terminal detaches automatically; xterm needs explicit & for background
  gnome-terminal -- bash -c "TL_MODEL='$TL_MODEL' bash '$TL_TARGET'" 2>/dev/null \
    || TL_MODEL="$TL_MODEL" xterm -e bash "$TL_TARGET" &
  gnome-terminal -- bash -c "ENG_MODEL='$ENG_MODEL' bash '$ENG_TARGET'" 2>/dev/null \
    || ENG_MODEL="$ENG_MODEL" xterm -e bash "$ENG_TARGET" &
fi

echo ""
echo "TL and Engineer loops spawned in new terminal windows."
echo "To stop: close the terminal windows or press Ctrl+C in each."
