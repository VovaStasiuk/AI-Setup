# Billing Settings Implementation Notes

This is an example of how `implementation-agent` and `tdd-seams` should work through the tickets. It is not tied to a specific framework.

## Starting Point

Begin with `tickets/01-user-can-view-billing-settings.md`.

## Ticket 01 Frontier

Public seam:

- Billing Settings read route, loader, controller, or API endpoint.
- Billing Settings page state for admin and non-admin users.

Focused failing checks:

- Admin read state includes plan, billing status, billing contact, and provider portal link.
- Non-admin read state excludes edit controls and provider management actions.

Implementation order:

1. Add the smallest read seam shape needed by the page.
2. Render the admin state.
3. Render the non-admin state from the same route.
4. Add empty and error states.
5. Run focused tests before broad lint/type checks.

## Ticket 02 Frontier

Public seam:

- Billing contact update action, mutation, controller, or API endpoint.

Focused failing checks:

- Non-admin update attempts are rejected at the write seam.
- Admin can update a valid billing contact.
- Invalid email returns a validation error and preserves form state.

Implementation order:

1. Add the non-admin rejection test first.
2. Add the admin update path.
3. Add validation behavior.
4. Connect the UI form to the write seam.
5. Record provider synchronization behavior as implemented or deferred.

## Verification Notes

Use project-specific commands from `.ai/commands.md`. Example placeholder commands:

```bash
npm test -- billing-settings
npm test -- billing-contact
npm run lint
```

Do not mark these commands as verified in a real ticket unless they were actually run.

## Handoff Notes

If the work moves to another agent, include:

- The spec path.
- The active ticket path.
- The public seams chosen.
- Commands already run and their results.
- Any unresolved provider or audit logging assumptions.
