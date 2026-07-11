# React Styleguide

Starter conventions for React projects. Treat this as a baseline, not a law. Project code, `AGENTS.md`, `.ai/DESIGN.md`, `.ai/tech-stack.md`, and local architecture win when they disagree.

## Context first

- Read `.ai/project-context.md`, `.ai/tech-stack.md`, `.ai/commands.md`, `.ai/DESIGN.md`, and this styleguide before non-trivial frontend work.
- Inspect nearby routes, pages, components, hooks, query modules, tests, and theme files before adding new patterns.
- Identify the app model before editing: SPA, framework router, Django/Blade/Rails template mount, microfrontend, or component library.

## Project structure

- Follow the existing route/page/component layout.
- Do not hand-edit generated route files or generated API clients unless the project says to.
- Keep reusable primitives in the local component system.
- Keep feature-specific components near the feature until reuse is real.
- Prefer project aliases/import conventions over deep relative paths when available.

## Components

- Use named exports unless the project consistently uses default exports.
- Keep components focused: data loading, layout, and leaf rendering should be separated when a file becomes hard to scan.
- Do not define stateful child components inside parent render functions when it causes remounts or state loss.
- Add prop/component documentation only when the contract is reusable or non-obvious.
- Keep text, labels, empty states, and errors domain-specific.

## Data fetching

- Use the project's established data layer: TanStack Query, framework loaders/actions, GraphQL hooks, generated clients, or local API helpers.
- Avoid `useEffect` for server data fetching when the project has a query/router data pattern.
- Include tenant/org/user/filter context in cache keys when returned data varies by that context.
- Keep API functions and query hooks consistent with nearby modules.
- Handle loading, empty, error, permission, and stale/refetch states where relevant.

## Forms

- Use the project's form stack and validation library.
- Keep validation schemas near the feature unless the project has a central schema pattern.
- Show actionable validation messages.
- Preserve dirty/submitting/disabled states.
- Do not create raw form controls when project primitives already handle accessibility and styling.

## Styling and design

- `.ai/DESIGN.md` is the visual source of truth.
- Reuse existing primitives, theme tokens, spacing, typography, and state colors before adding one-off styling.
- For existing products, identify 2-5 golden local examples before designing new UI.
- Do not invent random card, icon-color, shadow, gradient, or typography systems.
- Use semantic color for status and action meaning.
- Check responsive behavior and long text/overflow when the UI has variable content.

## State and performance

- Keep server data in the data layer, not duplicated in local state.
- Use local state for local UI concerns.
- Derive cheap values during render; use memoization for expensive work or identity-sensitive props.
- Avoid unnecessary global state.
- Virtualize or paginate large lists when the project has that pattern.

## Accessibility

- Preserve keyboard navigation and focus states.
- Use semantic controls before custom div/button behavior.
- Connect labels, descriptions, errors, and inputs.
- Ensure dialogs, menus, drawers, and popovers follow the project's accessible primitives.

## Tests and verification

- Use the project's test stack and colocated test conventions.
- Cover critical user workflows, permission gates, validation, empty/error states, and data mutation effects.
- Run the narrowest meaningful check from `.ai/commands.md`.
- For UI work, verify with screenshots when practical and state what was not checked.

## Review checklist

- Does the UI follow `.ai/DESIGN.md` and nearby examples?
- Are project primitives and tokens reused?
- Are server data, cache keys, mutations, and invalidation handled through the project data layer?
- Are loading, empty, error, disabled, permission, and responsive states covered?
- Is generated code avoided or regenerated through the proper command?
- Are tests or screenshot checks sufficient for the risk?
