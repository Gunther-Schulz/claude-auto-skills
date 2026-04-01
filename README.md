# claude-skills

Reusable quality checklists for Claude Code, delivered as slash commands with an optional smart classifier hook.

## Skills

| Command | When to use |
|---------|-------------|
| `/code-quality` | Before writing or modifying code — requirements review, consumer analysis, fallback tracing, pattern search |
| `/critical-thinking` | During investigation, debugging, or analysis — claim verification, backward traces, hypothesis testing |
| `/critical-evaluation` | When evaluating proposals — challenge assumptions before agreeing |

## Installation

```bash
git clone https://github.com/Gunther-Schulz/claude-skills.git
cd claude-skills
./install.sh
```

This installs:
- **Scripts** to `~/.local/bin/` (classifier and debug logger)
- **Commands** symlinked to `~/.claude/commands/` (slash commands)
- **Config** to `~/.config/claude-skills/config.sh`
- **State/logs** to `~/.local/state/claude-skills/`

### Classifier hook

The classifier hook automatically detects what kind of task a user prompt involves and reminds Claude to run the relevant skill before proceeding. It uses `claude -p` with Haiku for fast, cheap classification on every prompt.

The installer prints the hook config snippet to add to `hooks.UserPromptSubmit` in `~/.claude/settings.json`. Logs cost, duration, and token counts per classification to `~/.local/state/claude-skills/classifier.log`.

## Directory layout

Follows [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/latest/):

| Artifact | Location | Override env var |
|----------|----------|------------------|
| Config | `~/.config/claude-skills/config.sh` | `CLAUDE_SKILLS_CONFIG` |
| Logs | `~/.local/state/claude-skills/` | `CLAUDE_SKILLS_STATE` |
| Scripts | `~/.local/bin/` | — |
| Commands | `~/.claude/commands/` | — |

## Configuration

Edit `~/.config/claude-skills/config.sh`:

```bash
# Classifier model (default: claude-haiku-4-5-20251001)
CLASSIFIER_MODEL="claude-haiku-4-5-20251001"

# Effort level for classifier (default: low)
CLASSIFIER_EFFORT="low"

# Max budget per classification call in USD (default: no limit)
CLASSIFIER_MAX_BUDGET=""
```

## Updating

```bash
cd claude-skills
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

## Roadmap

- **CLIPPY integration**: Add a fourth classifier category for substantial feature/refactoring tasks that recommends `/clippy-composer` (from [coding-clippy](https://github.com/Gunther-Schulz/coding-clippy)) instead of `/code-quality`. Waiting on CLIPPY skills stabilization.
- **Enrich /code-quality from CLIPPY patterns**: Extract useful lightweight checks from CLIPPY's quality checkpoints (e.g., search for existing patterns before writing, duplication checks) without importing the full protocol.
- **Classifier accuracy tuning**: Haiku sometimes over-classifies (triggers all three skills) or mis-classifies (proposal vs code task). Refine the classifier prompt based on log analysis.

## License

MIT
