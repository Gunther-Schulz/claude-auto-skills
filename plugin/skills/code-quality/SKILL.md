---
name: code-quality
description: Apply when the user asks to WRITE, EDIT, CREATE, or IMPLEMENT code — new features, bug fixes, refactoring, file creation. Also apply for design constraints or corrections directed at code being written.
version: 1.0.0
---

## Code Quality Checklist

Apply these rules to the current task before writing or modifying code.

### Required output markers (user will spot-check these)

Before code, list requirements from the discussion:
- `📋 Requirements: [requirement] — [met/simplified/skipped]` for each

When modifying shared interfaces, list consumers and evaluate coupling:
- `📋 Consumers: [file:line] — [status: ok/needs change/N/A]` for each
- `📋 Coupling: [dependency] — [direct requirement/should be configurable/should be inverted]` for each cross-project dependency

When checking consistency after changes:
- `📋 Consistency: [consumer/dependency] — [consistent/updated/N/A]` for each

### Before writing code
- Re-read the preceding discussion. List the requirements, constraints, and quality expectations it established.
- Check each requirement off in the implementation. If any is being simplified or skipped, state this BEFORE coding.
- If the discussion included investigation findings or root cause analysis, verify the implementation targets the origin identified — not just the symptom location.

### Before modifying shared interfaces, function signatures, state variables, or data formats
- Read the code being changed and identify:
  - (a) All immediate consumers — code that reads the state, calls the function, or depends on the format.
  - (b) All immediate dependencies — data it reads, configs it accepts, external state it assumes.
- For shared data formats (files, databases, queues, environment variables), search the codebase to find all readers — reading the writer alone is insufficient.
- Each consumer identified via search must be read before being listed as checked — a search match is discovery only.
- List each consumer and dependency with its current behavior and whether it requires a change. This list must appear in the response before the first line of implementation code.
- For each dependency on another project or system, evaluate: is this a direct requirement, or an assumption that should be configurable or inverted? Hardcoding another project's internals (env vars, paths, APIs) is a coupling smell — make it configurable unless there's a strong reason not to.

### When adding error suppression or fallbacks
- Trace the fallback/default value through downstream consumers in the same function and its callers.
- If any consumer treats the fallback as valid data (passes it to a write, uses it in a computation, returns it to a caller), the error must be handled explicitly — not suppressed.
- State which downstream paths were checked.

### After modifying shared interfaces, data formats, or state variables
- Check consistency in both directions:
  - Forward: trace each change to its consumers — code that calls it, messages that describe it, tests that validate it, docs that explain it.
  - Backward: trace each change to its dependencies — data formats it reads, configs it accepts, interfaces it assumes.
- List consumers and dependencies checked with their status (consistent / updated / N/A).

### When you identify a pattern (bug, smell, security issue, performance problem)
- Search the codebase for other instances. Report search results (files checked, matches found).
- Read each match before concluding whether it constitutes the same pattern.

### When auditing code
- Do multiple passes. List findings per pass. A pass that finds any functional issue requires another pass.
- Stop when a full pass finds zero functional issues.
