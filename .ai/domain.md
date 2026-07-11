# Domain

## Terms

- AI Setup: this portable Claude + Codex developer workspace setup.
- Global skills: reusable workflows installed from `setup/skills`.
- Claude command wrappers: slash-command prompts installed from `setup/claude-commands`.
- Project kit: starter files copied from `setup/project-kit` into a target project.
- Profile: an install bundle definition under `profiles/`.
- Spec: stable feature or change contract under `.ai/specs/`.
- Ticket: focused implementation work item under `.ai/tickets/` with blockers and verification.
- Test seam: public boundary where executable behavior is verified.
- Domain modeling: workflow for clarifying shared vocabulary and proposing `.ai/domain.md` updates.

## Overloaded Words

- Skill: reusable model-invoked behavior in `setup/skills`; not the same as a Claude slash command.
- Command: user-invoked Claude wrapper in `setup/claude-commands`; not a shell command unless explicitly shown in a code block.

## Actors And Scope

- Installer user: developer installing AI Setup globally or into a project.
- Maintainer: developer editing this source repo and reinstalling/updating from it.
- Target project: external repo receiving `setup/project-kit`.

## Naming Guidance

Use `specs` for stable feature/change descriptions and `tickets` for focused implementation work items with blockers.
Use `commands` for Claude slash wrappers and `shell commands` for terminal commands.
