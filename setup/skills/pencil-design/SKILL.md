---
name: pencil-design
description: Use Pencil MCP and .pen files for reusable UI mockups, design-to-code handoff, visual iteration, and design system exploration. Trigger when the task mentions Pencil, .pen files, Pencil MCP tools, mockup export, or translating a Pencil design into implementation. Keep project visual direction in project DESIGN.md files; this skill only covers the generic Pencil workflow.
---

# Pencil Design

Use `engineering-baseline` first. Use `human-ui-designer` before this skill for product/UI direction, design-source gates, and design contracts. This skill is the generic Pencil workflow; project design rules remain in `.ai/DESIGN.md`, `.ai/design/`, project styleguides, screenshots, and component docs.

## When to use Pencil

Use Pencil when the task needs:

- a `.pen` file created, inspected, or updated
- a UI mockup that should preserve editable design structure
- design-system exploration before code
- design-to-code handoff from a visual source
- exportable nodes/assets from an existing Pencil document
- iteration on layout, component reuse, tokens, spacing, or responsive artboards

Do not force Pencil when:

- the project already has authoritative Figma/design files and the user wants those used
- the task is a simple code-native UI change
- the output is a raster illustration/photo; prefer imagegen when available
- no Pencil MCP/tool route is available and a faster fallback is acceptable

## Availability check

Do not assume Pencil is installed. Check the active tool list, MCP tools, project instructions, or user-provided environment notes. If unavailable, explain briefly and offer the best fallback:

- Figma route when Figma is available and authoritative
- imagegen for raster assets/mockups
- HTML/CSS/React prototype
- SVG/vector asset
- external prompt or handoff

## Workflow

1. Load project design sources through `human-ui-designer`.
2. Confirm the task target: new mockup, edit existing `.pen`, export, or design-to-code.
3. Inspect the current Pencil document before changing it.
4. Reuse existing components, tokens, variables, images, and logos when present.
5. Build or update one section/artboard at a time.
6. Verify each section visually with screenshot/layout inspection when tools allow.
7. For implementation handoff, map design tokens and reusable components to project code conventions.
8. State what was verified and what remains unverified.

## Design rules

- Project design direction is authoritative. Do not invent a style when `.ai/DESIGN.md`, screenshots, tokens, or existing UI are unclear; ask or create a design contract first.
- Prefer reusable components over recreated shapes.
- Prefer semantic tokens/variables over hardcoded colors, spacing, typography, or radii.
- Avoid arbitrary Tailwind values in generated code when semantic project tokens/classes exist.
- Check for text overflow, clipping, bad wrapping, and overlapping elements on desktop and mobile artboards.
- Reuse existing logos/icons/images from the document or project assets before generating replacements.
- Keep `.pen` locations and naming project-specific; do not encode project paths in this global skill.

## Design-to-code handoff

When translating Pencil to code, include:

- source `.pen` file and node/artboard names
- screenshots or exported assets used
- design tokens and component mappings
- responsive behavior and breakpoints
- interaction states: hover, focus, disabled, loading, empty, error, success
- project files/components likely to change
- visual risks or unknowns

Generated code must follow project styleguides and existing components. Pencil output is design input, not permission to ignore the codebase.

## Completion

Final response should state:

- Pencil route used or fallback chosen.
- Source design files/nodes inspected.
- Components/tokens reused.
- Screenshots/layout checks performed.
- Exports or implementation handoff produced.
- Anything not verified because tools or source files were unavailable.
