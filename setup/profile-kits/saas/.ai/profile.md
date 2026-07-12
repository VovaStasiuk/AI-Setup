# Project Profile: SaaS

This project uses the SaaS profile. Keep product and engineering decisions grounded in tenant/workspace boundaries, billing risk, onboarding quality, and admin workflows.

## Product Areas To Notice

- Authentication and workspace membership
- Roles, permissions, invitations, and account ownership
- Billing, plans, invoices, trials, upgrades, and cancellations
- Onboarding, activation, dashboard, settings, and admin workflows
- Analytics events and customer-support visibility

## Workflow Defaults

- Use `grill-with-context` before planning vague product changes.
- Use `domain-modeling` when terms like account, workspace, tenant, organization, user, admin, owner, plan, subscription, or customer are unclear.
- Use `to-spec` and `to-tickets` for changes touching billing, roles, onboarding, settings, or dashboards.
- Prefer vertical slices that prove one user-visible SaaS workflow end to end.

## Review Gates

Ask for review before merging changes that affect:

- Authentication or authorization
- Billing or subscription state
- Tenant data isolation
- Workspace/user lifecycle
- Migrations that affect customer data
- Analytics events used for activation, billing, or support

## Design Bias

Operational SaaS UI should be quiet, dense enough for repeated use, and optimized for scanning. Avoid marketing-page styling inside app workflows.
