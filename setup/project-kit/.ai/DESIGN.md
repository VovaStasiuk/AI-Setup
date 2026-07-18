# Design Contract

If this file is incomplete, agents must ask before inventing visual direction for new UI.

## Product

- Product type:
- Primary users:
- Core workflows:
- Usage frequency:
- Density expectation:
- Target platforms:
- Frontend stack:
- Existing design/animation dependencies:

## Reference Priority

Use design references in this order:

1. Existing production UI and reusable components in this project.
2. This `DESIGN.md` and feature-level `.ai/specs/<feature>/DESIGN.md`.
3. User-provided screenshots, Figma/Pencil files, or explicit references.
4. Existing design tokens, Tailwind/theme config, Storybook, or component docs.
5. External inspiration such as getdesign.md, awesome-design-md, Open Design, or competitor screenshots.
6. AI-generated ideas only after the sources above are missing or insufficient.

Do not treat old task mockups, feature-specific screenshots, or external product references as global style unless the user or this file says so.

## Existing UI Inventory

List the strongest local examples before designing a new screen.

- Golden pages/screens to copy:
- Golden components to reuse:
- Table/list pattern:
- Form pattern:
- Modal/drawer pattern:
- Empty/loading/error state pattern:
- Patterns to avoid:

## Visual Direction

- Personality:
- Density:
- Variance: restrained / balanced / expressive
- Motion: subtle / standard / choreographed
- Light/dark mode:
- Layout rhythm:
- Border/radius/shadow style:
- Icon style:
- Motion style:
- References:
- Avoid:

## Motion Contract

- Purpose:
- Triggers:
- Entry/exit behavior:
- Duration/easing:
- Interruption behavior:
- Scroll behavior:
- Reduced-motion fallback:
- Performance limits:

## Foundations

- Color roles:
  - Background:
  - Surface:
  - Border:
  - Primary action:
  - Secondary action:
  - Success:
  - Warning:
  - Danger:
  - Info:
- Typography:
  - Body:
  - Headings:
  - Numeric/tabular data:
  - Labels/help text:
- Spacing:
  - Page padding:
  - Section gap:
  - Card/panel padding:
  - Table row height:

## Components

- Buttons:
- Forms:
- Tables/lists:
- Cards/panels:
- Navigation:
- Tabs:
- Modals/drawers:
- Toasts/alerts:

## States

- Loading:
- Empty:
- Error:
- Disabled:
- Success:
- Permission denied:
- Long text / overflow:
- Mobile / narrow viewport:

## Accessibility and Interaction

- Keyboard path and visible focus:
- Contrast requirements:
- Touch targets:
- Hover alternatives:
- Zoom/reflow:
- Loading and action feedback:

## Visual Acceptance Criteria

Before calling UI work complete, verify:

- It matches the density, spacing, typography, and action hierarchy of the chosen local examples.
- It reuses existing primitives/tokens before adding new styling.
- It does not invent a random card, icon-color, shadow, or gradient system.
- Color is semantic and restrained; accents communicate state or hierarchy.
- Tables/lists are decision-useful, not decorative.
- Primary and destructive actions have correct visual weight.
- Loading, empty, error, disabled, and permission states are handled when relevant.
- Keyboard, focus, contrast, zoom/reflow, touch, and non-hover behavior are checked when relevant.
- Motion has a product purpose, remains interruptible, avoids layout shift, and respects reduced-motion preferences.
- Screenshot verification was performed, or the reason it was not possible is stated.

## Screenshot Checks

- Desktop:
- Mobile/narrow:
- Dark mode:
- Important states checked:
- Keyboard/focus/contrast checked:
- Motion/reduced-motion checked:
- Performance/layout stability checked:
- Visible drift / remaining polish:
