#!/usr/bin/env bash
set -euo pipefail

SETTINGS="${HOME}/.claude/settings.json"

GREEN='\033[0;32m'
NC='\033[0m'

if ! command -v jq &>/dev/null; then
    echo "Error: jq is required. Install with: sudo apt install jq  or  brew install jq" >&2
    exit 1
fi

if [ ! -f "$SETTINGS" ]; then
    echo "Error: $SETTINGS not found." >&2
    exit 1
fi

echo "Uninstalling claude-auto-skills..."
echo ""

jq '
  del(.enabledPlugins["claude-auto-skills@local"]) |
  del(.extraKnownMarketplaces["local"])
' "$SETTINGS" > "${SETTINGS}.tmp" && mv "${SETTINGS}.tmp" "$SETTINGS"

echo -e "  ${GREEN}removed${NC}  claude-auto-skills@local from enabledPlugins"
echo -e "  ${GREEN}removed${NC}  local marketplace from extraKnownMarketplaces"
echo ""
echo "Config and logs are NOT removed. To clean up:"
echo "  rm -rf \${XDG_CONFIG_HOME:-\$HOME/.config}/claude-auto-skills"
echo "  rm -rf \${XDG_STATE_HOME:-\$HOME/.local/state}/claude-auto-skills"
echo ""
echo "Restart Claude Code to apply changes."
