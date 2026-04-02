---
name: skill-design
description: Apply when the user asks to WRITE, UPDATE, DESIGN, or REVIEW a skill, rule, checklist, or prompt template. Includes creating new skills, modifying existing skill files, or discussing how skills should work.
version: 1.0.0
---

## Skill Design Checklist

Apply when writing, modifying, or reviewing any skill, rule, or checklist — not just auto-skills.

### Required output markers (user will spot-check these)

- `🔧 Phenomenon: [what actually goes wrong/right and why]` — before drafting any rule
- `🔧 Proxy check: [element] — [direct representation/proxy for X → rewrite as Y]` — for each rule element
- `🔧 Non-firing cases: [scenario] — [should trigger: yes/no]` — at least two, one edge case
- `🔧 Scope test: [context] — [holds/breaks/unclear because...]` — at least two different contexts

### Foundational principle

Every element of a rule — trigger, condition, action, threshold, scope — must directly represent the phenomenon it addresses. If any element is a proxy, approximation, or convention where the actual condition can be expressed, the rule is not finished.

### Before drafting a rule

1. **Identify the phenomenon.** Describe what actually goes wrong (or right) and why. Separate the specific incident from the general pattern — a specific incident reveals one facet; the rule must address the root cause across all contexts where it applies.

### When drafting a rule

2. **Derive every element from the phenomenon:**
   - Observable trigger — something visible in conversation or tool output, not an internal state. A rule that relies on noticing an internal state (e.g., "be more careful") will fail.
   - Concrete mandatory action — a specific step to perform, not a quality to exhibit. "Be careful" is a proxy for what should actually be done.
   - Verifiable checkpoint — output or artifact that proves the action was taken. Without it, compliance is judgment rather than observation.

### After drafting a rule

3. **Validate precision.** For each element (trigger, action, checkpoint, every threshold):
   - Does it represent the actual condition, or a convenient approximation?
   - If any element can be replaced by the precise phenomenon it proxies for, rewrite it. Finding a proxy and keeping it with a justification is not acceptable.
   - Enumerate at least two cases where the trigger would NOT fire, with at least one plausible edge case. For each, state whether the rule should have applied. If any should have triggered but didn't, the trigger is too narrow.

4. **Validate scope.** Rules should be project-agnostic and language-agnostic unless explicitly scoped.
   - Substitute at least two different contexts and state whether the rule holds in each.
   - At least one substitution should be a context where it's unclear whether the rule applies — forcing real judgment.
   - If the rule breaks in a valid context, it's over-fitted.

5. **Check for mechanical vs cosmetic compliance.** Ask: could this rule be followed to the letter while still missing the phenomenon it's meant to prevent? If yes, the checkpoint is cosmetic — it verifies format, not substance. Add a step that forces engagement with the actual content (e.g., "evaluate whether the dependency should exist" not just "list dependencies").

### Review

Present the rule with the element justification list. Commit only after user approval.
