# claude-auto-skills

Automatic quality checklists for Claude Code. A Haiku-based classifier detects what kind of task each prompt involves and loads the relevant skill checklist before Claude starts working.

## Why

Claude Code follows instructions but doesn't consistently self-check. It can skip consumer analysis before modifying interfaces, agree with proposals without challenging assumptions, or make claims without showing supporting data. These skills force verifiable checkpoints — tagged markers (📋, ✅, ⚖️) that you can spot-check — and the classifier loads them automatically so you don't have to remember to invoke them.

## Skills

| Skill | When to use |
|-------|-------------|
| `/auto-skills:code-quality` | Before writing or modifying code — requirements review, consumer analysis, fallback tracing, pattern search |
| `/auto-skills:critical-thinking` | During investigation, debugging, or analysis — claim verification, backward traces, hypothesis testing |
| `/auto-skills:critical-evaluation` | When evaluating proposals — challenge assumptions before agreeing |
| `/auto-skills:skill-design` | When writing or reviewing skills, rules, checklists, or prompt templates |

## Installation

```bash
git clone https://github.com/Gunther-Schulz/claude-auto-skills.git
cd claude-auto-skills
./install.sh
```

This handles everything: config setup, migration from older installs, marketplace registration, and plugin installation via the `claude` CLI.

Restart Claude Code or run `/reload-plugins` to activate.

### What the plugin provides

- **4 skills** — auto-discovered by Claude based on task context
- **1 command** — `/auto-skills:auto-skills` for toggling, status, and sensitivity control
- **2 hooks** — classifier (detects task type per prompt) and debug logger

### Classifier hook

The classifier hook automatically detects what kind of task a user prompt involves and injects the relevant skill reminder. It uses `claude -p` with Haiku for fast, cheap classification on every prompt.

Logs cost, duration, and token counts per classification to `~/.local/state/claude-auto-skills/classifier.log`.

## Directory layout

| Artifact | Location |
|----------|----------|
| Plugin | `~/.claude/plugins/cache/local/auto-skills/` (managed by Claude Code) |
| Config | `~/.config/claude-auto-skills/config.sh` |
| Logs | `~/.local/state/claude-auto-skills/` |

Config and logs follow the [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/latest/) and can be overridden with `CLAUDE_AUTO_SKILLS_CONFIG` and `CLAUDE_AUTO_SKILLS_STATE`.

## Configuration

Edit `~/.config/claude-auto-skills/config.sh`:

```bash
# Enable/disable the classifier (default: true)
# Skills remain available manually via /auto-skills:code-quality etc. when disabled
CLASSIFIER_ENABLED=true

# Classifier model (default: claude-haiku-4-5-20251001)
CLASSIFIER_MODEL="claude-haiku-4-5-20251001"

# Effort level for classifier (default: low)
CLASSIFIER_EFFORT="low"

# Max budget per classification call in USD (default: no limit)
CLASSIFIER_MAX_BUDGET=""

# Sensitivity: low, normal, high (default: normal)
# low:    Only trigger on explicit action keywords
# normal: Balanced — skips confirmations, discussions, git ops
# high:   Trigger on anything plausible
CLASSIFIER_SENSITIVITY="normal"
```

### claude-worktime statusline integration (optional)

If you use [claude-worktime](https://github.com/Gunther-Schulz/claude-worktime), add to `~/.config/claude-worktime/config.sh`:

```bash
# Auto-skills status (grey label, green "on" / grey "off")
_skills_conf="${CLAUDE_AUTO_SKILLS_CONFIG:-${XDG_CONFIG_HOME:-$HOME/.config}/claude-auto-skills}/config.sh"
_skills_enabled="off"
if [ -f "$_skills_conf" ]; then
    _skills_enabled="on"
    source "$_skills_conf" 2>/dev/null
    [ "${CLASSIFIER_ENABLED:-true}" != "true" ] && _skills_enabled="off"
fi
_gray=$'\033[38;5;246m'; _green=$'\033[32m'; _reset=$'\033[0m'
if [ "$_skills_enabled" = "on" ]; then
    _mode="${CLASSIFIER_SENSITIVITY:-normal}"
    GROUP_AUTOSKILLS="${_gray}auto-skills:${_reset}${_green}on(${_mode})${_reset}"
else
    GROUP_AUTOSKILLS="${_gray}auto-skills:off${_reset}"
fi
GROUP_AUTOSKILLS_COLOR="none"  # requires claude-worktime v97e5788+ for "none" support
STATUSLINE_3="MODEL RATE_5H RATE_7D CONTEXT AUTOSKILLS"
```

## Management

Use `/auto-skills:auto-skills` inside Claude Code to toggle, check status, or change sensitivity. You can also pass arguments directly:

| Command | Action |
|---------|--------|
| `/auto-skills:auto-skills status` | Show current config and recent classifier activity |
| `/auto-skills:auto-skills toggle` | Enable/disable the classifier |
| `/auto-skills:auto-skills low` | Set sensitivity to low |

## Updating

```
/plugin marketplace update local
/plugin uninstall auto-skills@local
/plugin install auto-skills@local
/reload-plugins
```

## Uninstalling

```
/plugin uninstall auto-skills@local
/plugin marketplace remove local
```

Config and logs are preserved. To remove them:
```bash
rm -rf ~/.config/claude-auto-skills ~/.local/state/claude-auto-skills
```

## Effectiveness caveat

There is no way to prove these skills improve Claude's output quality. The skills force Claude to produce visible markers (📋, ✅, ⚖️) that make its verification steps auditable, but whether that changes actual thoroughness vs just documenting what it would have done anyway is unknown. The only reliable signal is your correction frequency over time — if you stop catching "you forgot to update X" mistakes, the skills are working. If the same mistakes persist, they're cosmetics.

## Roadmap

- **Classifier accuracy tuning**: Output filter rejects hallucinated responses. Transcript context helps disambiguate short prompts ("yes" after "shall I implement?" → code-quality). 89% accuracy on test battery. Ongoing: refine based on `classifier.log` analysis.
- **CLIPPY integration**: Add a fourth classifier category for substantial feature/refactoring tasks that recommends `/clippy-composer` (from [coding-clippy](https://github.com/Gunther-Schulz/coding-clippy)) instead of `/code-quality`. Waiting on CLIPPY skills stabilization.
- **Enrich /code-quality from CLIPPY patterns**: Extract useful lightweight checks from CLIPPY's quality checkpoints (e.g., search for existing patterns before writing, duplication checks) without importing the full protocol.
- **Replace `claude -p` subprocess with native hook classification**: Currently the classifier shells out to `claude -p` with Haiku (~3-6s latency, ~$0.008/call). Agent-type hooks (`type: "agent"`) would allow inline model calls without a subprocess, but are currently broken ([anthropics/claude-code#26474](https://github.com/anthropics/claude-code/issues/26474)). Prompt-type hooks can't inject context ([#37559](https://github.com/anthropics/claude-code/issues/37559)). Revisit when either is fixed.

## License

MIT
