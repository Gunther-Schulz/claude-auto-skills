# claude-auto-skills

Automatic quality checklists for Claude Code. A Haiku-based classifier detects what kind of task each prompt involves and loads the relevant skill checklist before Claude starts working.

## Skills

| Command | When to use |
|---------|-------------|
| `/code-quality` | Before writing or modifying code — requirements review, consumer analysis, fallback tracing, pattern search |
| `/critical-thinking` | During investigation, debugging, or analysis — claim verification, backward traces, hypothesis testing |
| `/critical-evaluation` | When evaluating proposals — challenge assumptions before agreeing |

## Installation

```bash
git clone https://github.com/Gunther-Schulz/claude-auto-skills.git
cd claude-auto-skills
./install.sh
```

This installs:
- **Scripts** to `~/.local/bin/` (classifier and debug logger)
- **Commands** symlinked to `~/.claude/commands/` (slash commands)
- **Config** to `~/.config/claude-auto-skills/config.sh`
- **State/logs** to `~/.local/state/claude-auto-skills/`

### Classifier hook

The classifier hook automatically detects what kind of task a user prompt involves and reminds Claude to run the relevant skill before proceeding. It uses `claude -p` with Haiku for fast, cheap classification on every prompt.

The installer prints the hook config snippet to add to `hooks.UserPromptSubmit` in `~/.claude/settings.json`. Logs cost, duration, and token counts per classification to `~/.local/state/claude-auto-skills/classifier.log`.

## Directory layout

Follows [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/latest/):

| Artifact | Location | Override env var |
|----------|----------|------------------|
| Config | `~/.config/claude-auto-skills/config.sh` | `CLAUDE_SKILLS_CONFIG` |
| Logs | `~/.local/state/claude-auto-skills/` | `CLAUDE_SKILLS_STATE` |
| Scripts | `~/.local/bin/` | — |
| Commands | `~/.claude/commands/` | — |

## Configuration

Edit `~/.config/claude-skills/config.sh`:

```bash
# Enable/disable the classifier (default: true)
# Skills remain available manually via /code-quality etc. when disabled
CLASSIFIER_ENABLED=true

# Classifier model (default: claude-haiku-4-5-20251001)
CLASSIFIER_MODEL="claude-haiku-4-5-20251001"

# Effort level for classifier (default: low)
CLASSIFIER_EFFORT="low"

# Max budget per classification call in USD (default: no limit)
CLASSIFIER_MAX_BUDGET=""
```

### claude-worktime statusline integration (optional)

If you use [claude-worktime](https://github.com/Gunther-Schulz/claude-worktime), add to `~/.config/claude-worktime/config.sh`:

```bash
# Auto-skills status (shows skills:on or skills:off)
_skills_conf="${CLAUDE_SKILLS_CONFIG:-${XDG_CONFIG_HOME:-$HOME/.config}/claude-skills}/config.sh"
_skills_enabled="off"
if [ -f "$_skills_conf" ]; then
    _skills_enabled="on"
    source "$_skills_conf" 2>/dev/null
    [ "${CLASSIFIER_ENABLED:-true}" != "true" ] && _skills_enabled="off"
fi
GROUP_AUTOSKILLS="skills:${_skills_enabled}"
STATUSLINE_3="MODEL RATE_5H RATE_7D CONTEXT AUTOSKILLS"
```

## Updating

```bash
cd claude-auto-skills
git pull
./install.sh
```

Commands update immediately via symlinks. Scripts are re-copied on `./install.sh`.

## Uninstalling

```bash
./uninstall.sh
```

Removes scripts and command symlinks. Config and state directories are preserved. Remove the classifier hook from `settings.json` manually.

## Adding to CLAUDE.md (recommended)

Add condensed references to your global `~/.claude/CLAUDE.md` so Claude is aware of the skills even without the classifier hook:

```markdown
## Critical thinking
Verify claims, trace before fixing, investigate contradictions. Full rules: `/critical-thinking`

## Code quality
List requirements before coding, check consumers before modifying interfaces, trace fallbacks, search for patterns. Full rules: `/code-quality`

## Critical evaluation
Challenge proposals before agreeing — state concerns, alternatives, or unstated assumptions. Full rules: `/critical-evaluation`
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
