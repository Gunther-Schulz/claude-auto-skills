---
name: auto-skills
description: Show available auto-skills and their descriptions.
allowed-tools: Read, Bash
disable-model-invocation: true
---

Show a summary of the auto-skills plugin.

List the installed skills by reading the SKILL.md frontmatter from each skill directory in this plugin. For each skill, show:
- Skill name (namespaced as `auto-skills:<name>`)
- Description (from frontmatter)

Also note: skills are auto-discovered by Claude Code based on task context. No manual invocation needed for normal use. Explicit invocation via `/auto-skills:<name>` is available if needed.
