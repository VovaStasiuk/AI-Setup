# Ticket 02: Admin Can Update Billing Contact

## What To Build

Add the Billing Settings write path so workspace admins can update billing contact display name and email.

## Blocked By

- `01-user-can-view-billing-settings.md`

## Scope

- Add or extend the public write seam for billing contact updates.
- Add the edit form or inline edit controls for admins.
- Validate display name and email.
- Show success and error states.
- Reject non-admin update attempts at the write seam.

## Out Of Scope

- Payment method changes.
- Invoice downloads.
- Plan changes.
- Provider synchronization unless the project has a confirmed contract for it.

## Acceptance Criteria

- Admins can submit a valid billing contact update.
- The updated contact is visible after save.
- Invalid email input shows a validation error and preserves user-entered values.
- Non-admin write attempts are rejected even if they call the write seam directly.
- Provider synchronization behavior is either implemented from a confirmed contract or explicitly deferred.

## Test Seam

Use the project's public action, controller, mutation, or API endpoint as the primary write seam. Add UI coverage only for behavior that cannot be proven at the write seam.

## Verification

Replace these placeholders with project-specific commands from `.ai/commands.md`:

```bash
npm test -- billing-contact
npm run lint
```

## Implementation Notes

- Start with a failing authorization check for non-admin update attempts.
- Add the successful admin update path next.
- Add validation coverage before polishing UI states.
- If audit logging is required by the project, treat it as acceptance criteria rather than an incidental side effect.

## Review Focus

- Confirm authorization happens server-side or at the trusted write boundary.
- Confirm validation rules match existing account/contact conventions.
- Confirm provider synchronization assumptions are explicit.

## Suggested Route

Use `implementation-agent` with `tdd-seams` for the write boundary.
