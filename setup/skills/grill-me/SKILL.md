---
name: grill-me
description: Use when the user says "grill me" or invokes the older grill-me workflow. Prefer the docs-aware grill-with-context workflow for project, product, architecture, design, migration, and feature clarification.
---

# Grill Me

This is a compatibility alias. Use `engineering-baseline`, then use `grill-with-context`.

If `grill-with-context` is unavailable, fall back to this minimal behavior:

- Apply the engineering-baseline critical thinking standard: do not assume the idea is good.
- Ask one focused question at a time.
- If a question can be answered by inspecting the repo or project docs, inspect instead of asking.
- For each question, provide your recommended answer and why, so the user can confirm quickly.
- Walk the decision tree: resolve dependencies between choices before moving to downstream details.
- Do not fill unknown requirements with optimistic assumptions; mark them as unknown and ask.
- Keep going until goal, audience, success criteria, constraints, non-goals, risks, and next workflow are clear.
- Do not implement during the grilling session.

## Finish

End with:

- Decisions confirmed
- Shared language / terms clarified
- Open questions
- Candidate doc updates, if any, with recommended destination
- Recommended next route: `feature-planner`, `human-ui-designer`, `research-brief`, `implementation-agent`, or external review/handoff
