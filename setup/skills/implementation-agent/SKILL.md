---
name: implementation-agent
description: Implement approved plans or direct coding tasks end to end. Choose between Claude Superpowers execution, Codex/custom implementation, or cross-agent handoff. Use for scoped code changes, tests, fixes, refactors, and feature implementation after the plan or target is clear.
---

# Implementation Agent

Use `engineering-baseline` first.

## Flow

1. Identify the source of truth: user request, issue, spec, plan, or failing test.
2. Inspect project instructions, commands, existing code, and tests.
3. If the work is too broad for one focused pass, route to `to-spec` or `to-tickets` before editing.
4. For non-trivial executable behavior, use `tdd-seams`: identify the public seam, write or name the focused failing check, then implement one vertical slice.
5. Pick the execution route yourself; ask only before handing the work to another model or tool.
6. Implement in small scoped changes.
7. Run the narrowest meaningful verification, then broader checks if risk warrants it.
8. Summarize behavior changed, files touched, checks run, and remaining risk.
9. If implementation reveals a reusable project pattern or command gotcha, propose a `project-memory-curator` update with evidence.

After frontend or browser-facing changes, check the result with the browser tools that are available (`chrome-devtools-mcp` when installed, Claude in Chrome, the built-in browser, or Playwright), including console and network output when that evidence matters. Use existing browser tests for simpler checks. Never attach to a personal or production-authenticated browser profile without explicit approval.

## Code comment discipline

- Default to no new comment. Prefer clear names, a small helper, a type, an assertion, or a regression test.
- Make the final code read as if the correct implementation was written first.
- When correcting your own implementation, delete comments that explain the failed attempt, the correction, or why the previous version was wrong.
- Do not leave investigation history, bug narratives, before/after explanations, or change logs in code comments.
- Describe only the current invariant. Do not write retrospective phrases such as "previously," "now," "this fixes," or "we tried."
- Never make a comment block longer than the code it explains. A single statement gets at most one short comment line.
- Use a code comment only when the code cannot clearly express a stable, non-obvious reason, invariant, external constraint, or safety requirement.
- Put defect history and discovery details in a regression-test name, final summary, issue, spec, or decision record—not beside the implementation.
- Before finishing, review every comment added or substantially changed and remove or shorten anything that does not protect a future maintainer from a likely misunderstanding or unsafe edit.

Treat comments written while debugging as temporary. If a necessary explanation cannot fit within the size limit, improve the code structure or link to a durable issue or decision instead of embedding the narrative.

Do not say tests/build/lint pass unless they were run and passed. If checks were skipped or failed, report that directly.
If test-first work was skipped, state why and what verification replaced it.

## Completion contract

Before final response, check the requested scope against actual changes.

For every non-trivial implementation, perform a local final review pass:

- Compare actual changes against the user request and plan.
- Re-read changed files or inspect the diff when available.
- Check for obvious regressions, missing states, missing tests, and incomplete scope.
- Decide whether external/adversarial review is needed for risk, size, uncertainty, or sensitive areas.

Report:

- Completed: implemented behavior and important files.
- Verified: exact checks run and results.
- Not done / skipped: skipped tests, screenshots, edge cases, migrations, docs, or integrations with reason and risk.
- Next step: required follow-up if the task is not fully complete.

Do not call the task done if any required scope remains unimplemented.

## Routes

- Use Superpowers execution when a Superpowers plan exists and Claude Code is active.
- Use Codex/custom implementation for repo-grounded edits, tests, and patch discipline.
- Use handoff-protocol when another agent should review, rescue, or continue.

## Full-stack delivery

For features spanning backend and frontend, implement vertical slices by default:

1. Choose the user-verifiable workflow slice.
2. Identify the highest practical seam that proves that slice.
3. Add or name the focused failing check at that seam when feasible.
4. Build the smallest backend contract needed for the slice.
5. Build the frontend path that consumes it.
6. Include loading, empty, error, and basic permission/state handling needed for that slice.
7. Verify the slice end-to-end before starting the next slice.
8. Ask for direction check when the product behavior or UI could drift.

Do not build all APIs first unless the plan documents why a horizontal backend-first phase is necessary.

## Workflow state

Read the work item's state file at the start and, at the end, set `stage`, `done` and `next` as described in `engineering-baseline/references/workflow-state.md`.
