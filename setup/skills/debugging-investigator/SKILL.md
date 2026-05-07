---
name: debugging-investigator
description: Investigate errors, failing commands, stack traces, logs, test failures, and user-pasted console output without guessing. Use when the user reports a bug, pastes an error, says something is broken, or asks why a failure happened. Ground conclusions in the provided output and repo evidence.
---

# Debugging Investigator

Use `engineering-baseline` first. Treat pasted errors as evidence, not as a complete diagnosis.

## Rules

- Do not invent missing logs, files, commands, versions, or root causes.
- Do not claim a fix worked unless it was actually verified.
- Preserve exact error text, command, file path, line number, environment, and timing when available.
- If the error is incomplete, ask for the missing high-value detail or inspect the repo for it.
- Separate observations, hypotheses, tests, and conclusions.
- Prefer reproducing the failure or finding the relevant code path before editing.
- If two attempts fail with the same error, route to rescue/review when available.

## Flow

1. Restate the concrete failure from the evidence.
2. Identify likely layer: environment, dependency, command usage, app code, data, config, network, auth, permissions, build, test.
3. Inspect relevant files/configs before proposing broad fixes.
4. Form 1-3 hypotheses with evidence for/against each.
5. Pick the cheapest next verification step.
6. Fix only after the cause is sufficiently grounded.
7. Verify and state what remains unverified.

## Output

- Evidence observed
- Most likely cause
- What I checked
- Fix or next diagnostic step
- Verification result / not verified

Do not call an issue fixed until the failing case or a relevant substitute check has passed. If only a hypothesis was produced, label it as a hypothesis.
