---
name: feature-planner
description: Plan new features, large changes, refactors, migrations, and product workflows. Picks Claude Superpowers planning or the custom lightweight planner without asking, unless the user wants to choose. Produce decision-complete specs/plans with success criteria, assumptions, risks, implementation shape, and tests.
---

# Feature Planner

Use `engineering-baseline` first.

Challenge weak ideas before turning them into plans. Call out overengineering, vague requirements, missing production concerns, and bad tradeoffs directly.

## Flow

1. Inspect project instructions and relevant context before asking discoverable questions.
2. Clarify goal, users, success criteria, constraints, scope, and non-goals.
3. Pick the planning route without asking, unless the user wants to choose:
   - Superpowers brainstorming/writing-plans for large/vague Claude Code work.
   - Custom lightweight plan for Codex, small/medium tasks, or unavailable Superpowers.
   - Custom plan + Codex review for high-risk or important decisions.
4. Produce the chosen output:
   - Product/spec plan when intent is still being shaped.
   - Implementation plan when requirements are already stable.
5. Include acceptance criteria and verification steps.

## Guardrails

- Do not over-plan tiny changes.
- Do not invent project facts; inspect or mark assumptions.
- Do not present assumptions as requirements.
- For product work spanning backend and frontend, prefer user-verifiable vertical slices over building all backend first and all frontend later.
- Use horizontal phases only when a real dependency requires it, such as externally defined API contracts, risky schema/auth foundations, or shared platform work.
- Split independent subsystems into separate plans.
- If the finished plan is too large for one implementation pass, route to `to-spec` and `to-tickets` before implementation.
- Project files and existing code patterns override generic preferences.
- If planning reveals durable architecture, command, or domain knowledge, propose a `project-memory-curator` update instead of leaving it only in chat.

## Slice planning

For full-stack features, organize the plan as thin end-to-end workflows:

- Slice 1: smallest read/list or first useful user path.
- Slice 2: detail or drill-in path.
- Slice 3: create/edit workflow.
- Slice 4: destructive, advanced, or edge workflows.

Each slice should include only the backend, frontend, state handling, tests, and verification needed to prove that workflow.

## Planning completion

A plan is not complete until it states:

- included scope
- excluded scope
- assumptions
- verification strategy
- user-visible acceptance criteria
- known risks or unresolved questions

## Workflow state

Read the work item's state file at the start and, at the end, set `stage`, `done` and `next` as described in `engineering-baseline/references/workflow-state.md`.
