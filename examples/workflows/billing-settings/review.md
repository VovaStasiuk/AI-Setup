# Billing Settings Review

This is an example output shape for `code-review-swe` after the Billing Settings tickets are implemented.

## Fixed Point

Review the feature branch against the base branch used for the Billing Settings implementation.

## Spec Sources

- `examples/workflows/billing-settings/spec.md`
- `examples/workflows/billing-settings/tickets/01-user-can-view-billing-settings.md`
- `examples/workflows/billing-settings/tickets/02-admin-can-update-billing-contact.md`
- `examples/workflows/billing-settings/tickets/03-review-billing-settings-permissions.md`

## Findings

Example finding format:

- P1: Billing contact update must enforce workspace admin permissions at the trusted write seam.

Evidence in a real review should point to exact files and lines. The risk is that hiding edit controls in the UI does not prevent a non-admin from calling the update action directly.

## Spec Axis

- Covered: admin read state, non-admin read state, billing contact update, validation states.
- Needs confirmation: provider synchronization behavior and audit logging decision.
- Out of scope: payment methods, invoice downloads, plan changes.

## Standards Axis

- Domain language should use "workspace admin", "billing contact", "billing provider portal", and "plan" consistently.
- Project commands should come from `.ai/commands.md`.
- Any new durable billing vocabulary should be proposed for `.ai/domain.md` through the project memory workflow.

## Test Gaps

- Direct non-admin write attempts must be covered at the write seam.
- Provider portal visibility should be covered by admin vs non-admin read-state tests.
- Audit logging coverage depends on the project decision.

## Review Outcome

Do not approve the implementation until trusted-boundary permission coverage is present and provider/audit assumptions are documented.
