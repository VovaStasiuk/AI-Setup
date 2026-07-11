---
name: developer-orchestrator
description: Route engineering, planning, review, design, research, rescue, image, multimodal, and handoff tasks across available tools such as Claude, Codex, Gemini, Superpowers, imagegen, UI/UX Pro Max, Figma, Pencil, Open Design, and project skills. Use when deciding who or what should handle a task, especially when multiple agents/tools may be involved. Detect available routes, ask before major handoffs, and degrade gracefully when tools are missing.
---

# Developer Orchestrator

Use `engineering-baseline` first, then use this skill to choose the route. Project instructions override global routing.

## First pass

1. Identify the task type: plan, spec writing, ticket slicing, implement, review, rescue, design, image, research, long-context, multimodal, security-sensitive, or handoff.
2. Inspect available project instructions and relevant skills.
3. Check tool availability when a route depends on a CLI/plugin/tool.
4. Recommend a route and ask before major model/tool handoffs unless a forced route applies.
5. If the task reveals durable project knowledge, route to `project-memory-curator` after the primary task or ask whether to capture it.

If the user pastes an error, stack trace, failing test, build output, or console log, route to `debugging-investigator` before planning broad changes.

## Ask before major routes

Ask before routing planning, design, research, or implementation to another model/tool. Give one recommended option and one fallback.

Do not ask when the user explicitly requested that route or when a forced route applies.

## Forced routes

- Agent self-review of important agent-authored code/plan/design -> external review when available, preferably Codex.
- Same test/command/edit failure twice -> rescue route when available, preferably Codex.
- Risky auth, billing, migrations, deploy, secrets, policy, infrastructure, or security-sensitive changes -> adversarial review before saying done.
- Large audio/video/PDF or huge context scan -> Gemini or long-context route when available.
- Raster image generation/editing -> imagegen route when available.

## Tool checks

Use cheap checks such as `command -v codex`, `command -v claude`, and `command -v gemini` when routing depends on a CLI. If unavailable, explain briefly and offer the best local fallback.

Do not assume every capability is a shell CLI. `imagegen` is usually an agent skill/tool route, not `command -v imagegen`.

For raster image generation/editing:

- In Codex: use the `imagegen` skill/tool directly when available.
- In Claude: check whether Codex is available and whether the Codex setup exposes `imagegen`; if yes, offer a Codex imagegen handoff.
- If Codex/imagegen is unavailable, fallback to SVG/HTML, Pencil/Figma export, or an external image-generation prompt.
- Ask before routing to Codex unless the user explicitly requested it.

For Pencil or `.pen` tasks:

- Route through `human-ui-designer` first for project design-source checks and the design contract.
- Then use `pencil-design` for Pencil MCP, `.pen` editing, export, or design-to-code workflow when available.
- If Pencil is unavailable, offer Figma, HTML/CSS/React prototype, SVG, imagegen, or an external handoff as the fallback.

## References

- Capability priorities: `references/capability-matrix.md`.
- Detailed routing rules: `references/routing-rules.md`.
