# Refresh your setup

Run these from your clone of this repo when the team announces a new version.

```bash
git pull
cat VERSION
./install.sh --status            # what differs from the repo, nothing is changed
./install.sh --dry-run --update  # preview
./install.sh --update            # skills, commands, global files, installed mods
```

Restart Claude Code and Codex afterwards.

## What changes on your machine

- **Skills and commands** are refreshed. Skills that were removed from the repo are retired, with a copy in `~/.agents/backups/`.
- **Global files** (`~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`) are written as a managed block between `<!-- ai-setup:begin -->` and `<!-- ai-setup:end -->`. Anything you write outside the block is kept. Put your personal rules (model choices, habits) below the block.
- **Mods** installed with `--mods` have their files refreshed. Which mods are enabled is not changed; edit `enabledPlugins` in `~/.claude/settings.json` or re-run `./install.sh --claude --mods <list>`.

## First time with mods

```bash
./install.sh --dry-run --claude --mods
./install.sh --claude --mods                     # cockpit, cheap-lane, relay, file-guard
./install.sh --claude --mods house-rules         # opt-in git/worktree guard
```

## Careful if your global file is old

If your global file has no markers and starts with `# Global Claude Instructions` or `# Global Agent Instructions`, the installer treats it as a previous AI Setup file and replaces it (a backup is made first). If you added personal rules to such a file, move them below a line of your own first, or restore them from the backup after the update.
