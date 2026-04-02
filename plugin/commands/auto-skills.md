---
description: Manage the auto-skills classifier — toggle on/off, check status, or set sensitivity level.
allowed-tools: AskUserQuestion, Read, Bash
disable-model-invocation: true
argument-hint: [status|toggle|low|normal|high]
---

Manage the auto-skills classifier.

Config: `~/.config/claude-auto-skills/config.sh`
Log: `~/.local/state/claude-auto-skills/classifier.log`

Set the action to: $ARGUMENTS

If $ARGUMENTS is `status`, `toggle`, `low`, `normal`, or `high` — handle it directly without prompting.

Otherwise use AskUserQuestion:

Question: "What would you like to do?"
Header: "auto-skills"
Options:
  - Status (Show current config and recent classifier activity)
  - Toggle (Turn classifier on or off)
  - Set level (Change sensitivity: low, normal, or high)

---

## Status

Read the config file and display:
- CLASSIFIER_ENABLED (on/off)
- CLASSIFIER_SENSITIVITY (low/normal/high)
- CLASSIFIER_MODEL
- CLASSIFIER_EFFORT

Show the last 5 non-DEBUG lines from the log file (skip lines containing ` DEBUG |`).

---

## Toggle

Read CLASSIFIER_ENABLED from the config file.
- If `true` or absent/commented → set to `false`
- If `false` → set to `true`

Use sed to update in place. If the variable is missing, append it.
Report the new state.

---

## Set level

If level is not already known from $ARGUMENTS, use AskUserQuestion:

Question: "Which sensitivity level?"
Header: "Level"
Options:
  - low (Only trigger on explicit action keywords: evaluate, investigate, implement, fix, etc.)
  - normal (Balanced — skips confirmations, discussions, git ops)
  - high (Trigger on anything plausible, only skip pure confirmations)

Update CLASSIFIER_SENSITIVITY in the config file using sed. If missing, append it.
Report the new level.
