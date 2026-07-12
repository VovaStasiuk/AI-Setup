# Billing Settings Grill Notes

This is an example output from `grill-with-context` before writing a spec.

## Feature

Add a Billing Settings area for a B2B SaaS workspace.

## Confirmed Decisions

- Workspace admins can view plan details, billing contact, and a link to the billing provider portal.
- Workspace admins can update the billing contact display name and email.
- Non-admin workspace members can view limited plan information but cannot see edit controls.
- Payment method management is out of scope and remains in the billing provider portal.
- Invoice downloads are out of scope for the first pass.
- The first implementation should use a small vertical slice: read settings, render the page, then add the update action.

## Shared Language

- Workspace: the tenant or account that owns billing.
- Workspace admin: a user with permission to manage workspace settings.
- Billing contact: the name and email used for billing notifications.
- Billing provider portal: the external provider-hosted page for payment methods, invoices, and plan changes.
- Plan: the current subscription tier shown inside the app.

## Open Questions

- What exact provider portal URL or API field should the app use?
- Should billing contact updates be written to the local database only, or also synchronized to the billing provider?
- Should updates create an audit event?

## Candidate Domain Update

Add this to `.ai/domain.md` after project approval:

```text
Billing contact: workspace-level name and email used for billing notifications. It is editable by workspace admins and is separate from payment method ownership in the billing provider.
```

## Next Route

Use `to-spec` to turn these decisions into a stable implementation contract.
