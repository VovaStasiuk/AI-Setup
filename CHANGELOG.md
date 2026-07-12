# Changelog

## Unreleased

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
