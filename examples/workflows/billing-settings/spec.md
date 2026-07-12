# Billing Settings Spec

This is an example output from `to-spec`.

## Problem

Workspace admins need a clear place to view their current billing state and update the billing contact without asking support.

## Goal

Provide a Billing Settings page that shows plan and billing contact information, links admins to the billing provider portal, and lets admins update the billing contact.

## Actors

- Workspace admin
- Workspace member
- Billing provider

## Scope

- Add a Billing Settings page under workspace settings.
- Show current plan name and billing status.
- Show current billing contact display name and email.
- Show a provider portal link to workspace admins.
- Allow workspace admins to update billing contact display name and email.
- Hide edit controls from non-admin workspace members.
- Return a clear unauthorized result for non-admin update attempts.
- Include loading, empty, validation, success, and error states.

## Out Of Scope

- Payment method changes.
- Invoice downloads.
- Plan upgrades and downgrades.
- Billing provider webhook changes.
- Historical billing activity.

## User Stories

- As a workspace admin, I can view plan and billing contact information.
- As a workspace admin, I can open the billing provider portal.
- As a workspace admin, I can update the billing contact.
- As a workspace member, I can view limited plan information without seeing admin-only controls.
- As the system, I prevent non-admin users from changing billing contact data.

## Domain Language

- Billing contact: workspace-level name and email used for billing notifications.
- Billing provider portal: provider-hosted external billing management page.
- Plan: current subscription tier and billing status shown in the app.

## Implementation Decisions

- Use a public read seam for Billing Settings data, such as a route loader, controller action, or API endpoint.
- Use a separate public write seam for billing contact updates.
- Enforce admin authorization at the write seam, not only in the UI.
- Treat provider portal link generation as a server-side concern when the provider requires a signed URL.
- Keep provider synchronization behavior explicit before implementation. If synchronization is unknown, persist locally and leave a named follow-up.

## Testing Decisions

- Add a focused read check for admin and non-admin page state.
- Add a focused write check that accepts workspace admins and rejects non-admin members.
- Add validation coverage for malformed or missing billing contact email.
- Verify the UI does not render edit controls for non-admin members.

## Acceptance Criteria

- Admins can see plan name, billing status, billing contact, and provider portal link.
- Admins can update billing contact display name and email.
- Non-admins do not see edit controls or provider-only management actions.
- Non-admin update attempts are rejected at the write seam.
- Validation errors are visible and preserve the form state.
- Success and failure states are clear to the user.
- Verification commands are recorded in the implementation notes or ticket.

## Assumptions

- The project already has workspace membership and role information.
- The billing provider portal can be represented as a URL available to admins.
- Existing project settings navigation can host the Billing Settings page.

## Open Questions

- Should billing contact updates emit an audit event?
- Is billing contact data owned locally, by the provider, or both?

## Next Step

Use `to-tickets` to split this spec into small vertical implementation tickets.
