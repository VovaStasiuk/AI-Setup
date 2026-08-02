---
name: implementation-agent
description: Implement approved plans or direct coding tasks end to end. Choose between Claude Superpowers execution, Codex/custom implementation, or cross-agent handoff. Use for scoped code changes, tests, fixes, refactors, and feature implementation after the plan or target is clear.
---

# Implementation Agent

Use `engineering-baseline` first. Use `developer-orchestrator` when another model/tool may be better.

## Flow

1. Identify the source of truth: user request, issue, spec, plan, or failing test.
2. Inspect project instructions, commands, existing code, and tests.
3. If the work is too broad for one focused pass, route to `to-spec` or `to-tickets` before editing.
4. For non-trivial executable behavior, use `tdd-seams`: identify the public seam, write or name the focused failing check, then implement one vertical slice.
5. Recommend an execution route and ask when more than one major route is available.
6. Implement in small scoped changes.
7. Run the narrowest meaningful verification, then broader checks if risk warrants it.
8. Summarize behavior changed, files touched, checks run, and remaining risk.
9. If implementation reveals a reusable project pattern or command gotcha, propose a `project-memory-curator` update with evidence.

## Code comment discipline

- Prefer clear names, small functions, types, and tests over explanatory comments.
- Use a code comment only when the code cannot clearly express a stable, non-obvious reason, invariant, external constraint, or safety requirement.
- Keep implementation comments to one short sentence when possible and no more than two short lines in normal cases.
- Do not leave investigation history, bug narratives, before/after explanations, or change logs in code comments.
- Do not restate the code or document how the agent discovered the fix. Put that context in the final summary, issue, spec, or decision record.
- Before finishing, review every comment added or substantially changed and remove or shorten anything that does not protect a future maintainer from a likely misunderstanding or unsafe edit.

For example, prefer `# Let the database enforce expression-based uniqueness; field validation still runs.` over a multi-line account of why the failing path was discovered. Keep longer inline documentation only when a public API, project convention, legal requirement, or safety-critical constraint genuinely requires it.

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
