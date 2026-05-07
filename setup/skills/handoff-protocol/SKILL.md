---
name: handoff-protocol
description: Create structured handoffs between Claude, Codex, Gemini, and other agents/tools. Use when one agent plans and another implements, one agent implements and another reviews, or work must continue in a new session without losing context.
---

# Handoff Protocol

Use this whenever another agent/tool/session needs to continue work.

## Handoff packet

Include:

- Goal and current status
- Relevant project instructions and constraints
- Files/areas in scope
- Decisions already made
- Commands run and results
- Known risks, failed attempts, and open questions
- Exact ask for the receiving agent/tool

## Review handoff

For review, include:

- What changed or what plan should be reviewed
- Risk areas to focus on
- Tests expected to cover the work
- What counts as a blocking finding

## Implementation handoff

For implementation, include:

- Plan/spec link or summary
- Acceptance criteria
- Implementation boundaries
- Verification commands
- Required output format

For full-stack work, include the next vertical slice only unless the receiving agent explicitly needs the whole plan for context.

## Imagegen handoff

When Claude hands image generation to Codex, include:

- Exact image request and intended use.
- Required format: PNG/JPG/WebP, size/aspect ratio if known, transparent background if needed.
- Style constraints from `DESIGN.md` or user references.
- What not to include.
- Expected output: generated image asset/path or a clear statement if imagegen is unavailable.
