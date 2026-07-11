# Django Styleguide

Starter conventions for Django projects. Treat this as a baseline, not a law. Project code, `AGENTS.md`, `.ai/tech-stack.md`, and local architecture win when they disagree.

## Context first

- Read `.ai/project-context.md`, `.ai/tech-stack.md`, and `.ai/commands.md` before non-trivial backend work.
- Inspect nearby apps, models, serializers, views, tests, and helper modules before adding new patterns.
- Do not copy rules from another project blindly.

## App layout

- Keep feature/domain code inside focused Django apps.
- Keep project/runtime configuration in the project config package.
- Prefer existing local helper modules over new utilities.
- Keep migrations, serializers, views, services, selectors, tasks, and tests near the app/domain they belong to.

## Models

- Follow the project's established base model pattern.
- Use explicit field names, constraints, indexes, and `related_name` values where they improve clarity.
- Keep model methods small and data-oriented.
- Avoid hidden business workflows in `save()`; prefer explicit services for write workflows.
- Use lazy translation for class-level labels when the project uses i18n.

## Services and selectors

- Put write workflows in services when they involve validation, permissions, transactions, side effects, or multiple models.
- Put reusable read/query composition in selectors when views or tasks would otherwise duplicate query logic.
- Keep services independent of HTTP request/response objects unless the project has an established exception.
- Validate data before saving when model or domain invariants matter.
- Use transactions for multi-row writes, state transitions, and write plus side-effect scheduling.

## APIs and views

- Follow the project's established API stack: DRF, Django views, HTMX, GraphQL, or other local pattern.
- Keep views thin: authentication, permission, parsing, delegation, response shaping.
- Do not put complex domain logic in views or serializers.
- Use explicit serializers/forms/schemas for public contracts.
- Scope queries by tenant, organization, user, or ownership whenever the product has multi-tenant or permission boundaries.

## Admin

- Use the project's admin base classes and permission conventions.
- Avoid expensive list display fields without eager loading or clear justification.
- Do not expose sensitive data or cross-tenant records through admin shortcuts.

## Tasks and side effects

- Keep background tasks thin; delegate business logic to services.
- Pass IDs or primitives to tasks, not model instances.
- Schedule tasks after transaction commit when the task reads data written in the transaction.
- Log with structured context and lazy formatting.

## Migrations

- Keep migrations reversible when practical.
- Split risky production changes: add nullable field, backfill, enforce non-null/constraint.
- Be careful with large-table locks and data migrations.
- Do not edit old migrations unless the project is still pre-release and the team explicitly accepts rewrite risk.

## Tests

- Put tests where the project expects them.
- Cover the behavior that can break: permissions, ownership, validation failures, state transitions, API contracts, and background jobs.
- Prefer focused tests near the changed app/domain over broad slow tests unless integration risk is high.
- Use project factories/fixtures instead of ad hoc setup when available.

## Review checklist

- Is every query scoped correctly for tenant/org/user ownership?
- Are permissions enforced server-side, not only in UI?
- Are writes validated and transactional where needed?
- Is business logic outside views/serializers when it should be reusable/testable?
- Are migrations safe for existing data?
- Are tests focused on the changed behavior and failure modes?
