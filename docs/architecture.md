# Architecture

AI Setup has three layers.

## Global Layer

Global skills live in `~/.agents/skills` and are exposed to Claude and Codex.

These skills contain reusable behavior:

- engineering taste
- routing rules
- project-aware requirements interrogation
- planning workflow
- implementation workflow
- review workflow
- design workflow
- research workflow
- handoff protocol

They should not contain project-specific architecture, commands, or styleguide details.

`grill-with-context` is the default interrogation workflow. It may read project
docs and nearby code to clarify terms before planning, but it should only
propose durable doc updates and wait for approval before writing.

## Tool Layer

Claude and Codex get small bootstrap files:

- `~/.claude/CLAUDE.md`
- `~/.codex/AGENTS.md`

These files point to global skills without loading every reference.

Claude also gets optional command wrappers in `~/.claude/commands`.

## Project Layer

Projects get a tiny local kit:

- `AGENTS.md`
- `CLAUDE.md`
- `.ai/project-context.md`
- `.ai/tech-stack.md`
- `.ai/styleguide.md`
- `.ai/DESIGN.md`
- `.ai/commands.md`
- `.ai/specs/`
- `.ai/decisions/`

Project files override global skills.

## Precedence

```text
User request > project instructions > global skills > model defaults
```

## Progressive Disclosure

The global bootstrap should stay short. Detailed references are loaded only after a skill triggers and only when relevant.
