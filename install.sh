#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETTINGS="${HOME}/.claude/settings.json"
CONFIGDIR="${CLAUDE_AUTO_SKILLS_CONFIG:-${XDG_CONFIG_HOME:-${HOME}/.config}/claude-auto-skills}"

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

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

# Strip old manual hook entries from settings.json
if command -v jq &>/dev/null; then
    jq '
      if .hooks.UserPromptSubmit then
        .hooks.UserPromptSubmit = [
          .hooks.UserPromptSubmit[] |
          select(
            (.hooks[0].command // "") |
            (contains("claude-skill-classifier") or contains("claude-hook-logger")) |
            not
          )
        ]
      else . end |
      del(.extraKnownMarketplaces["local"])
    ' "$SETTINGS" > "${SETTINGS}.tmp" && mv "${SETTINGS}.tmp" "$SETTINGS"
    echo -e "  ${GREEN}cleaned${NC}    old hook/plugin entries from settings.json"
fi
echo ""

# Config
mkdir -p "$CONFIGDIR"
if [ ! -f "${CONFIGDIR}/config.sh" ]; then
    cp "${SCRIPT_DIR}/config.sh.example" "${CONFIGDIR}/config.sh"
    echo -e "  ${GREEN}installed${NC}  ${CONFIGDIR}/config.sh"
else
    echo -e "  ${YELLOW}kept${NC}       ${CONFIGDIR}/config.sh (already exists)"
fi

# Install plugin via CLI
if command -v claude &>/dev/null; then
    if ! claude plugin marketplace list 2>/dev/null | grep -q '"local"'; then
        claude plugin marketplace add Gunther-Schulz/claude-auto-skills
        echo -e "  ${GREEN}added${NC}      marketplace 'local'"
    else
        claude plugin marketplace update local 2>/dev/null
        echo -e "  ${GREEN}updated${NC}    marketplace 'local'"
    fi

    if claude plugin list 2>/dev/null | grep -q 'auto-skills@local'; then
        claude plugin update auto-skills@local 2>/dev/null
        echo -e "  ${GREEN}updated${NC}    auto-skills@local"
    else
        claude plugin install auto-skills@local
        echo -e "  ${GREEN}installed${NC}  auto-skills@local"
    fi
    echo ""
    echo "Restart Claude Code or run /reload-plugins to activate."
else
    echo ""
    echo "Claude CLI not found. Run these commands inside Claude Code:"
    echo ""
    echo "  /plugin marketplace add Gunther-Schulz/claude-auto-skills"
    echo "  /plugin install auto-skills@local"
    echo ""
    echo "Then restart Claude Code or run /reload-plugins."
fi
