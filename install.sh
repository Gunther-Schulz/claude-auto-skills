#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETTINGS="${HOME}/.claude/settings.json"
CONFIGDIR="${CLAUDE_AUTO_SKILLS_CONFIG:-${XDG_CONFIG_HOME:-${HOME}/.config}/claude-auto-skills}"

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

if ! command -v jq &>/dev/null; then
    echo "Error: jq is required. Install with: sudo apt install jq  or  brew install jq" >&2
    exit 1
fi

if [ ! -f "$SETTINGS" ]; then
    echo "Error: $SETTINGS not found. Is Claude Code installed?" >&2
    exit 1
fi

echo "Installing claude-auto-skills..."
echo ""

# --- Migrate from pre-plugin install ---
# Remove old scripts copied to ~/.local/bin
for script in claude-skill-classifier claude-hook-logger; do
    target="${HOME}/.local/bin/${script}"
    if [ -f "$target" ] && ! [ -L "$target" ]; then
        rm "$target"
        echo -e "  ${GREEN}removed${NC}    $target (old install)"
    fi
done

# Remove old command symlinks from ~/.claude/commands/
OLD_COMMANDS=(
    auto-skills-level.md auto-skills-status.md auto-skills-toggle.md
    code-quality.md critical-thinking.md critical-evaluation.md skill-design.md
)
for cmd in "${OLD_COMMANDS[@]}"; do
    target="${HOME}/.claude/commands/${cmd}"
    if [ -L "$target" ]; then
        rm "$target"
        echo -e "  ${GREEN}removed${NC}    $target (old install)"
    fi
done
echo ""

# --- Register local marketplace, enable the plugin, and strip any old manual hook
# entries (claude-skill-classifier / claude-hook-logger) that were used before
# the plugin approach — the plugin's hooks/hooks.json replaces them.
jq --arg path "$SCRIPT_DIR" '
  .extraKnownMarketplaces["local"] = {"source": {"source": "directory", "path": $path}} |
  .enabledPlugins["claude-auto-skills@local"] = true |
  if .hooks.UserPromptSubmit then
    .hooks.UserPromptSubmit = [
      .hooks.UserPromptSubmit[] |
      select(
        (.hooks[0].command // "") |
        (contains("claude-skill-classifier") or contains("claude-hook-logger")) |
        not
      )
    ]
  else . end
' "$SETTINGS" > "${SETTINGS}.tmp" && mv "${SETTINGS}.tmp" "$SETTINGS"

echo -e "  ${GREEN}registered${NC} marketplace 'local' → $SCRIPT_DIR"
echo -e "  ${GREEN}enabled${NC}    claude-auto-skills@local"
echo -e "  ${GREEN}cleaned${NC}    old hook entries from settings.json (if any)"
echo ""

# Config
mkdir -p "$CONFIGDIR"
if [ ! -f "${CONFIGDIR}/config.sh" ]; then
    cp "${SCRIPT_DIR}/config.sh.example" "${CONFIGDIR}/config.sh"
    echo -e "  ${GREEN}installed${NC}  ${CONFIGDIR}/config.sh"
else
    echo -e "  ${YELLOW}kept${NC}       ${CONFIGDIR}/config.sh (already exists)"
fi

echo ""
echo "Restart Claude Code to apply changes."
