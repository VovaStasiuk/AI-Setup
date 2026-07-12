# Ticket 01: User Can View Billing Settings

## What To Build

Add the first Billing Settings read path and page state. Admins should see plan, billing status, billing contact, and the provider portal link. Non-admin members should see limited plan information without admin-only controls.

## Blocked By

None.

## Scope

- Add or extend the public read seam for Billing Settings data.
- Render Billing Settings in the workspace settings area.
- Show admin and non-admin states from the same page.
- Include loading, empty, and read-error states.

## Out Of Scope

- Updating billing contact.
- Payment method changes.
- Invoice download behavior.
- Provider webhook changes.

## Acceptance Criteria

- Admins see plan name, billing status, billing contact display name, billing contact email, and provider portal link.
- Non-admin members see limited plan information.
- Non-admin members do not see edit controls or provider management actions.
- Empty billing contact data renders a clear empty state.
- Read failures render a recoverable error state.

## Test Seam

Use the project's public page, route loader, controller, or API read seam for Billing Settings. Avoid testing private formatting helpers as the main seam.

## Verification

Replace these placeholders with project-specific commands from `.ai/commands.md`:

```bash
npm test -- billing-settings
npm run lint
```

## Implementation Notes

- Start with the narrowest failing read-state check for admin vs non-admin visibility.
- Keep provider portal URL creation on the server if it may require signing or account scoping.
- Record any unresolved provider-field assumptions in the ticket before continuing.

## Review Focus

- Confirm non-admin users cannot infer or access admin-only provider actions.
- Confirm page states do not depend on hidden UI controls for security.

## Suggested Route

Use `implementation-agent`, then `code-review-swe` if the read seam touches shared authorization or billing code.
