Use `ai-setup-manager`.

Guide a teammate through AI Setup onboarding without making unapproved changes. Locate the installer, then determine the target tools (`--claude`, `--codex`, or `--all`), profile (`core`, `saas`, `enterprise`, or `mobile`), install mode (`--copy` or `--link`), and optional project path. Recommend `--copy` unless the user is maintaining this repository and accepts that a link install depends on the source clone.

Present an `Onboarding Command Plan` with the selected choices and exact commands in this order:

1. Global dry-run: `./install.sh --dry-run --profile <profile> <tool-flag> <mode>`.
2. Global install: the same command without `--dry-run`.
3. Project dry-run when a project path is provided: `./install.sh --dry-run --profile <profile> --init-project <path>`.
4. Project init: the same command without `--dry-run`.
5. Post-install checks: `./install.sh --doctor`, `./install.sh --status`, and `/ai-setup-configure-project`.

Read-only discovery, `--list-profiles`, and dry-runs may run before confirmation. Explain what each dry-run will add, skip, or preserve. Never run a real install, project init, update, use `--force`, or edit project files until the user explicitly confirms the exact mutating command or batch. Treat global install and project init as separate approval gates when they are not confirmed together. After project init, let `/ai-setup-configure-project` produce its own `Configured Project Plan` and approval gate before any project-file writes.
