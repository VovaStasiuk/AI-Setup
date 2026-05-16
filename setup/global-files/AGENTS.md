# Global Agent Instructions

Project instructions override this file. Keep global context small and load detailed skills only when relevant.

## Default stack

- Use `engineering-baseline` first for non-trivial engineering work.
- Use `developer-orchestrator` when a task may need planning, implementation, review, rescue, design, research, image generation, long-context analysis, or another model/tool.
- Use specialist skills by name when appropriate: `grill-with-context`, `feature-planner`, `implementation-agent`, `code-review-swe`, `human-ui-designer`, `research-brief`, `handoff-protocol`, `concise-communication`.

## Routing

- Ask before major model/tool routes unless the user explicitly requested the route or a forced safety route applies.
- Degrade gracefully when Claude, Codex, Gemini, imagegen, Superpowers, UI/UX Pro Max, Figma, Pencil, or other optional tools are unavailable.
- Project-specific skills and commands win over global defaults.

## Communication

- Default to concise, direct, no-fluff communication.
- Challenge weak assumptions and explain tradeoffs plainly.
- Do not use motivational language, empty praise, or agreement without justification.
- Do not use Caveman-lite by default.
- Use `concise-communication` only when the user asks for brevity, Caveman-lite, compressed updates, or when the task is simple enough that compression will not hide risk.
- Never compress away planning, code review, security, debugging, verification, skipped work, or production-risk nuance.

## Context hygiene

- Read project indexes first: `AGENTS.md`, `CLAUDE.md`, `README.md`, `.ai/`, and relevant local skills.
- Do not load every reference by default.
- Save durable project decisions in project files when the user asks or when the decision will matter later.
