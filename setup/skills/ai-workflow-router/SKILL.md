---
name: ai-workflow-router
description: Route users to the right AI Setup workflow, skill, or slash command. Use when the user asks what to do next, which workflow to use, how to start, or has a request that could be install, configure, plan, implement, review, debug, design, research, memory capture, or handoff.
---

# AI Workflow Router

Use this to choose the next workflow. Do not replace the specialist skills; route to them.

## First pass

1. Identify the request type from the user's prompt and current repo state.
2. Inspect cheap local context only when it changes the route: `AGENTS.md`, `CLAUDE.md`, `.ai/`, README, command files, or obvious error/diff/spec inputs.
3. Recommend one primary route and one fallback when useful.
4. Give the exact command or prompt the user can run.
5. If the user asked you to proceed, invoke the chosen skill instead of stopping at routing.

Ask a short question only when two routes are genuinely tied and the answer changes the next action.

## Route map

| Situation | Route |
|---|---|
| Install, update, uninstall, doctor, source deletion, project init, project configuration, project AI audit | `ai-setup-manager` or `/ai-setup*` command |
| "I just initialized this project" or blank starter `.ai` files | `/ai-setup-configure-project` |
| "What should I use?" or unclear workflow choice | `ai-workflow-router` |
| Vague feature, product idea, architecture decision, migration, or design decision | `grill-with-context` |
| Requirements are stable and need a plan/spec | `feature-planner` or `/plan-feature` |
| Conversation or approved plan needs a stable spec | `to-spec` or `/to-spec` |
| Plan, spec, PRD, or backlog needs small implementation tickets | `to-tickets` or `/to-tickets` |
| Clear implementation task or approved plan | `implementation-agent` or `/implement` |
| Test-first implementation, test seam choice, or weak-test concern | `tdd-seams` through `implementation-agent` |
| Error, stack trace, failing command, failing test, console output, or regression | `debugging-investigator` or `/debug-error` |
| Code, diff, plan, PR, or implementation review | `code-review-swe` or `/review-code` |
| UI screen, redesign, polish, design critique, or "make it look better" | `human-ui-designer` or `/design-ui` |
| Pencil, `.pen`, editable mockup, or Pencil design-to-code | `human-ui-designer`, then `pencil-design` |
| Current/source-backed research, library/API choice, competitor/reference research | `research-brief` or `/research` |
| Durable project rule, command, style, design, or architecture knowledge should be saved | `project-memory-curator` or `/project-memory` |
| Cross-agent/session continuation, review packet, Codex handoff, or context compaction | `handoff-protocol` or `/handoff-codex` |
| Multiple major tools/models could apply | `developer-orchestrator` |
| User explicitly wants terse replies | `concise-communication` |

## Output

When only routing, respond with:

- Recommended route.
- Why this route fits.
- Exact command or prompt to use.
- Fallback route, if the preferred route is unavailable.
- What the route should produce.

Keep the answer short. Do not list the whole route map unless the user asks.
