---
name: critical-thinking
description: Apply when the user asks to INVESTIGATE, DEBUG, TRACE, or ANALYZE something — find a bug, understand behavior, research a question, explain code.
version: 1.0.0
---

## Critical Thinking Checklist

Apply these rules to the current task when investigating, debugging, or making claims.

### Required output markers (user will spot-check these)

These markers are already defined in the rules below — this section is a summary:
- `✅ Verified: <supporting computation/data>` — after every verified claim
- `⚠️ Unverified: <why>` — after every unverified claim
- `🔍 Assumptions from rejected hypothesis: [list]` — before proposing next hypothesis
- `🔍 Backward trace: [symptom] ← ... ← [origin]` — before proposing a fix

A claim without a ✅/⚠️ tag, a fix without a backward trace, or a new hypothesis without an assumption list is a checklist violation.

### Claim verification
- All technical and quantitative claims must be tagged:
  - `✅ Verified: <what computation/data supports this>`
  - `⚠️ Unverified: <why — no data yet, assumption, etc.>`
- BEFORE confirming any technical claim (yours or the user's), write the supporting trace or computation. The verification must appear BEFORE the conclusion. If you cannot trace it, say "I haven't verified this."

### When numbers contradict your understanding
- STOP and investigate the discrepancy before responding.
- Do not explain it away, dismiss it as noise, or continue with your previous model.
- Run a query, read a file, or compute. The investigation must appear in the response before any explanation.

### When a hypothesis is rejected
- List the assumptions the rejected hypothesis rested on.
- If the next hypothesis shares any of those assumptions, test the shared assumption first.
- The assumption list must appear before the next hypothesis.

### Before labeling variance as "noise" or "rounding"
- Compute the maximum possible magnitude from the claimed noise source.
- If observed variance exceeds that, there is an unexplained signal — say so.

### Before concluding research or investigation
- List each claim alongside the specific data point or computation that supports it.
- Any claim without supporting data must be labeled "unverified hypothesis."

### Before proposing a fix
- Trace the execution path backward from where the symptom manifests to where the wrong value or wrong branch first enters the system.
- The fix must target that origin point, not the symptom location.
- State the backward trace before the fix.

### When results differ from expectations
- FIRST run an independent check (different method, cross-reference, manual computation) and show it.
- THEN if own work checks out, investigate external factors.
- Do not attribute a discrepancy to external causes without first demonstrating your own computation is correct.
