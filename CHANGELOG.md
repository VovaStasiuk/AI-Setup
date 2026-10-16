# Changelog

## 0.2.1

- Fixed `./install.sh --status` reporting global `CLAUDE.md` / `AGENTS.md` as stale when personal notes sit below the managed block. Status now compares only the block.

## 0.2.0

- Added workflow stages and per-work-item state (`.ai/work/<slug>/state.md`) so a session can resume and propose the next step without being re-briefed. See `engineering-baseline/references/workflow-state.md`.
- Added the `ship` skill: lint, build, tests, review, browser check, commit message, ticket note and state update, with an explicit not-run list.
- Added `plain-talk` and `ticket` skills; added implementation rules (touch points, root cause, keep validation, no dependency for a few lines, project components first, edge-case-correct choice, never trade away validation, security or accessibility).
- Added Claude mods under `mods/` (`cheap-lane`, `relay`, `cockpit`, `file-guard`, opt-in `house-rules`) and `./install.sh --mods`.
- Added the `fable-advisor` agent (`setup/claude-agents/`), installed with `--mods`.
- Global `CLAUDE.md` / `AGENTS.md` are now written as a managed block between `<!-- ai-setup:begin -->` and `<!-- ai-setup:end -->`; text outside the block is kept on update.
- Removed `concise-communication`, `ai-workflow-router`, `developer-orchestrator` and `/ai-workflow`. `--update` retires them from existing installs (with a backup).
- Removed the "prefer Superpowers" routing line from the global files.

## Unreleased

- Added opt-in, pinned Chrome DevTools MCP registration for Claude and Codex with isolated-browser defaults, telemetry/CrUX opt-outs, ownership-aware status checks, workflow routing, and security documentation.
- Strengthened code-comment discipline across the global bootstraps, `engineering-baseline`, and `implementation-agent`: corrected code must contain no debugging archaeology, single statements allow at most one short comment line, and defect history belongs in tests or implementation summaries.
- Removed the redundant `grill-me` skill and `/grill-me` command; natural-language "grill me" requests now route only to `grill-with-context`, and updates safely retire recognizable AI Setup-owned copies.
- Strengthened `human-ui-designer` with a bounded UI/UX Pro Max-inspired intelligence pass, explicit quality priorities, motion and reduced-motion contracts, and interaction/accessibility verification requirements.
- Added isolated installer coverage for tool/mode/profile routes, onboarding-wrapper safety contracts, local Markdown link checking in CI, a fresh-user usability protocol, and a pinned team update policy.
- Added team onboarding documentation, quick-path README recipes, `/ai-setup-onboard-team`, and a complete SaaS teammate rollout example with approval-gated install and project configuration.
- Added `./install.sh --status` to detect installed-vs-source drift for skills, command wrappers, global bootstraps, and install metadata before updating.
- Made `/ai-setup-configure-project` profile-aware with a concrete `Configured Project Plan` output contract and example.
- Added installer profile support with `core`, `saas`, `enterprise`, and `mobile` profiles plus project-kit overlays.
- Added a Billing Settings worked example that shows the full `grill-with-context` -> `to-spec` -> `to-tickets` -> implementation -> review flow.
- Added `domain-modeling` to clarify project vocabulary and maintain `.ai/domain.md` through approved memory updates.
- Added `tdd-seams` to guide test-first implementation through public seams and avoid weak tests.
- Strengthened `implementation-agent` to use seam-first, focused verification loops for non-trivial work.
- Upgraded `code-review-swe` with fixed-point, spec-axis, standards-axis, and code-smell baseline guidance.
- Made local `.ai/tickets/NN-title.md` ticket output concrete in `to-tickets`.
- Added `to-spec` and `/to-spec` to turn clarified conversations or approved plans into stable specs.
- Added `to-tickets` and `/to-tickets` to turn specs, PRDs, and backlogs into small vertical implementation tickets with blockers.
- Added project workflow, issue-tracker, domain, and ticket starter files to the project kit.
- Added `ai-workflow-router` and `/ai-workflow` to route users to the right setup, planning, implementation, review, debug, design, research, memory, or handoff workflow.
- Added `/ai-setup-configure-project` for AI-guided project starter file configuration after init.
- Added repository metadata validation for skills, profiles, command wrappers, project-kit files, and portable global bootstraps.
- Synced `pencil-design` into the core profile skill list.
- Removed the optional `graphify` reference from the portable Claude global bootstrap.
- Treated `CLAUDE.md` files that explicitly wrap `AGENTS.md` as intentional in project standardization reports.
- Added `LICENSE` (MIT), `SECURITY.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`.
- Added `.editorconfig`, GitHub issue/PR templates, and CI workflow.
- README: license badge, alpha status note, clone step, contributing/license sections.
- Fixed shellcheck warnings in `install.sh` (SC2155, SC2295).

## 0.1.0

- Added portable Claude + Codex AI Setup project.
- Added global skills, Claude commands, project starter kit, and installer.
- Added copy-by-default install mode with explicit `--link` maintainer mode.
- Added bootstrap prompt for first install through Claude/Codex.
- Added `ai-setup-manager` for ongoing setup management.
- Added `--doctor` and `--audit-project` installer checks.
- Added `--update` to refresh installed skills, commands, bootstraps, and metadata.
- Added `--standardize-project` and `/ai-setup-standardize` for project AI setup consistency reports.
- Added `project-memory-curator` for approved, evidenced updates to project docs/styleguides.
- Added `debugging-investigator` and strengthened evidence/anti-fabrication rules across workflows.
- Added vertical-slice delivery defaults for full-stack backend/frontend features.
- Added completion contract so agents must state completed work, verification, skipped items, and residual risk.
- Added local final review pass requirement for non-trivial implementation.
- Added uninstall, backup restore, installer test script, limitations, and security docs.
- Clarified image generation routing: Claude should hand off to Codex imagegen when available instead of checking only for an `imagegen` CLI.
- Upgraded project standardization guidance so AI performs deep content inspection and prioritized recommendations instead of stopping at inventory.
