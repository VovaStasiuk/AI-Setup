# Security And Privacy

AI Setup changes global AI assistant instructions and may add project files. Treat it like developer tooling.

## Before Install

- Inspect `install.sh`.
- Run dry-run first:

```bash
./install.sh --dry-run --all
```

- Prefer copy mode for one-time installs.
- Use `--link` only when you trust and keep the source repo.

## Data Handling

- AI Setup does not require secrets.
- Do not paste secrets into AI chats.
- Do not commit `.env`, credentials, customer data, database dumps, or private tokens.
- Project initialization may add `.ai/` files to a repo; review before committing.

## Global Files

The installer may update:

- `~/.codex/AGENTS.md`
- `~/.claude/CLAUDE.md`
- `~/.agents/skills`
- `~/.codex/skills`
- `~/.claude/skills`
- `~/.claude/commands`

Backups of global bootstraps are saved under:

```text
~/.agents/backups/
```

## Uninstall

```bash
./install.sh --dry-run --uninstall
./install.sh --uninstall
```

To restore global bootstrap files from a backup:

```bash
./install.sh --restore-backup ~/.agents/backups/<backup-dir>
```
