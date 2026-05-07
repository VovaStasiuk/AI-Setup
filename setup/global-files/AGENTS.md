# Global Agent Instructions

Project instructions override this file. Keep global context small and load detailed skills only when relevant.

## Default stack

- Use `engineering-baseline` first for non-trivial engineering work.
- Use `developer-orchestrator` when a task may need planning, implementation, review, rescue, design, research, image generation, long-context analysis, or another model/tool.
- Use specialist skills by name when appropriate: `feature-planner`, `implementation-agent`, `code-review-swe`, `human-ui-designer`, `research-brief`, `handoff-protocol`, `concise-communication`.

## Routing

- Ask before major model/tool routes unless the user explicitly requested the route or a forced safety route applies.
- Degrade gracefully when Claude, Codex, Gemini, imagegen, Superpowers, UI/UX Pro Max, Figma, Pencil, or other optional tools are unavailable.
- Project-specific skills and commands win over global defaults.

## Context hygiene

- Read project indexes first: `AGENTS.md`, `CLAUDE.md`, `README.md`, `.ai/`, and relevant local skills.
- Do not load every reference by default.
- Save durable project decisions in project files when the user asks or when the decision will matter later.
