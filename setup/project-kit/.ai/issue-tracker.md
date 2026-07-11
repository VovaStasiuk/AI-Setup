# Issue Tracker

Configure where AI-generated specs and tickets should be written.

## Current Mode

Local Markdown.

## Local Markdown

- Specs: `.ai/specs/`
- Tickets: `.ai/tickets/`
- One ticket per Markdown file.
- Number ticket files in dependency order, for example `01-user-can-view-list.md`.
- Use lower-case kebab-case after the number.
- Include `Blocked By`, `Acceptance Criteria`, `Test Seam`, `Verification`, and `Review Focus` sections in every ticket.
- Use `Blocked By: None.` for frontier tickets that can start immediately.

## External Trackers

If this repo uses GitHub, Linear, Jira, GitLab, or another tracker, document:

- tracker name
- project/repo/team
- labels or statuses used for agent-ready work
- how to represent blockers
- whether agents may create or update tickets without extra confirmation

Agents must not create external tickets unless the user explicitly asks.
