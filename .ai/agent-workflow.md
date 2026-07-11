# Agent Workflow

This repo uses a portable Claude + Codex workflow.

## Main Flow

```text
grill-with-context -> to-spec -> to-tickets -> implementation-agent -> code-review-swe
```

Use `/ai-workflow` when the right route is unclear.

## Artifacts

- Specs: `.ai/specs/`
- Tickets: `.ai/tickets/`
- Decisions: `.ai/decisions/`
- Domain language: `.ai/domain.md`
- Issue tracker rules: `.ai/issue-tracker.md`

## Local Rules

- Keep global skills reusable and project-neutral.
- Put project facts in `.ai/` files.
- Use local Markdown tickets unless an external tracker is explicitly configured.
- For executable behavior, use `tdd-seams` inside implementation to choose the public seam and focused verification.
