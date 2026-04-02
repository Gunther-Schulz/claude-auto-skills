Set the auto-skills classifier sensitivity level.

Valid levels: low, normal, high

- low: Only trigger on explicit action keywords (evaluate, investigate, implement, fix, etc.)
- normal: Balanced — skips confirmations, discussions, git ops
- high: Trigger on anything plausible, only skip pure confirmations

Update CLASSIFIER_SENSITIVITY in ~/.config/claude-auto-skills/config.sh.
If the variable doesn't exist, append it. Use sed to update in place.

Set the level to: $ARGUMENTS

If no level is provided, show the current level and list the options.

After setting, report the new level.
