# Team Onboarding

Use this guide to give a new teammate the same AI Setup baseline as the rest of the project. Run commands from a cloned copy of this repository and keep the global install profile aligned with the project-init profile.

For guided onboarding in Claude, run `/ai-setup-onboard-team`. It produces the same dry-run, install, and project-init commands and waits for confirmation before any write.

## Choose Target Tools

### Claude Only

Choose this when the teammate uses Claude Code but not Codex. It installs shared skills, the Claude bootstrap, and Claude command wrappers.

```bash
./install.sh --dry-run --profile core --claude --copy
./install.sh --profile core --claude --copy
```

### Codex Only

Choose this when the teammate uses Codex but not Claude Code. It installs shared skills and the Codex bootstrap; Claude command wrappers are not needed.

```bash
./install.sh --dry-run --profile core --codex --copy
./install.sh --profile core --codex --copy
```

### Claude + Codex

Choose this when both tools are part of the team workflow.

```bash
./install.sh --dry-run --profile core --all --copy
./install.sh --profile core --all --copy
```

All routes work without Gemini. Optional tools and subscriptions degrade gracefully.

## Choose Copy Or Link Mode

| Mode | Choose It When | Consequence |
|---|---|---|
| `--copy` | A teammate wants a stable, self-contained install | Default and recommended. The source clone can be deleted after successful health and drift checks. |
| `--link` | A maintainer actively edits AI Setup and wants live local changes | Installed skill folders depend on the source clone. Moving or deleting it breaks the links. |

Use explicit `--copy` in team instructions even though it is the default. Use `--link` only when the teammate understands that the clone becomes part of the live installation.

## Choose A Profile

The profile should match the project, not the teammate's job title.

| Profile | Choose It For |
|---|---|
| `core` | General software projects or projects that do not clearly fit a specialized profile |
| `saas` | B2B SaaS with workspaces/tenants, billing, onboarding, dashboards, settings, or admin workflows |
| `enterprise` | Enterprise, GRC, or internal operations software with access control, auditability, compliance, migrations, or approval workflows |
| `mobile` | iOS, Android, React Native, Flutter, or mobile-first products with device, offline, accessibility, and release concerns |

Inspect the available definitions before deciding:

```bash
./install.sh --list-profiles
```

Replace `core` in the tool commands above with the selected profile. Reuse that profile during project init so the matching `.ai/profile.md` overlay is installed.

## First Project Init Checklist

1. Confirm the exact project path and selected profile.
2. Inspect existing `AGENTS.md`, `CLAUDE.md`, and `.ai/` files. Preserve project-specific instructions.
3. Run the project dry-run:

   ```bash
   ./install.sh --dry-run --profile saas --init-project /path/to/project
   ```

4. Review every file reported as added or skipped. Do not use `--force` until conflicts have been reviewed and a merge or replacement is explicitly approved.
5. Apply the init only after approval:

   ```bash
   ./install.sh --profile saas --init-project /path/to/project
   ```

6. Audit the initialized project before configuration:

   ```bash
   ./install.sh --audit-project /path/to/project
   ```

7. In Claude, run `/ai-setup-configure-project`. In Codex or another assistant, ask: `Use ai-setup-manager to configure this project after AI Setup init.` Review the `Configured Project Plan` before approving file writes.

## Post-Install Checks

Check global installation health:

```bash
./install.sh --doctor
```

Check whether installed files match the current source clone:

```bash
./install.sh --status
```

Then configure project facts, commands, domain language, design sources, and profile-specific gaps:

```text
/ai-setup-configure-project
```

The configuration workflow must inspect the repository first, separate verified commands from candidates, preserve non-placeholder instructions, and ask before writing. A complete SaaS walkthrough is available in [examples/onboarding/team-rollout.md](../examples/onboarding/team-rollout.md).
