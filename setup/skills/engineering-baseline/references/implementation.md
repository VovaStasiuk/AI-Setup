# Implementation Defaults

- Inspect existing code, tests, commands, and conventions before editing.
- Keep edits tightly scoped to the request.
- Use existing helpers/components/services before creating new ones.
- Avoid broad refactors unless required to safely finish the task.
- Leave no debugging archaeology in source comments: final code should read as if the correct implementation was written first, and a single statement gets at most one short comment line.
- Put failed-attempt and correction history in tests or the implementation summary, not beside the corrected code.
- Before editing, list every file the change touches (callers, tests, config, docs) so nothing is missed.
- Fix the root cause once, in the place all callers share, instead of patching each symptom.
- When moving or rewriting code, keep its error handling, validation, and edge-case behavior.
- Do not add a dependency for a few lines you can write and test yourself.
- Use the project's own components and helpers before native elements or new utilities.
- When two options both work, pick the one that is correct on edge cases, not the shorter one.
- Never trade away validation, security, or accessibility for brevity.
- Run focused checks first, then broader checks when the blast radius warrants it.
- Preserve unrelated user changes and do not revert work you did not make.
- Summarize changed behavior, files touched, verification, and residual risk.
