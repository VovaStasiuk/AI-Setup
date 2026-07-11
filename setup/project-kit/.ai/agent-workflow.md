# Agent Workflow

This file tells AI agents how work moves from idea to implementation in this repo.

## Main Flow

Use this path for most product or engineering changes:

```text
grill-with-context -> to-spec -> to-tickets -> implement -> review-code
```

Skip steps only when the work is already small and clear.

## Artifacts

- Specs: `.ai/specs/`
- Tickets: `.ai/tickets/`
- Durable decisions: `.ai/decisions/`
- Domain language: `.ai/domain.md`
- Issue tracker rules: `.ai/issue-tracker.md`

## Ticket Rules

- Prefer vertical, user-verifiable slices.
- Every ticket should list blockers or say `None`.
- Work frontier tickets first: tickets whose blockers are complete.
- Use `/implement` for one ticket at a time.
- For executable behavior, identify the public test seam before writing tests.
- Use `/review-code` before merging important or risky work.

## Human Gates

Ask before:

- writing to external issue trackers
- changing auth, billing, infrastructure, migrations, secrets, or deployment
- using destructive commands
- replacing existing project instructions
