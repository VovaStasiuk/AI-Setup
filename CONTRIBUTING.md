# Contributing to AI Setup

Thanks for your interest. AI Setup is an installer/template project for portable Claude + Codex + Gemini workflows.

## Ground Rules

- Keep changes portable. No machine-specific paths or assumptions.
- Preserve existing user/project files. Never overwrite without explicit opt-in.
- Keep global skills small. Push detail into `references/`.
- Follow `skill-creator` guidance for new or modified skills.
- Run dry-runs before recommending real installs.

## Development Workflow

1. Fork and clone.
2. Make changes in a feature branch.
3. Run the installer test:

   ```bash
   ./scripts/test-install.sh
   ```

   It uses a temporary `HOME` so your real config stays untouched.

4. Validate repository links and metadata:

   ```bash
   bash scripts/check-markdown-links.sh
   bash scripts/validate-repo.sh
   ```

5. Lint the installer:

   ```bash
   shellcheck install.sh scripts/check-markdown-links.sh scripts/test-install.sh scripts/validate-repo.sh
   ```

6. Verify dry-run output for any installer flag you touched:

   ```bash
   ./install.sh --dry-run --all
   ./install.sh --dry-run --init-project /tmp/ai-setup-test
   ```

7. Update `CHANGELOG.md` under the unreleased section.

## Adding a Skill

- Create `setup/skills/<name>/SKILL.md` with precise `name` and `description` frontmatter.
- Keep the body compact. Long detail goes in `setup/skills/<name>/references/`.
- Add the skill to `profiles/core.json` only if broadly useful.
- Add a Claude command wrapper in `setup/claude-commands/` only if it maps to a common user action.
- Document in `docs/` if it changes routing or workflow.

## Adding a Profile

- Create `profiles/<name>.json`.
- Document in `docs/profiles.md`.
- Do not bloat `core.json`.

## Pull Requests

- One logical change per PR.
- Update README/docs when behavior or flags change.
- Include test output from `scripts/test-install.sh`.
- Reference any related issue.

## Reporting Bugs

Open a GitHub issue with:

- AI Setup version (`cat VERSION`).
- OS and shell.
- Exact command run.
- Dry-run output if relevant.
- Expected vs. actual behavior.

For security issues, see [SECURITY.md](SECURITY.md).

## Code of Conduct

This project follows the [Contributor Covenant](CODE_OF_CONDUCT.md).
