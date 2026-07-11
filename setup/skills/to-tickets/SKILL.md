---
name: to-tickets
description: Break a spec, plan, PRD, backlog, or broad implementation request into small tracer-bullet tickets with blocking edges. Use after planning/spec work when implementation should be split across focused agent sessions or humans.
---

# To Tickets

Use `engineering-baseline` first. If requirements are not stable, use `grill-with-context`, `feature-planner`, or `to-spec` before ticketing.

## Inputs

Inspect the source of truth before writing tickets:

- Current conversation, spec, plan, PRD, issue, or `.ai/specs/` document.
- `.ai/agent-workflow.md`, `.ai/issue-tracker.md`, `.ai/domain.md`, `.ai/commands.md`, `.ai/tech-stack.md`, and relevant project docs.
- Optional tracker templates, labels, priorities, or ownership rules when already configured.

Do not create external tracker tickets unless the user explicitly asks and the required tool or connector is available.

## Flow

1. Identify the source, assumptions, unresolved decisions, and configured ticket destination.
2. If core requirements are still ambiguous, route back to `grill-with-context`, `feature-planner`, or `to-spec`.
3. Draft tracer-bullet vertical slices: each ticket delivers a narrow but complete verifiable behavior.
4. Add blocking edges: every ticket lists the tickets that must finish before it can start.
5. Present the proposed breakdown and ask whether granularity and blockers are right before writing.
6. Write tickets to the configured destination when approved. If no destination is configured, default to one Markdown file per ticket under `.ai/tickets/`.
7. Work the frontier: any ticket with all blockers done can be implemented next.

## Slicing rules

- Prefer outcome titles such as "User can invite a teammate" over layer titles such as "Add invite API".
- Do not create separate frontend/backend tickets unless a real dependency requires it.
- A completed ticket should be demoable or verifiable on its own.
- Keep each ticket small enough for one focused agent session and one review pass.
- Pull risky auth, billing, migration, infrastructure, or security work into explicit review-gated tickets.
- Include tests, docs, migrations, loading/error states, and follow-up memory updates inside the ticket that needs them.
- If the work is already smaller than one ticket, say so and recommend direct `implementation-agent` execution.
- Mark speculative or unverified requirements as assumptions, not acceptance criteria.

## Wide refactors

Wide refactors are the exception to vertical slicing. A wide refactor is one mechanical change whose blast radius touches many call sites, such as renaming a shared symbol, changing a column, or retyping a shared API.

Use expand-contract:

1. Expand: add the new form beside the old so existing callers still work.
2. Migrate: move call sites in batches sized by blast radius, such as by package, directory, or workflow.
3. Contract: remove the old form after every migration batch is complete.

If batches cannot stay green independently, make them integration-branch tickets that all block one final integrate-and-verify ticket.

## Ticket format

For each ticket, include:

- Title.
- What to build: user-visible behavior or concrete technical outcome.
- Blocked by: ticket titles or "None".
- Scope.
- Out of scope.
- Acceptance criteria.
- Implementation notes.
- Verification commands or checks.
- Test seam: public boundary to verify, or `Not applicable` with reason.
- Risks or review focus.
- Suggested route, usually `/implement` then `/review-code`.

## Local Markdown output

When writing local tickets, create one file per ticket:

```text
.ai/tickets/01-short-kebab-title.md
.ai/tickets/02-next-short-kebab-title.md
```

Number tickets in dependency order with blockers first. Use lower-case kebab-case after the number. Do not write one combined ticket file unless the user explicitly asks.

Use this body:

```markdown
# <Ticket Title>

## What To Build

## Blocked By

None.

## Scope

## Out Of Scope

## Acceptance Criteria

- [ ] Criterion

## Test Seam

Public boundary to verify, or `Not applicable` with reason.

## Verification

## Implementation Notes

## Review Focus

## Suggested Route

`/implement`, then `/review-code`.
```

## Output

Return:

1. Source and assumptions.
2. Ordered ticket list with blockers.
3. Frontier tickets that can start immediately.
4. Blockers or questions.
5. Suggested next command or prompt for the first frontier ticket.

If the user asks for tracker-ready output, format each ticket as a standalone Markdown ticket body.
