---
name: ai-setup-manager
description: Manage this AI Setup installation after it has been installed. Use when the user asks to install AI Setup into a project, initialize or audit a repo's AI files, update the setup, find the installer path, explain installed options, check whether the source repo can be deleted, or customize Claude/Codex/global skill setup.
---

# AI Setup Manager

Use this for ongoing management of AI Setup after first install.

## Locate setup

Find the setup in this order:

1. `$AI_SETUP_HOME`
2. `~/.agents/ai-setup/install.json` metadata
3. `~/Documents/Projects/AI Setup`
4. `~/Projects/AI Setup`
5. current directory if it contains `install.sh` and `setup/skills`

If no source repo is found but installed skills exist, explain that project initialization may still work from installed templates if available, but updates require a source repo.

## Common actions

- For global install/update: run `./install.sh --dry-run --update`, explain changes, then ask before applying `./install.sh --update`.
- For project init: run `./install.sh --dry-run --init-project <path>`, explain changes, then ask before applying.
- For global health: run `./install.sh --doctor`.
- For project audit: run `./install.sh --audit-project <path>`, then inspect details manually if needed.
- For project standardization: run `./install.sh --standardize-project <path>`, inspect the reported surfaces, then propose a step-by-step migration before editing.
- For "can I delete the repo?": read install metadata. Copy mode means yes; link mode means no.
- For customization: edit the source repo files, then reinstall/update.

## Standardize project workflow

Use this when the user wants Claude, Codex, `.agents`, `.claude`, `.codex`, `AGENTS.md`, `CLAUDE.md`, styleguides, and `.ai` files to be consistent.

The shell command `./install.sh --standardize-project <path>` is only an inventory report. Do not stop there. Use it as the starting point for a deeper AI-guided standardization pass.

### Required inspection

Read or inspect, when present:

- `AGENTS.md`
- `CLAUDE.md`
- `.ai/`
- `.agents/skills/`
- `.agents/skills/styleguides/`
- `.claude/`
- `.codex/`
- `README.md`
- `Makefile`
- package/config files such as `package.json`, `pyproject.toml`, `tailwind.config.*`, `vite.config.*`

### What to find

Compare for:

- stale/dead references
- duplicated instructions
- conflicting instructions
- missing project commands
- missing or weak design source
- missing project context
- missing tech stack constraints
- Claude-only rules that should be shared
- shared rules that accidentally live only in Claude or Codex config
- styleguides that are missing important actual code patterns
- styleguide claims that appear wrong or unsupported by current code
- project skills that overlap, drift, or duplicate global skills

### Canonical structure to recommend

- `AGENTS.md` as shared index
- `CLAUDE.md` as mirror or small Claude-specific wrapper
- `.ai/` for project context, tech stack, commands, design, specs, decisions
- `.agents/skills/` for project-specific skills and stack/styleguides
- `.claude/` and `.codex/` only for tool-specific config

### Recommendation output contract

For each recommendation include:

- Priority: P0/P1/P2/P3
- Issue
- Evidence: exact file/section or observed pattern
- Why it matters
- Proposed destination
- Exact proposed change
- Risk if wrong
- Approval needed: yes/no

### Execution

Ask before editing. Apply one safe batch at a time.

Suggested batch order:

1. Fix dead/stale references.
2. Create/fill missing `.ai` canonical files from existing repo sources.
3. Normalize `AGENTS.md` / `CLAUDE.md` parity.
4. Document intentional Claude/Codex differences in `.ai/decisions/`.
5. Audit styleguides against actual code patterns.
6. Propose memory/styleguide updates through `project-memory-curator`.

Recommend a canonical structure:
   - `AGENTS.md` as shared index
   - `CLAUDE.md` as mirror or small Claude-specific wrapper
   - `.ai/` for project context, commands, design, specs, decisions
   - `.agents/skills/` for project-specific skills and stack/styleguides
   - `.claude/` and `.codex/` only for tool-specific config

Future extension: generate or improve stack-specific styleguides from actual project code patterns, then ask for review before adopting them.

## Safety rules

- Do not use `--force` unless the user explicitly asks after reviewing conflicts.
- Prefer copy installs for friends and one-time setup.
- Prefer link installs only for maintainers.
- Preserve existing project instructions.
- Use `skill-creator` guidance when adding or modifying skills.
