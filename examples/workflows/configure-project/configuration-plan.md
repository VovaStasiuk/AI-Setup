# Configured Project Plan

This is an example output from `/ai-setup-configure-project`.

## Project

- Path: `/path/to/acme-billing`
- Detected profile: `saas`
- Current mode: project initialized with starter `.ai/` files

## Evidence Inspected

| Source | Evidence |
|---|---|
| `README.md` | Product is a B2B subscription app for workspaces. |
| `package.json` | Uses React, Vite, TypeScript, Vitest, and ESLint scripts. |
| `src/routes/settings/` | Existing settings pages use route-level loaders and forms. |
| `src/components/ui/` | Buttons, forms, tables, dialogs, and toast primitives exist. |
| `.github/workflows/ci.yml` | CI runs typecheck, lint, and tests. |
| `.ai/profile.md` | SaaS profile is installed; workspace, billing, onboarding, settings, and tenant isolation need attention. |

## Facts Found

- Primary users appear to be workspace admins and workspace members.
- The app has authenticated workspace settings routes.
- Existing UI primitives should be reused before adding styling.
- Test commands are documented in CI, but local service requirements are not documented.

## Proposed Destination Files

### `.ai/project-context.md`

- Add purpose: B2B subscription workspace app.
- Add users: workspace admins and members.
- Add important paths: `src/routes/`, `src/components/ui/`, `src/lib/`, `tests/`.
- Add constraints: tenant isolation and billing changes require review.

### `.ai/profile.md`

- Keep SaaS profile.
- Add project-specific watch areas: workspace settings, billing, invitations, onboarding.

### `.ai/agent-workflow.md`

- Keep standard flow.
- Add human gates for auth, billing, workspace membership, migrations, and deployment.

### `.ai/domain.md`

- Add candidate terms: workspace, workspace admin, member, billing contact, subscription, plan.
- Mark overloaded words for confirmation: account, customer, organization.

### `.ai/tech-stack.md`

- Add React, Vite, TypeScript, Vitest, ESLint.
- Note package manager from lockfile after confirmation.

### `.ai/commands.md`

Verified from CI or docs:

```bash
npm run typecheck
npm run lint
npm test
```

Candidate, not yet run:

```bash
npm run dev
npm run build
```

Approval-required:

```bash
npm run deploy
```

### `.ai/DESIGN.md`

- Design source found: existing `src/components/ui/` primitives.
- Golden examples to inspect before UI work: settings pages and table/list components.
- Unknown: brand palette and typography source.

### `.ai/styleguide.md`

- Keep React styleguide.
- Remove or ignore Django styleguide unless backend evidence appears.

## Profile-Specific Gaps

- Confirm whether `workspace`, `organization`, and `account` are distinct terms.
- Confirm billing provider ownership and whether billing changes require audit events.
- Confirm onboarding activation events and analytics ownership.
- Confirm support/admin visibility rules for customer data.

## Unknowns To Preserve

- Package manager until lockfile is inspected.
- Local services required for tests.
- Design token source.
- External issue tracker, if any.

## Risk If Wrong

- Incorrect tenant vocabulary can cause specs, tests, and permission checks to target the wrong boundary.
- Treating inferred commands as verified can waste implementation time or damage local state.
- Inventing visual direction can create UI that conflicts with existing product design.

## Proposed Write Batch

1. Update `.ai/project-context.md`, `.ai/profile.md`, `.ai/tech-stack.md`, and `.ai/commands.md`.
2. Update `.ai/domain.md` with confirmed terms and candidate overloaded terms.
3. Update `.ai/DESIGN.md` with existing UI inventory and unknown design-token source.
4. Run `./install.sh --audit-project .`.

Ask for approval before writing this batch.
