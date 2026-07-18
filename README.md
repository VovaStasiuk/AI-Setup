# AI Setup

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Status](https://img.shields.io/badge/status-alpha%200.1.0-orange)](CHANGELOG.md)

Portable Claude + Codex developer workspace setup.

This project installs a layered AI workflow that works with Claude Code, Codex, Gemini, or any subset of them. It keeps global context small, uses project files for local facts, and gives agents reusable workflows for planning, implementation, review, design, research, and handoff.

> **Status:** alpha. Flags, skill names, and file layout may change before 1.0. Pin a tag if you need stability.

## Choose Your Path

Run these from the cloned AI Setup repository. Every path starts with a dry-run; run the matching install command only after reviewing it.

Claude only, using the general-purpose `core` profile and copy mode:

```bash
./install.sh --dry-run --profile core --claude --copy
./install.sh --profile core --claude --copy
```

Codex only:

```bash
./install.sh --dry-run --profile core --codex --copy
./install.sh --profile core --codex --copy
```

Claude + Codex for a SaaS project:

```bash
./install.sh --dry-run --profile saas --all --copy
./install.sh --profile saas --all --copy
```

Initialize that SaaS project after the global install:

```bash
./install.sh --dry-run --profile saas --init-project /path/to/project
./install.sh --profile saas --init-project /path/to/project
```

Use `/ai-setup-onboard-team` for an approval-gated command plan, or see the [team onboarding guide](docs/team-onboarding.md) for tool, profile, and copy-vs-link choices.

## What It Installs

- Global skills:
  - `ai-workflow-router`
  - `ai-setup-manager`
  - `engineering-baseline`
  - `developer-orchestrator`
  - `grill-with-context`
  - `grill-me`
  - `domain-modeling`
  - `feature-planner`
  - `to-spec`
  - `to-tickets`
  - `implementation-agent`
  - `tdd-seams`
  - `debugging-investigator`
  - `code-review-swe`
  - `project-memory-curator`
  - `human-ui-designer`
  - `pencil-design`
  - `research-brief`
  - `handoff-protocol`
  - `concise-communication`
- Optional Claude command wrappers:
  - `/ai-workflow`
  - `/ai-setup`
  - `/ai-setup-onboard-team`
  - `/ai-setup-init`
  - `/ai-setup-configure-project`
  - `/ai-setup-doctor`
  - `/ai-setup-audit`
  - `/ai-setup-standardize`
  - `/ai-setup-update`
  - `/debug-error`
  - `/plan-feature`
  - `/to-spec`
  - `/to-tickets`
  - `/grill-with-context`
  - `/grill-me`
  - `/implement`
  - `/review-code`
  - `/design-ui`
  - `/project-memory`
  - `/research`
  - `/handoff-codex`
- Tiny global bootstrap files for Claude/Codex.
- A project starter kit with `AGENTS.md`, `CLAUDE.md`, `.ai/agent-workflow.md`, `.ai/issue-tracker.md`, `.ai/domain.md`, `.ai/DESIGN.md`, `.ai/commands.md`, starter Django/React styleguides, specs, tickets, and decisions.
- Optional profiles for `core`, `saas`, `enterprise`, and `mobile` project starts.
- Design workflow support for theme discovery, palette/typography direction, `DESIGN.md`, Pencil/.pen workflows, and screenshot QA.

## Install

Clone the repo:

```bash
git clone https://github.com/<your-fork>/ai-setup.git
cd ai-setup
```

Dry-run first:

```bash
./install.sh --dry-run --all
```

Install for both Claude and Codex:

```bash
./install.sh --all
```

Install only shared skills and Codex links:

```bash
./install.sh --codex
```

Install only shared skills and Claude links/commands:

```bash
./install.sh --claude
```

Use a project-type profile:

```bash
./install.sh --list-profiles
./install.sh --dry-run --profile saas --all
./install.sh --profile saas --all
```

Copy mode is the default, so the cloned/downloaded repo can be deleted after install.

Use maintainer symlink mode:

```bash
./install.sh --all --link
```

Initialize an existing project:

```bash
./install.sh --init-project /path/to/project
```

Initialize a project with a profile overlay:

```bash
./install.sh --profile enterprise --init-project /path/to/project
```

Initialize a new project folder:

```bash
mkdir -p /path/to/new-project
./install.sh --init-project /path/to/new-project
```

Check global install health:

```bash
./install.sh --doctor
```

Check installed-vs-source drift:

```bash
./install.sh --status
```

Update an existing install from a newer copy of this repo:

```bash
./install.sh --dry-run --update
./install.sh --update
```

Uninstall:

```bash
./install.sh --dry-run --uninstall
./install.sh --uninstall
```

Restore global bootstrap files from a backup:

```bash
./install.sh --restore-backup ~/.agents/backups/<backup-dir>
```

Audit an existing project:

```bash
./install.sh --audit-project /path/to/project
```

Report how to standardize an existing project's Claude/Codex/AI setup:

```bash
./install.sh --standardize-project /path/to/project
```

## Design Philosophy

Global skills define reusable behavior. Project files define local facts.

```text
Global = workflow, taste, routing.
Project = stack, commands, architecture, styleguide, design.
Conversation = current task.
```

The global bootstrap stays small. Skills load their detailed references only when relevant.

## Tool Compatibility

The setup degrades gracefully:

- Claude only: use Claude, Superpowers if installed, and custom skills.
- Codex only: use Codex and custom skills.
- Claude + Codex: Claude/Superpowers for large planning, Codex for review/rescue.
- Gemini available: use for long-context, PDFs, audio/video, and huge scans.
- imagegen available: use for raster images, mockups, and image edits.

No subscription or CLI is required for every route.

## Project Initialization

Project init adds only a small local kit:

```text
AGENTS.md
CLAUDE.md
.ai/project-context.md
.ai/agent-workflow.md
.ai/issue-tracker.md
.ai/domain.md
.ai/tech-stack.md
.ai/styleguide.md
.ai/DESIGN.md
.ai/commands.md
.agents/skills/styleguides/
.ai/specs/
.ai/tickets/
.ai/decisions/
```

Existing files are not overwritten by default. Conflicting files are skipped unless `--force` is used.

## Recommended Workflow

1. Install global setup.
2. Add project kit to a repo.
3. Run `/ai-setup-configure-project` to inspect the repo and draft `.ai/` updates.
4. Review and approve the proposed project context, commands, stack, design, and styleguide changes.
5. Use:

```text
Use feature-planner to plan this.
Use to-spec to turn this conversation into a spec.
Use to-tickets to split this spec into implementation tickets.
Use grill-with-context to pressure-test this idea before we plan.
Use implementation-agent to implement this.
Use code-review-swe to review this against the ticket and project standards.
Use human-ui-designer to design this.
```

For the full development flow and skill-by-skill map, see [docs/developer-workflow.md](docs/developer-workflow.md).

For concrete walkthroughs, see [the SaaS team rollout](examples/onboarding/team-rollout.md), [examples/workflows/configure-project](examples/workflows/configure-project) for first-run project configuration, and [examples/workflows/billing-settings](examples/workflows/billing-settings) for the feature workflow from clarification notes to spec, tickets, implementation notes, and review.

## Repository Layout

```text
AGENTS.md
CLAUDE.md
examples/
setup/
  skills/
  global-files/
  claude-commands/
  project-kit/
docs/
profiles/
scripts/
install.sh
```

## AI-Assisted Installation

If you want Claude, Codex, or another AI coding assistant to help install or customize this setup, point it at:

- `BOOTSTRAP.md`
- `AGENTS.md`
- `docs/ai-assistant-guide.md`
- `docs/developer-workflow.md`
- `docs/team-onboarding.md`
- `docs/team-onboarding-usability-test.md`
- `docs/limitations.md`
- `docs/security.md`

Those files explain how to choose install options, run dry-runs, initialize existing projects, and add new skills safely.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Security issues: see [SECURITY.md](SECURITY.md). Community standards: [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## License

[MIT](LICENSE).

## Roadmap

- Optional sync/update script.
