---
name: code-review-swe
description: Perform senior software-engineering review of code, diffs, plans, and implementations. Use for PR review, adversarial review, self-review replacement, pre-merge checks, and fixed-point reviews that compare a diff against both project standards and the originating spec or ticket.
---

# Code Review SWE

Use `engineering-baseline` first. Prefer an external model/tool for agent-authored critical work when available.

## Review setup

For serious code reviews, pin the fixed point before reviewing:

- user-supplied branch, commit, tag, or merge-base;
- PR base branch;
- `git diff` for uncommitted working-tree review when the user explicitly wants current local changes.

If the fixed point is unclear and materially changes the diff, ask. If the diff is empty, say so and stop.

Find the source of truth for the work when available:

1. User-provided spec, ticket, PRD, or plan.
2. References in branch name, commit messages, PR body, or ticket links.
3. `.ai/specs/` and `.ai/tickets/`.
4. Current conversation.

If there is no spec/ticket, run the Standards axis and report that the Spec axis is limited.

## Review stance

- Findings first, ordered by severity.
- Focus on correctness, regressions, security, data integrity, performance, UX breakage, and missing tests.
- Anchor each finding to concrete evidence.
- Avoid broad style notes unless they create a real risk.
- Do not soften production risks or praise changes before findings.
- If no findings, say so and name test gaps or uncertainty.
- If review reveals a reusable project rule or repeated failure pattern, suggest a `project-memory-curator` update after the findings.

## Two-axis review

Keep these axes separate so one cannot hide the other:

### Spec axis

Check whether the diff faithfully implements the source of truth:

- required behavior missing or partial;
- behavior added that was not requested;
- acceptance criteria not covered;
- test seam or verification missing for risky behavior;
- assumptions in the implementation that conflict with the spec/ticket.

### Standards axis

Check whether the diff follows project standards:

- `AGENTS.md`, `CLAUDE.md`, `.ai/`, styleguides, contributing docs, and nearby code patterns;
- security, privacy, performance, accessibility, and migration expectations;
- local command/test conventions;
- baseline code-smell heuristics below when project docs are silent.

Project-specific standards override the baseline. Treat baseline smells as judgment calls, not hard violations.

Baseline smells to consider:

- Unclear name: name does not reveal intent or domain meaning.
- Duplicate logic: the same decision or algorithm shape appears in multiple places.
- Feature envy: code reaches deeply into another object/module instead of asking a clear interface.
- Data clump: related fields travel together repeatedly but have no named concept.
- Primitive obsession: string/number/bool stands in for a domain concept that needs a type or value object.
- Repeated branching: similar conditionals on the same concept are scattered across the change.
- Shotgun surgery: one logical change requires many scattered edits.
- Divergent change: one module is edited for unrelated reasons.
- Speculative generality: abstraction/configuration added without a current requirement.
- Message chain: caller navigates through several objects/modules it should not know.
- Middleman: wrapper adds no policy, naming value, or simplification.

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
- Fixed point: comparison target or working-tree scope.
- Spec source: spec/ticket/plan used, or `None found`.
- Not reviewed: missing files, call sites, runtime behavior, tests, screenshots, or deployment concerns not inspected.
- Residual risk: what could still be wrong because it was outside coverage.

## Output

Use this shape:

1. Findings
2. Spec axis
3. Standards axis
4. Open questions or assumptions
5. Test gaps / residual risk
6. Short change summary only if useful
