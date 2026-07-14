# SaaS Team Rollout

This walkthrough follows a new teammate joining an existing SaaS project. The team uses Claude and Codex, the teammate wants a self-contained copy install, and the project lives at `/path/to/acme-app`.

## 1. Clone AI Setup

```bash
git clone <team-ai-setup-url> ai-setup
cd ai-setup
```

The teammate can alternatively run `/ai-setup-onboard-team` in Claude and select:

- Tools: Claude + Codex (`--all`)
- Profile: SaaS (`--profile saas`)
- Mode: copy (`--copy`)
- Project: `/path/to/acme-app`

The wrapper shows the exact command plan and does not install or write until the teammate confirms.

## 2. Preview And Install The Global Setup

```bash
./install.sh --dry-run --profile saas --all --copy
```

The teammate reviews the skills, Claude command wrappers, and global bootstrap changes. After confirming that plan:

```bash
./install.sh --profile saas --all --copy
```

Copy mode means the installation does not depend on this clone after it passes health checks.

## 3. Check The Install

```bash
./install.sh --doctor
./install.sh --status
```

`--doctor` should report a healthy global setup. `--status` should report that the installed skills, wrappers, bootstraps, and metadata match this source.

## 4. Preview Project Init

Before init, the teammate checks `/path/to/acme-app/AGENTS.md`, `/path/to/acme-app/CLAUDE.md`, and `/path/to/acme-app/.ai/` for existing project instructions.

```bash
./install.sh --dry-run --profile saas --init-project /path/to/acme-app
```

They review added and skipped files. Existing files are preserved; they do not use `--force` to replace team instructions.

## 5. Initialize The Project

After confirming the project-init dry-run:

```bash
./install.sh --profile saas --init-project /path/to/acme-app
./install.sh --audit-project /path/to/acme-app
```

The SaaS overlay adds `.ai/profile.md` with prompts for tenant/workspace boundaries, billing, onboarding, dashboards, settings, and admin workflows. These prompts are a lens for inspection, not assumed project facts.

## 6. Configure From Repository Evidence

From the project in Claude, the teammate runs:

```text
/ai-setup-configure-project
```

Claude inspects the project docs, configs, source layout, CI commands, design sources, styleguides, and `.ai/profile.md`. It presents a `Configured Project Plan` containing:

- Evidence and detected SaaS profile
- Proposed `.ai/` and styleguide updates
- Verified, candidate, and approval-required commands
- SaaS-specific gaps such as workspace ownership, tenant isolation, billing, roles, and onboarding
- The exact file-write batch

The teammate corrects any wrong assumptions and explicitly approves the write batch. Claude preserves existing non-placeholder instructions, applies the approved changes, and re-runs the project audit when the installer is available.

At that point the teammate has the same global workflow, project profile, and evidence-backed project context as the rest of the team.
