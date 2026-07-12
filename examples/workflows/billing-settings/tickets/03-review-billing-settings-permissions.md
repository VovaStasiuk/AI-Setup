# Ticket 03: Review Billing Settings Permissions

## What To Build

Perform a focused review of Billing Settings permission behavior after the read and write tickets are implemented.

## Blocked By

- `01-user-can-view-billing-settings.md`
- `02-admin-can-update-billing-contact.md`

## Scope

- Review admin and non-admin behavior across read and write seams.
- Verify provider portal link visibility and generation rules.
- Check whether audit logging is required for billing contact updates.
- Confirm tests cover direct write attempts, not only UI-hidden controls.

## Out Of Scope

- Rewriting the billing architecture.
- Adding new provider features.
- Broad settings-page refactors.

## Acceptance Criteria

- Review findings are listed with severity, evidence, and file/line references in a real project.
- Non-admin direct write attempts are covered by a test.
- Admin-only provider portal behavior is covered by a read-state or authorization test.
- Any audit logging decision is documented in the ticket, spec, or project decision file.
- No unrelated refactors are included in the review cleanup.

## Test Seam

Use the permission matrix at the public read and write seams. For a real implementation, review should point to exact tests or commands.

## Verification

Replace these placeholders with project-specific commands from `.ai/commands.md`:

```bash
npm test -- billing-settings
npm run lint
```

## Implementation Notes

- This is a review-gated ticket, not a new feature slice.
- If the review finds a permission bug, fix it in the smallest relevant seam and rerun the focused checks.

## Review Focus

- Server-side authorization at the write seam.
- Admin-only provider portal access.
- Test coverage for direct non-admin attempts.
- Clear handling of unresolved provider synchronization or audit requirements.

## Suggested Route

Use `code-review-swe` against the spec and both implementation tickets.
