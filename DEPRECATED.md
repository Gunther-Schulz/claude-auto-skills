# Classifier Hooks (deprecated branch)

**Status:** Deprecated as of 2026-04-02. Preserved for reference.

This branch contains the Haiku-based classifier hook that was removed from `main`. Claude Code's built-in skill auto-discovery handles the common cases without the latency (~2-6s) and cost (~$0.008/call) of the `claude -p` subprocess.

## What this branch has that main doesn't

- `plugin/hooks/hooks.json` — hook config for UserPromptSubmit
- `plugin/hooks/scripts/claude-skill-classifier` — Python script that classifies prompts via `claude -p` with Haiku and injects skill reminders
- `plugin/hooks/scripts/claude-hook-logger` — debug logger (off by default)
- `.claude/auto-skills.local.md` config with classifier settings (sensitivity, model, categories)

## Known issue at time of deprecation

The classifier's `claude -p` call was returning empty output in some environments. This was not fully debugged — the root cause may be related to how the system prompt is passed as a positional argument.

## When to reconsider

- If Claude Code's auto-discovery misses skills for short/ambiguous prompts ("yes", "do it", "sounds good" after a design discussion)
- If agent-type hooks ([#26474](https://github.com/anthropics/claude-code/issues/26474)) or prompt-type context injection ([#37559](https://github.com/anthropics/claude-code/issues/37559)) become available — these would replace the `claude -p` subprocess with native inline classification
- If per-project sensitivity tuning is needed (auto-discovery has no sensitivity levels)

## Repo/plugin renamed

This branch uses the old name `auto-skills`. The repo was renamed to `claude-quality-skills` and the plugin to `quality-skills` on main. If restoring the classifier, update all `auto-skills` references to `quality-skills`.

## claude-worktime statusline integration

The classifier branch supported a worktime statusline group showing classifier status. To re-add if restoring the classifier, add to `~/.config/claude-worktime/config.sh`:

```bash
_skills_conf="${HOME}/.claude/quality-skills.local.md"
_skills_enabled="off"
if [ -f "$_skills_conf" ]; then
    _skills_enabled="on"
    _val=$(sed -n '/^---$/,/^---$/{/^enabled:/s/.*: *//p}' "$_skills_conf" | head -1)
    [ "$_val" = "false" ] && _skills_enabled="off"
fi
_gray=$'\033[38;5;246m'; _green=$'\033[32m'; _reset=$'\033[0m'
if [ "$_skills_enabled" = "on" ]; then
    _mode=$(sed -n '/^---$/,/^---$/{/^sensitivity:/s/.*: *//p}' "$_skills_conf" | head -1)
    GROUP_AUTOSKILLS="${_gray}quality-skills:${_reset}${_green}on(${_mode:-normal})${_reset}"
else
    GROUP_AUTOSKILLS="${_gray}quality-skills:off${_reset}"
fi
GROUP_AUTOSKILLS_COLOR="none"
STATUSLINE_3="MODEL RATE_5H RATE_7D CONTEXT AUTOSKILLS"
```

## To restore

```bash
git checkout classifier-hooks -- plugin/hooks/
```

Update `auto-skills` → `quality-skills` in all restored files, then push and reinstall the plugin.
