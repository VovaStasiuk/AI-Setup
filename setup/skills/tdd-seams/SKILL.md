---
name: tdd-seams
description: Guide test-first implementation through public seams. Use when implementing features or bug fixes with tests, choosing where tests should live, avoiding implementation-coupled or tautological tests, or running a red-green vertical-slice loop.
---

# TDD Seams

Use this as a model-invoked implementation discipline. It is not a planning workflow and does not replace `implementation-agent`.

## Core rule

Test behavior at a public seam before changing implementation.

A seam is the boundary where the system exposes behavior: an endpoint, command, component prop, service interface, reducer, parser, CLI, workflow, or other stable contract. Prefer the highest seam that proves the behavior without depending on internals.

## Flow

1. Read the source of truth: ticket, spec, bug report, failing test, or user request.
2. Identify the smallest behavior slice to prove.
3. Name the seam under test and why it is the right public boundary.
4. If the seam choice is uncertain or expensive, ask before writing the test.
5. Write one failing check at that seam, or state why a test-first check is not practical.
6. Implement only enough code to pass that check.
7. Run the focused check.
8. Repeat for the next vertical slice.

## Good tests

- Verify observable behavior, not private implementation details.
- Use expected values from the spec, fixture, worked example, or externally visible contract.
- Stay stable when internal structure is refactored.
- Fail for the bug or missing behavior they claim to cover.
- Have names that use project domain language from `.ai/domain.md` when available.

## Anti-patterns

- Implementation-coupled: mocks private collaborators, tests private helpers, or asserts internal call order when behavior is unchanged.
- Tautological: recomputes the expected value the same way the implementation does, so the test cannot disagree with the code.
- Over-broad: starts with a full suite or many imagined cases before the first behavior is understood.
- Horizontal: writes all tests first, then all implementation. Work one behavior slice at a time.
- Snapshot-only: stores a large snapshot with no clear behavioral assertion.

## When not to write a test first

It is acceptable to skip test-first work when:

- the change is pure documentation or configuration with no executable behavior;
- the repo has no runnable test harness and creating one is out of scope;
- the useful seam requires external services the current environment cannot run;
- the user explicitly asks for a spike/prototype.

When skipping, state the reason and choose the narrowest meaningful verification instead.

## Output

When used explicitly, report:

- Source of truth.
- Chosen seam.
- First failing check or skipped-test reason.
- Focused verification command.
- Next slice, if any.
