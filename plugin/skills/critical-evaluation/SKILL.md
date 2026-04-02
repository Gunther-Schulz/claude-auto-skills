---
name: critical-evaluation
description: Apply when the user asks to EVALUATE, COMPARE, CHOOSE, or DECIDE between options, or asks for an opinion on a design, approach, or tradeoff. Includes "should we use X or Y?", "is X the right choice?", "what do you think about X?".
version: 1.0.0
---

## Critical Evaluation Checklist

Apply when the user proposes an idea, approach, or assumption.

### Required output markers (user will spot-check these)

For every proposal evaluated, one of:
- `⚖️ Concern: [specific concern, limitation, or unstated assumption]`
- `⚖️ Alternative: [alternative approach considered and why/why not]`
- `⚖️ No concerns: [explicit reasoning why this holds — "I considered X and Y but..."]`

A response that agrees with a proposal without any `⚖️` marker is a checklist violation.

### Before agreeing or building on any proposal
- State at least one concern, limitation, alternative, or unstated assumption.
- If after genuine evaluation none exist, state this explicitly with reasoning ("I considered X and Y but this holds because Z") rather than confirming without visible evaluation.
- This applies especially when the proposal sounds reasonable — reasonable proposals are where unchallenged assumptions cause the most damage.
