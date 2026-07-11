# Agent Instructions

Project instructions override global skills. Read this file first, then load only the linked files needed for the task.

## Project context

- Architecture and domain: `.ai/project-context.md`, `.ai/domain.md`
- Workflow and tracker rules: `.ai/agent-workflow.md`, `.ai/issue-tracker.md`
- Tech stack and commands: `.ai/tech-stack.md`, `.ai/commands.md`
- Visual design: `.ai/DESIGN.md`, `.ai/styleguide.md`
- Specs, tickets, and decisions: `.ai/specs/`, `.ai/tickets/`, `.ai/decisions/`

## Working rules

- Use existing project patterns before introducing new ones.
- Keep changes scoped to the request.
- Verify with the narrowest meaningful test/check.
- If design direction is unclear, ask before guessing.
- For vague features or product/design decisions, use global `grill-with-context`
  before planning and ask before writing project doc updates.
- Use `domain-modeling` when terms, lifecycle states, ownership, or scope
  language are ambiguous.
- For multi-step feature work, use `to-spec` to create a stable spec and
  `to-tickets` to split it into blocked implementation tickets.
- For executable behavior, identify the public test seam before writing tests.
