# AI Assistant Guide

Use this guide when an AI assistant is helping a developer install, customize, or extend AI Setup.

## Recommended conversation flow

1. Ask what environment they want to support:
   - Claude only
   - Codex only
   - Claude + Codex
   - Claude + Codex + Gemini
2. Ask whether they prefer symlinks or copies.
3. Ask whether they are installing globally, initializing a project, or both.
4. Run `--dry-run`.
5. Explain exactly what will change.
6. Run the real command only after confirmation.
7. Validate the install.

## Install choices

Global install. Copy mode is default and lets the user delete the cloned/downloaded repo later:

```bash
./install.sh --dry-run --all
./install.sh --all
```

Claude only:

```bash
./install.sh --dry-run --claude
./install.sh --claude
```

Codex only:

```bash
./install.sh --dry-run --codex
./install.sh --codex
```

Project init:

```bash
./install.sh --dry-run --init-project /path/to/project
./install.sh --init-project /path/to/project
```

Health check:

```bash
./install.sh --doctor
```

Update:

```bash
./install.sh --dry-run --update
./install.sh --update
```

Uninstall:

```bash
./install.sh --dry-run --uninstall
./install.sh --uninstall
```

Restore backup:

```bash
./install.sh --restore-backup ~/.agents/backups/<backup-dir>
```

Project audit:

```bash
./install.sh --audit-project /path/to/project
```

Project standardization:

```bash
./install.sh --standardize-project /path/to/project
```

Use this when the user wants `AGENTS.md`, `CLAUDE.md`, `.agents`, `.claude`, `.codex`, `.ai`, and styleguides made consistent. The command is only inventory. The AI must then inspect actual file contents, compare drift/conflicts/missing rules, produce prioritized recommendations with evidence and exact proposed changes, and ask before edits.

Maintainer link mode:

```bash
./install.sh --all --link
```

## Existing projects

Before project init, inspect:

- `AGENTS.md`
- `CLAUDE.md`
- `.ai/`
- `.claude/`
- `.codex/`
- README and package/stack files

If files exist, merge manually or let installer skip them. Avoid `--force` unless the user explicitly wants replacement.

## Customization rules

Global skills should remain reusable across projects. Put stack-specific rules in project files or future profiles.

Good global skill content:

- planning workflow
- review behavior
- design-source gate
- routing rules
- handoff format

Bad global skill content:

- "always use Next.js"
- "always use Tailwind"
- "always use this company's design"
- project-specific commands

For vague feature, product, architecture, or design requests, use
`grill-with-context` before planning. It should clarify shared language from
existing project docs/code when available and ask before proposing file updates.

## Adding skills

Use `skill-creator` principles:

- Short `SKILL.md`
- Precise trigger description
- References only when needed
- No extra README per skill
- No duplicated long instructions

After adding a skill:

- Add it to `profiles/core.json` if broadly useful.
- Add a Claude command only if there is a clear slash-command workflow.
- Update README/workflow examples if the new skill changes the recommended path.
- Run installer dry-runs.

## Answering user questions

If the user asks "what should I install?", recommend:

- `--claude` if they only use Claude Code
- `--codex` if they only use Codex
- `--all` if they use both
- `--copy` if they want a self-contained setup without symlinks

If they ask "will this work without Gemini?", answer yes. Gemini routes are optional and degrade gracefully.

If they ask "will this pollute context?", explain that only short global bootstraps and skill metadata load by default; detailed references load only when a skill triggers.

If they ask "can I delete the cloned repo?", check `~/.agents/ai-setup/install.json`. Copy mode means yes. Link mode means no.
