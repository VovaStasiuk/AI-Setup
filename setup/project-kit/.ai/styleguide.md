# Styleguide Index

Project instructions override global defaults. Use this file to find local code and product conventions before editing.

## How to use

- Load only the styleguide(s) relevant to the touched area.
- Existing code patterns in this project win over generic starter rules.
- If a starter rule conflicts with real project code, ask whether to update the styleguide instead of forcing the rule.
- Keep reusable project patterns here or in `.agents/skills/styleguides/`; keep one-off feature details in `.ai/specs/<feature>/`.

## Backend

- [Django Styleguide](../.agents/skills/styleguides/Django-Styleguide.md) - starter Django conventions for models, services, selectors, APIs, admin, tasks, migrations, tests, and i18n.

Use this only for Django projects. Customize it after inspecting the app's actual architecture.

## Frontend

- [React Styleguide](../.agents/skills/styleguides/React-Styleguide.md) - starter React conventions for components, routes, data fetching, forms, styling, state, tests, and accessibility.
- [Design Contract](DESIGN.md) - visual direction, reference priority, UI components, states, and screenshot checks.

Use this only for React projects. Customize it after inspecting the app's actual architecture and design system.

## Review

- Use global `code-review-swe` for generic review.
- For UI/frontend diffs, review against `.ai/DESIGN.md` and the React styleguide.
- If project-specific review rules become repetitive, create a project-local review skill later.

## When to create project skills

Do not create project skills just because this directory exists. Add a project skill only when the project has repeated, non-obvious workflow rules that a styleguide index cannot express well.
