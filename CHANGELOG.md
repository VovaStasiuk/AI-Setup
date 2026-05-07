# Changelog

## Unreleased

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
