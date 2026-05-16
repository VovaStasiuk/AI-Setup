---
name: code-review-swe
description: Perform senior software-engineering review of code, diffs, plans, and implementations. Lead with bugs, regressions, missing tests, security/performance risks, and concrete file/line findings. Use for PR review, adversarial review, self-review replacement, and pre-merge checks.
---

# Code Review SWE

Use `engineering-baseline` first. Prefer an external model/tool for agent-authored critical work when available.

## Review stance

- Findings first, ordered by severity.
- Focus on correctness, regressions, security, data integrity, performance, UX breakage, and missing tests.
- Anchor each finding to concrete evidence.
- Avoid broad style notes unless they create a real risk.
- Do not soften production risks or praise changes before findings.
- If no findings, say so and name test gaps or uncertainty.
- If review reveals a reusable project rule or repeated failure pattern, suggest a `project-memory-curator` update after the findings.

For UI/frontend diffs, include a design review lens when relevant:

- Did the change follow project `DESIGN.md` or another declared design source?
- Did it reuse project primitives, tokens, and nearby patterns?
- Does it fit visually next to existing screens?
- Are loading, empty, error, disabled, permission, overflow, and responsive states handled when relevant?
- Was screenshot verification done, or is it listed as not reviewed?

Do not invent findings. If evidence is insufficient, ask for the diff/files/tests or state the review is limited.

## Review completion

Always state review coverage:

- Reviewed: files, diff, plan, or behavior actually inspected.
- Not reviewed: missing files, call sites, runtime behavior, tests, screenshots, or deployment concerns not inspected.
- Residual risk: what could still be wrong because it was outside coverage.

## Output

Use this shape:

1. Findings
2. Open questions or assumptions
3. Test gaps / residual risk
4. Short change summary only if useful
