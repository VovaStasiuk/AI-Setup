# AI Setup Agent Guide

This repository packages a portable Claude + Codex developer workspace. Help users install, customize, or extend it safely.

## First principles

- Do not assume the user has Claude, Codex, Gemini, or all subscriptions.
- Do not overwrite existing global or project files without showing the plan.
- Prefer `./install.sh --dry-run ...` before any real install.
- Preserve user/project-specific instructions.
- Keep global skills small and progressively loaded.
- Use `skill-creator` guidance when adding or editing skills.

## Common tasks

### Explain the setup

Summarize the three layers:

- Global skills in `setup/skills`
- Tool bootstraps in `setup/global-files` and `setup/claude-commands`
- Project starter kit in `setup/project-kit`

Explain that project instructions override global skills.

### Install globally

Recommend dry-run first:

```bash
./install.sh --dry-run --all
```

Then install the selected route:

```bash
./install.sh --all
./install.sh --claude
./install.sh --codex
```

Use `--copy` when symlinks are undesirable.

### Initialize a project

Recommend:

```bash
./install.sh --dry-run --init-project /path/to/project
./install.sh --init-project /path/to/project
```

If the project already has `AGENTS.md`, `CLAUDE.md`, or `.ai/`, explain that existing files are skipped unless `--force` is used. Do not recommend `--force` until the user has reviewed the existing files.

### Customize for a team

Adjust these first:

- `setup/project-kit/.ai/commands.md`
- `setup/project-kit/.ai/tech-stack.md`
- `setup/project-kit/.ai/DESIGN.md`
- `setup/global-files/AGENTS.md`
- `setup/global-files/CLAUDE.md`

Avoid putting project-specific stack details into global skills.

### Clarify a vague feature or decision

Use `grill-with-context` before planning. It should inspect relevant project
docs/code, ask one focused question at a time, clarify shared language, and ask
whether to propose doc updates at the end. Keep `grill-me` only as a backward
compatible alias.

### Add a new skill

Use `skill-creator` principles:

- Create only `SKILL.md` unless references/scripts are genuinely needed.
- Keep frontmatter `name` and `description` precise.
- Keep the body compact.
- Put long details in `references/`.
- Add the skill to `profiles/core.json` only if it is broadly useful.
- Add a Claude command wrapper only if it maps to a common user action.

### Add a profile

Profiles should extend install choices without bloating the default setup.

Create a JSON file in `profiles/` and document it in `docs/profiles.md`. Planned profiles:

- `saas`
- `enterprise`
- `mobile`

## Validation checklist

After changes:

```bash
./install.sh --dry-run --all
./install.sh --dry-run --init-project /tmp/ai-setup-test
```

Also check:

- every skill has `SKILL.md`
- `profiles/core.json` lists installed core skills
- README examples still match installer options
- Claude command wrappers match their target skill names
- no `.DS_Store`, secrets, local absolute machine-specific assumptions, or generated junk

## Useful paths

- `README.md` - human-facing overview
- `install.sh` - installer
- `setup/skills` - global skills
- `setup/global-files` - Claude/Codex global bootstraps
- `setup/claude-commands` - Claude command wrappers
- `setup/project-kit` - files copied into projects
- `docs/architecture.md` - design of this setup
- `docs/project-onboarding.md` - project install guide
- `docs/profiles.md` - profile strategy
