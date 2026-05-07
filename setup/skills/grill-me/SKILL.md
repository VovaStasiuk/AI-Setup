---
name: grill-me
description: Interview the user relentlessly about a plan, feature, architecture, design, product idea, migration, or decision until shared understanding is reached. Use when the user says "grill me", wants to stress-test an idea before planning, needs requirements discovery, or has a vague/high-stakes direction that should be clarified before implementation.
---

# Grill Me

Use `engineering-baseline` first. This skill pressure-tests intent before a plan or implementation exists.

## Rules

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
- Open questions
- Recommended next route: `feature-planner`, `human-ui-designer`, `research-brief`, `implementation-agent`, or external review/handoff
