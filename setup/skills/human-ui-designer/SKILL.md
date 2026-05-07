---
name: human-ui-designer
description: Design and implement product UI that follows project visual direction instead of guessing. Use for new screens, redesigns, UI polish, design critique, generated mockups, and "make this not look AI-generated" requests. Enforces a design-source gate, creates a design contract before coding, and verifies implementation with screenshots when practical.
---

# Human UI Designer

Use `engineering-baseline` first. This is a workflow skill, not a design system. Project design sources are authoritative.

## Design-source gate

Before designing or coding UI, search for:

- `DESIGN.md`
- `.ai/DESIGN.md`
- `.ai/styleguide.md`
- `AGENTS.md` / `CLAUDE.md`
- existing components, pages, screenshots, Storybook, tokens, Tailwind/theme config
- project-local frontend/design skills

If the source is clear, summarize the relevant constraints and proceed.

If the source is missing, weak, or conflicting, do not guess. Ask whether to create:

- project-level `DESIGN.md`
- feature-level `.ai/specs/<feature>/DESIGN.md`
- a design from existing UI only
- a design from user-provided references/screenshots
- a theme discovery pass using reference DESIGN.md collections such as getdesign.md or awesome-design-md

## Design contract before coding

For UI-heavy work, produce or update a contract covering:

- audience and workflow
- visual direction and density
- layout, spacing, typography, and color roles
- component choices and interaction states
- loading, empty, error, disabled, and responsive states
- explicit anti-patterns to avoid

## Theme discovery

Use this when the user asks for color palette, typography, theme direction, visual identity, or when no reliable design source exists.

1. Ask for product type, audience, workflow density, and any references/anti-references.
2. Offer 3-5 visual directions inspired by reference collections such as getdesign.md or awesome-design-md.
3. For each direction, include:
   - intended product fit
   - palette direction
   - typography direction
   - layout density
   - component feel
   - what to avoid
4. Recommend one direction with reasoning.
5. Ask the user to choose, reject, or combine directions.
6. Convert the chosen direction into concrete `DESIGN.md` rules before coding.

Do not copy a brand blindly. Translate references into constraints appropriate for the user's product.

## Tool use

UI/UX Pro Max, awesome-design-md, Open Design, Pencil, Figma, and imagegen are optional references/tools. They are not the source of truth unless the user or project says so.

Use `pencil-design` when the task mentions Pencil, `.pen` files, Pencil MCP, editable UI mockups, or design-to-code from a Pencil document. Keep product taste and project visual direction in this skill's design contract; use `pencil-design` for the Pencil-specific tool workflow.

For raster image assets, prefer Codex imagegen when available. In Claude, do not assume imagegen is a local CLI; route through Codex/imagegen or fall back to SVG/Pencil/Figma/external prompt.

## Verification

After implementation, verify with screenshots when practical. Compare the result to the contract and fix visible drift.

For detailed DESIGN.md templates, read `references/design-md-template.md`.

## Design completion

For UI/design work, final response should state:

- Design contract followed.
- Screenshots/viewports checked.
- States checked: loading, empty, error, disabled, success where relevant.
- Not checked: viewports, browsers, data states, accessibility, or interactions not verified.
- Visible drift or remaining polish.
