---
name: human-ui-designer
description: Design, implement, and review product UI that follows project visual direction instead of guessing. Use for new screens, websites, redesigns, UI polish, design critique, responsive behavior, interaction and motion design, generated mockups, and "make this not look AI-generated" requests. Enforces a design-source gate, uses optional design-intelligence tools only for unresolved choices, creates a design contract before coding, and verifies visual, interaction, accessibility, and motion quality when practical.
---

# Human UI Designer

Use `engineering-baseline` first. This is a workflow skill, not a design system. Project design sources are authoritative; generated recommendations are candidates, not proof of quality.

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

## Existing UI extraction

When the project has existing UI, identify 2-5 golden examples before designing:

- one nearby screen in the same feature/domain
- reusable primitives/components
- one list/table pattern when the new UI lists data
- one form/modal/drawer pattern when the new UI collects input
- one empty/loading/error state pattern when relevant

Extract the reusable rules: density, spacing, typography, color roles, borders, shadows, icon treatment, action hierarchy, and state behavior. Do not copy feature-specific content or old mockups as global style.

## Design-intelligence pass

Run this pass only when the design-source gate leaves a real choice unresolved, or when the task needs focused research such as palette, typography, landing-page structure, data visualization, accessibility, or motion. Skip broad style generation when the project already has a clear system.

1. Capture the product type, audience, workflow, platform/stack, desired tone, density, and motion intent.
2. If UI/UX Pro Max is installed, follow its local instructions and query only the relevant domains. For a new product or approved redesign, one complete design-system candidate is reasonable; for existing UI, prefer narrow searches that cannot replace local tokens or patterns.
3. If it is unavailable, evaluate the same dimensions directly. Do not block the task or invent tool output.
4. Compare every recommendation with project sources, existing dependencies, accessibility, responsive behavior, and performance.
5. Present meaningful alternatives and convert only the user's accepted direction into the design contract.

Never install or update an optional design tool, persist generated files, add a UI or motion dependency, or overwrite project design sources without confirmation. Never treat generated accessibility labels, contrast claims, or performance claims as verified results.

## Quality priority

Resolve conflicts in this order:

1. Accessibility: semantics, keyboard path, visible focus, contrast, zoom, and reduced motion.
2. Interaction: clear affordances, adequate targets, feedback, and non-hover alternatives.
3. Performance: stable layout, appropriate assets, responsive input, and non-janky motion.
4. Project fit: local components, tokens, product language, and visual continuity.
5. Responsive layout: content hierarchy, overflow, and behavior at project breakpoints.
6. Typography, color, spacing, imagery, and data visualization.
7. Decorative style and motion.

## Design contract before coding

For UI-heavy work, produce or update a contract covering:

- audience and workflow
- target platform/stack and existing UI dependencies
- visual direction and density
- design dials: restrained/balanced/expressive, spacious/standard/dense, and subtle/standard/choreographed motion
- reference priority and golden examples to follow
- layout, spacing, typography, and color roles
- component choices and interaction states
- loading, empty, error, disabled, and responsive states
- motion purpose, triggers, reduced-motion behavior, and performance limits
- accessibility and interaction acceptance checks
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

## Motion contract

Use motion to explain hierarchy, causality, state change, or spatial continuity. Do not animate merely to make the interface feel "premium."

- Choose subtle, standard, or choreographed motion and name the reason for that level.
- Define triggers, affected elements, entrance/exit behavior, interruption behavior, duration/easing ranges, and reduced-motion fallback.
- Prefer the project's current animation approach. Use CSS transitions or the Web Animations API for simple effects; use a framework library or GSAP only when it already exists or the user approves the dependency.
- Prefer `transform` and `opacity`; avoid layout-thrashing properties, scroll hijacking, long input-blocking sequences, and animation that causes layout shift.
- Keep exits no slower than entrances, make repeated interactions faster than first-time orientation, and ensure controls remain usable while motion runs.
- Under `prefers-reduced-motion`, remove non-essential movement and preserve meaning with immediate state changes, opacity, or other restrained feedback.

## Tool use

UI/UX Pro Max, awesome-design-md, Open Design, Pencil, Figma, and imagegen are optional references/tools. They are not the source of truth unless the user or project says so.

Use `pencil-design` when the task mentions Pencil, `.pen` files, Pencil MCP, editable UI mockups, or design-to-code from a Pencil document. Keep product taste and project visual direction in this skill's design contract; use `pencil-design` for the Pencil-specific tool workflow.

For raster image assets, prefer Codex imagegen when available. In Claude, do not assume imagegen is a local CLI; route through Codex/imagegen or fall back to SVG/Pencil/Figma/external prompt.

## Verification

After implementation, compare the result to the contract and fix material drift. Use available project checks and record what was actually inspected:

- Screenshots at project breakpoints, including narrow/mobile and dark mode when supported.
- Loading, empty, error, disabled, permission, success, overflow, and long-content states when relevant.
- Keyboard navigation, visible focus, semantic labels, contrast, zoom/reflow, touch targets, and non-hover alternatives.
- `prefers-reduced-motion`, animation interruption, scroll behavior, and obvious jank or layout shift.
- Existing component/token reuse and consistency with the selected golden examples.

Do not claim accessibility, performance, browser, or motion verification from generated guidance alone. If the app cannot be run or inspected, say exactly which checks remain.

For detailed DESIGN.md templates, read `references/design-md-template.md`.

For design review of an existing implementation, check:

- whether project design sources and golden examples were used
- whether project primitives/tokens were reused
- whether the UI visually fits nearby screens
- whether loading, empty, error, disabled, permission, and overflow states are covered
- whether focus, contrast, keyboard, responsive, reduced-motion, and performance-sensitive behavior were checked
- whether screenshots were checked and what visible drift remains

## Design completion

For UI/design work, final response should state:

- Design contract followed.
- Screenshots/viewports checked.
- States checked: loading, empty, error, disabled, success where relevant.
- Accessibility/interactions/motion checked.
- Not checked: viewports, browsers, data states, accessibility, interactions, performance, or motion not verified.
- Visible drift or remaining polish.
