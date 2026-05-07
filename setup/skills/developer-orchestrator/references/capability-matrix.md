# Capability Matrix

## Planning

- Claude + Superpowers: best for large, vague, collaborative product/spec planning.
- Custom `feature-planner`: best for Codex sessions, smaller features, or when Superpowers is unavailable.
- Codex: best for adversarial plan review and feasibility critique.
- Gemini: useful before planning when the input is huge, multimedia, or whole-repo context.

## Implementation

- Codex: strong for repo-grounded edits, tests, reviews, and patch discipline.
- Claude + Superpowers execution: strong when a Superpowers plan exists and Claude Code is the active workspace.
- Project skills override global defaults for framework-specific work.

## Review

- Codex: default adversarial reviewer for code, plans, risky paths, and agent self-review.
- Claude: acceptable for explaining code or reviewing user-authored non-code prose.
- Gemini: useful for huge diffs/docs only when long context matters more than patch-level precision.

## Design

- Project `DESIGN.md`, `.ai/DESIGN.md`, styleguide, and existing UI are authoritative.
- `human-ui-designer` runs the workflow and design-source gate.
- `pencil-design` handles Pencil MCP and `.pen` files after design direction is established.
- UI/UX Pro Max, awesome-design-md, Open Design, Pencil, Figma, and imagegen are optional helpers.

## Image Generation

- Codex imagegen: preferred for raster PNG/JPG/WebP generation and image edits when available.
- Claude: cannot assume direct raster image generation; route to Codex imagegen when available.
- Pencil/Figma/SVG/HTML: fallback for vector, UI mockups, or code-native assets.
- External prompt: fallback when no local image-generation route is available.

## Research

- Current docs/web are required for facts that may have changed.
- Gemini is useful for long documents and media.
- Claude/Codex synthesize findings into decisions, plans, or implementation tasks.

## Communication

- `concise-communication` or Caveman-lite is optional for brevity.
- Do not compress away important risk, nuance, or implementation detail.
