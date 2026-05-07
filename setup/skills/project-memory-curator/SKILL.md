---
name: project-memory-curator
description: Capture durable project knowledge into the right project files only after evidence and user approval. Use when an agent discovers reusable patterns, commands, gotchas, architecture decisions, design rules, testing rules, security constraints, or project conventions that would save future planning/implementation/review time.
---

# Project Memory Curator

Use this to propose durable project knowledge updates. Do not silently write memory or styleguide changes.

## Capture only if durable

Good candidates:

- repeated code patterns or helper usage
- repeated delivery patterns, such as preferred full-stack vertical slice sequencing
- verified commands and test procedures
- project-specific architecture or domain facts
- security, tenancy, permissions, or data-integrity constraints
- design rules and UI anti-patterns
- coding standards observed across the repo
- production gotchas or known failure modes

Do not capture:

- one-off bug details
- speculative guesses
- temporary TODOs
- personal chat context
- vague notes without evidence
- rules contradicted by nearby code

## Proposal format

Before editing, ask with:

- Finding: the reusable knowledge
- Evidence: files, commands, or examples where observed
- Destination: exact file and section
- Proposed text: short wording to add
- Value: why this saves future time/tokens or prevents mistakes
- Staleness risk: when this note should be revisited

If evidence is weak, do not propose a permanent rule. Suggest a temporary note or ask for more verification.

## Destination guide

- `.ai/commands.md` for verified commands and environment rules.
- `.ai/project-context.md` for architecture/domain facts.
- `.ai/DESIGN.md` for visual/product UI rules.
- `.ai/decisions/` for durable architecture/product decisions.
- `.ai/specs/<feature>/` for feature-specific context.
- Project styleguides for repeated coding patterns and standards.

## Writing rules

- Write concise, sourced notes.
- Prefer updating an existing section over creating a new file.
- Do not duplicate the same rule in multiple places unless one file is an index.
- If the right destination is unclear, ask.
