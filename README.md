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
| Config | `.claude/auto-skills.local.md` (project) or `~/.claude/auto-skills.local.md` (global) |
| Logs | `~/.local/state/claude-auto-skills/` |

## Configuration

Edit `~/.claude/auto-skills.local.md` (global) or `.claude/auto-skills.local.md` (per-project override):

```yaml
---
enabled: true
sensitivity: normal    # low | normal | high
model: claude-haiku-4-5-20251001
effort: low
debug_logger: false    # enable hook input debug logging

# Category definitions — add custom skills by adding entries here
categories:
  - name: code-quality
    match: "User is asking to WRITE, EDIT, CREATE, or IMPLEMENT code."
    action: "Run /auto-skills:code-quality before writing code."
  - name: critical-thinking
    match: "User is asking to INVESTIGATE, DEBUG, TRACE, or ANALYZE something."
    action: "Run /auto-skills:critical-thinking before proceeding."
  - name: critical-evaluation
    match: "User is asking to EVALUATE, COMPARE, CHOOSE, or DECIDE between options."
    action: "Run /auto-skills:critical-evaluation before responding."
  - name: skill-design
    match: "User is asking to WRITE, UPDATE, DESIGN, or REVIEW a skill or prompt template."
    action: "Run /auto-skills:skill-design before writing or modifying skills."
---
```

### Adding custom skills

1. Add a category entry to the `categories` list in your config
2. Create a corresponding `SKILL.md` in your project's `.claude/skills/` directory
3. The classifier will now route matching prompts to your skill

## Management

Use `/auto-skills:auto-skills` inside Claude Code to toggle, check status, or change sensitivity. You can also pass arguments directly:

| Command | Action |
|---------|--------|
| `/auto-skills:auto-skills status` | Show current config and recent classifier activity |
| `/auto-skills:auto-skills toggle` | Enable/disable the classifier |
| `/auto-skills:auto-skills low` | Set sensitivity to low |

## Updating

```bash
claude plugin marketplace update local
claude plugin update auto-skills@local
```

Then `/reload-plugins` or restart Claude Code.

## Development

Skills and hooks live in `plugin/`:

```
plugin/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   └── auto-skills.md            # /auto-skills:auto-skills management command
├── hooks/
│   ├── hooks.json                # classifier + logger hook config
│   └── scripts/
│       ├── claude-skill-classifier   # Haiku-based prompt classifier
│       └── claude-hook-logger        # debug logger
└── skills/
    ├── code-quality/SKILL.md
    ├── critical-thinking/SKILL.md
    ├── critical-evaluation/SKILL.md
    └── skill-design/SKILL.md
```

After editing, push to GitHub and update:

```bash
git add -A && git commit -m "..." && git push
claude plugin marketplace update local
claude plugin update auto-skills@local
```

Then `/reload-plugins` or restart Claude Code.

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
