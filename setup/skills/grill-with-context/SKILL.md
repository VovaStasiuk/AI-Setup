---
name: grill-with-context
description: Use when the user says "grill me", wants to stress-test a feature, product idea, architecture, design, migration, or decision before planning, or needs project-aware requirements discovery.
---

# Grill With Context

Use `engineering-baseline` first. This skill pressure-tests intent before planning or implementation, and uses project context/docs when they exist.

## Context Scan

Before asking questions, inspect only the relevant project context that is cheap and likely to change the questions:

- `.ai/project-context.md`
- `.ai/domain.md`
- `.ai/tech-stack.md`
- `.ai/DESIGN.md` for UI/design topics
- `.ai/specs/<feature>/` when the feature is identifiable
- `.ai/decisions/` when the topic involves hard-to-reverse tradeoffs
- `CONTEXT.md` or domain docs if the project already uses them
- nearby code only when terms, constraints, or existing behavior are unclear

If no project docs exist, behave like normal grilling and ask from first principles.

## Rules

- Apply the engineering-baseline critical thinking standard: do not assume the idea is good.
- Ask one focused question at a time.
- If a question can be answered by inspecting the repo or project docs, inspect instead of asking.
- For each question, provide your recommended answer and why, so the user can confirm or reject quickly.
- Challenge fuzzy language, overloaded terms, hidden assumptions, and terminology that conflicts with existing docs or code.
- Use `domain-modeling` when terminology, lifecycle states, ownership, tenant/account scope, or naming choices are central to the decision.
- Use concrete scenarios to clarify edge cases, permissions, states, lifecycle, ownership, and failure behavior.
- Walk the decision tree: resolve upstream choices before downstream details.
- Do not fill unknown requirements with optimistic assumptions; mark them as unknown and ask.
- Keep going until goal, audience, success criteria, constraints, non-goals, risks, shared language, and next workflow are clear.
- Do not implement during the grilling session.

## Documentation Capture

During the session, track candidate durable updates without writing them immediately:

- domain terms or renamed concepts
- overloaded words and preferred vocabulary
- product rules and invariants
- lifecycle/status semantics
- permissions, ownership, and tenant-scope rules
- design direction or UI contract changes
- hard-to-reverse decisions and tradeoffs
- reusable code/style patterns discovered from the repo

At the end, ask whether to propose doc updates. Do not write docs without explicit approval.

Preferred destinations:

- `.ai/domain.md` for durable vocabulary, overloaded terms, and naming guidance
- `.ai/project-context.md` for durable product, architecture, or constraint language
- `.ai/specs/<feature>/` for feature-specific decisions and contracts
- `.ai/decisions/` for ADR-like decisions that are hard to reverse, surprising, or tradeoff-heavy
- `.ai/DESIGN.md` for reusable design direction
- project styleguides for reusable coding patterns

Avoid noisy docs. If a fact is temporary, obvious, or only useful once, keep it in the session summary instead of proposing a file update.

## Finish

End with:

- Decisions confirmed
- Shared language / terms clarified
- Open questions
- Candidate doc updates, if any, with recommended destination
- Recommended next route: `feature-planner`, `human-ui-designer`, `research-brief`, `implementation-agent`, or external review/handoff
