#!/usr/bin/env bash
set -euo pipefail

SETTINGS="${HOME}/.claude/settings.json"

GREEN='\033[0;32m'
NC='\033[0m'

echo "Uninstalling claude-auto-skills..."
echo ""

# Clean up any leftover settings.json entries from older install methods
if command -v jq &>/dev/null && [ -f "$SETTINGS" ]; then
    jq '
      del(.enabledPlugins["auto-skills@local"]) |
      del(.extraKnownMarketplaces["local"])
    ' "$SETTINGS" > "${SETTINGS}.tmp" && mv "${SETTINGS}.tmp" "$SETTINGS"
    echo -e "  ${GREEN}cleaned${NC}  legacy entries from settings.json"
fi

echo ""
echo "Now run these commands inside Claude Code:"
echo ""
echo "  /plugin uninstall auto-skills@local"
echo "  /plugin marketplace remove local"
echo ""
echo "Config and logs are NOT removed. To clean up:"
echo "  rm -rf \${XDG_CONFIG_HOME:-\$HOME/.config}/claude-auto-skills"
echo "  rm -rf \${XDG_STATE_HOME:-\$HOME/.local/state}/claude-auto-skills"
