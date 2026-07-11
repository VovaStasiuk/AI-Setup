---
name: to-spec
description: Turn the current conversation, plan, or clarified feature request into a decision-complete spec. Use when requirements are already discussed and the next step is a stable spec, not another interview.
---

# To Spec

Use `engineering-baseline` first. If the request is still vague, route to `grill-with-context` or `feature-planner` before writing a spec.

## Inputs

Inspect, when available:

- Current conversation or user-provided plan.
- `AGENTS.md`, `CLAUDE.md`, `.ai/agent-workflow.md`, `.ai/domain.md`, `.ai/project-context.md`, `.ai/tech-stack.md`, and `.ai/commands.md`.
- Relevant docs, existing specs, decisions, tests, and code paths.

Do not invent requirements. Mark uncertain details as assumptions or open questions.

## Flow

1. Identify the problem, users, goal, and source of truth.
2. Inspect the project enough to use correct terminology and avoid stale architecture claims.
3. Capture implementation decisions already made in the conversation.
4. Capture testing decisions, including the public seams or workflows that should be verified by `tdd-seams` during implementation.
5. Write the spec to the configured destination from `.ai/agent-workflow.md` when the user asks you to persist it.
6. If no destination is configured, default to `.ai/specs/` for local specs and ask before writing.

Do not interview the user unless a missing decision would materially change the spec.

## Spec format

Use this structure:

```markdown
# <Feature Or Change Name>

## Problem

## Goal

## Users / Actors

## Scope

## Out Of Scope

## User Stories

## Implementation Decisions

## Testing Decisions

## Acceptance Criteria

## Assumptions

## Open Questions

## Next Step
```

## Output

Return:

1. Spec draft or path written.
2. Assumptions and open questions.
3. Recommended next command, usually `/to-tickets` for multi-session work or `/implement` for small work.
