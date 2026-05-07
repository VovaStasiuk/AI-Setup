# Bootstrap Install Prompt

Use this before AI Setup is installed. Paste it into Claude, Codex, or another coding assistant with either a GitHub URL or local folder path.

## Prompt

```text
Install AI Setup from this repo or folder:
<PASTE_REPO_URL_OR_LOCAL_PATH>

First inspect the repo. Do not assume it is safe.

Use this process:
1. Locate `install.sh`, `README.md`, and `setup/`.
2. Explain what the setup installs.
3. Prefer copy mode so I can delete the cloned/downloaded repo later.
4. Run a dry-run first:
   ./install.sh --dry-run --all
5. Explain exactly what will change.
6. Ask for my confirmation before the real install.
7. If I approve, run:
   ./install.sh --all
8. After install, tell me whether the source repo/folder can be deleted.

If I only use Claude, recommend `./install.sh --claude`.
If I only use Codex, recommend `./install.sh --codex`.
If I use both, recommend `./install.sh --all`.

Do not overwrite existing project files with `--force` unless I explicitly ask.
```

## Notes

- Default install mode is copy. Source repo can be deleted after install.
- `--link` is for maintainers who want installed skills to point back to this repo.
- After install, use `ai-setup-manager` for project initialization, audits, updates, and questions.
- To update later from a newer repo copy, run `./install.sh --dry-run --update`, then `./install.sh --update`.
