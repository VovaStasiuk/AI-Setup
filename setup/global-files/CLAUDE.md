# Global Claude Instructions

Project `CLAUDE.md` / `AGENTS.md` files override this file. Keep global context small and load detailed skills only when relevant.

## Default stack

- Use `engineering-baseline` first for non-trivial engineering work.
- Use `developer-orchestrator` when a task may need planning, implementation, review, rescue, design, research, image generation, long-context analysis, or another model/tool.
- Use specialist skills by name when appropriate: `feature-planner`, `implementation-agent`, `code-review-swe`, `human-ui-designer`, `research-brief`, `handoff-protocol`, `concise-communication`.

## Claude-specific routing

- Prefer Superpowers for large/vague planning when available and the user confirms that route.
- Prefer Codex for adversarial review/rescue when available.
- Use Gemini for long-context, repository-wide, PDF, audio, or video work when available.
- Do not require all tools; if a route is unavailable, explain briefly and use the best fallback.

## graphify

- **graphify** (`~/.claude/skills/graphify/SKILL.md`) - any input to knowledge graph. Trigger: `/graphify`
- When the user types `/graphify`, invoke the Skill tool with `skill: "graphify"` before doing anything else.
