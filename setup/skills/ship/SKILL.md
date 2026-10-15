---
name: ship
description: "Use when implementation looks finished and the work needs to be verified, reviewed and closed: lint, build, tests, review, browser check, commit message, ticket note. Never commits unless the user asks."
---

# Ship

Close a piece of work with evidence. Run each step that applies, record the result, and say plainly what was skipped.

## Steps

1. **Lint and format:** run the project's lint on the touched files.
2. **Build and types:** run the build or type check if the project has one.
3. **Tests:** run the narrowest tests that cover the change (see `tdd-seams`), then wider ones only if the blast radius needs it.
4. **Review:** use `code-review-swe` on the diff against the spec or ticket. Use an independent reviewer (for example Codex) when available for risky changes.
5. **Browser check:** for UI changes, open the page, exercise the changed flow and check the console. Use `human-ui-designer` for visual quality.
6. **Commit message:** write one from the staged diff. Do not run `git commit`, `git push` or switch branches unless the user asked.
7. **Ticket note:** post or draft a short note with what changed and how it was verified (see `ticket`).
8. **State:** update `.ai/work/<slug>/state.md` per `engineering-baseline/references/workflow-state.md`: `stage: close` when done, otherwise the stage that remains and `next:`.

## Report

- Done: what was changed.
- Verified: each command or check actually run, with the result.
- Not run / skipped: each step above that did not run, why, and the risk.
- Next: only if something remains.

Never say "done" with an open step that is not listed under Not run.
