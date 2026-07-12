# Project Profile: Enterprise

This project uses the Enterprise profile. Keep decisions grounded in access control, auditability, compliance evidence, operational density, and migration safety.

## Product Areas To Notice

- Role-based access control and approval workflows
- Audit logs, exports, evidence, retention, and reporting
- Admin consoles, policy configuration, and organization settings
- Integrations, imports, data migrations, and background jobs
- Compliance, security review, and change-management workflows

## Workflow Defaults

- Use `grill-with-context` when a request has vague stakeholder, policy, control, evidence, or approval language.
- Use `domain-modeling` for overloaded terms like user, owner, admin, reviewer, approver, control, policy, evidence, exception, status, or scope.
- Use `to-spec` and `to-tickets` for changes touching permissions, audit logs, data retention, migrations, or compliance reporting.
- Prefer small vertical slices with explicit rollback, migration, and verification notes.

## Review Gates

Ask for review before merging changes that affect:

- Permissions, roles, groups, or identity provider mappings
- Audit logs, compliance evidence, or reporting outputs
- Data retention, deletion, export, or migration
- Background jobs that can modify many records
- Security-sensitive configuration or secrets

## Design Bias

Enterprise UI should be clear, information-dense, and predictable. Optimize for repeated operational work, comparison, filtering, and low-drama error recovery.
