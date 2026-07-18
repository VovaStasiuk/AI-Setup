# Developer Workflow

This setup is a workflow system for Claude, Codex, Gemini, or any subset of them. It keeps context small while giving agents clear behavior.

## Mental Model

```text
engineering-baseline
  -> default engineering judgment

developer-orchestrator
  -> choose who/what should handle the task

specialist skills
  -> planning, implementation, review, design, research, handoff

project files
  -> actual stack, commands, styleguide, design, architecture
```

Project files override global skills.

## Skill Map

| Skill | Use When | Output |
|---|---|---|
| `ai-workflow-router` | User asks what workflow, skill, or command to use | Recommended route, exact command/prompt, fallback |
| `ai-setup-manager` | Manage install, update, project init/configuration, audits, or source deletion questions | Safe install/project setup guidance |
| `engineering-baseline` | Any non-trivial engineering task | Simple, scoped, evidence-driven behavior |
| `developer-orchestrator` | More than one route/tool may apply | Route recommendation and fallback |
| `grill-with-context` | Idea is vague or needs pressure-testing, especially inside a codebase | Decisions, shared language, candidate doc updates, open questions, next route |
| `grill-me` | Backward-compatible alias for old "grill me" prompts | Routes to `grill-with-context` when available |
| `domain-modeling` | Terms, lifecycle/status language, ownership, scope, or naming is ambiguous | Shared vocabulary, overloaded terms, proposed `.ai/domain.md` update |
| `feature-planner` | Feature/change needs a spec or plan | Decision-complete plan with tests |
| `to-spec` | Conversation or approved plan needs a stable spec | Decision-complete spec with assumptions, testing decisions, and next step |
| `to-tickets` | Spec/plan/PRD/backlog needs small implementation tickets | Ordered tracer-bullet tickets with blocking edges and verification |
| `implementation-agent` | Plan or task is ready to build | Scoped implementation + verification |
| `tdd-seams` | Implementation needs test-first feedback or a test seam decision | Public seam, focused failing check, narrow verification |
| `debugging-investigator` | User reports/pastes an error, failing test, or console output | Evidence-based diagnosis and next check |
| `code-review-swe` | Code/plan/diff needs review | Findings first, spec axis, standards axis, test gaps |
| `project-memory-curator` | Reusable project knowledge should be saved | Approved, sourced updates to project docs/styleguides |
| `human-ui-designer` | UI/design work or polish | Design contract + screenshot QA loop |
| `pencil-design` | Pencil MCP or `.pen` files are involved | Editable mockup/design-to-code workflow |
| `research-brief` | Need current/source-backed research | Recommendation, evidence, tradeoffs |
| `handoff-protocol` | Work moves between agents/sessions | Handoff packet with context and exact ask |
| `concise-communication` | User wants shorter replies | Compact communication without losing risk detail |

## Standard Flows

### Choose A Workflow

```text
engineering-baseline
-> ai-workflow-router
-> recommended specialist skill or command
```

Use this when the user asks what to do next, which command to run, or which skill fits a request.

### Vague Feature Idea

```text
engineering-baseline
-> grill-with-context
-> domain-modeling when shared language is unclear
-> to-spec
-> to-tickets if the spec is too large for one implementation pass
-> plan review
-> implementation-agent
-> tdd-seams inside implementation for executable behavior
-> code-review-swe
```

### Clear Feature Request

```text
engineering-baseline
-> developer-orchestrator
-> feature-planner
-> domain-modeling when terms, ownership, scope, or states affect the plan
-> vertical slice plan for full-stack work
-> to-spec for a stable implementation contract
-> to-tickets for tracker-ready or multi-agent slices
-> implementation-agent
-> tdd-seams inside implementation for executable behavior
-> verification
-> code-review-swe
```

For large Claude Code work, `feature-planner` may recommend Superpowers. For Codex-only work, it uses the custom planner.

For features spanning backend and frontend, default to vertical slices. Build the smallest backend contract and matching frontend workflow together, verify it end-to-end, then move to the next slice. Use backend-first horizontal phases only when a real dependency is documented.

### Bug Fix

```text
engineering-baseline
-> debugging-investigator
-> focused reproduction/test
-> tdd-seams for the regression seam
-> fix
-> verification
-> code-review-swe if risk warrants it
```

If the same failure happens twice, route to rescue when available.

### UI / Product Design

```text
engineering-baseline
-> human-ui-designer
-> design-source gate
-> identify golden local examples when existing UI is available
-> bounded design-intelligence pass only for unresolved choices
-> theme discovery if palette/typography/direction is unclear
-> DESIGN.md or feature DESIGN.md if needed
-> design contract including responsive, accessibility, interaction, and motion rules
-> pencil-design if Pencil/.pen is the selected route
-> implementation
-> screenshot + interaction + accessibility + motion verification
```

The agent must not guess visual style when project design direction is unclear.

When existing UI is available, the agent should extract rules from 2-5 golden local examples before designing. This prevents generic AI-looking screens and avoids treating old mockups or external screenshots as global style.

For theme discovery, the agent may suggest 3-5 directions inspired by getdesign.md or awesome-design-md, including palette, typography, density, component feel, and anti-patterns. The chosen direction must be converted into `DESIGN.md` before coding.

UI/UX Pro Max may be used as an optional design-intelligence source for focused palette, typography, layout, stack, accessibility, data-visualization, or motion questions. It must not replace project sources, self-certify its recommendations, write generated design files, add dependencies, or install/update itself without confirmation. Accepted recommendations belong in the project design contract and must still be verified against the running UI.

### Research

```text
engineering-baseline
-> research-brief
-> sources/current docs
-> recommendation
-> feature-planner or implementation-agent
```

### Cross-Agent Handoff

```text
engineering-baseline
-> handoff-protocol
-> receiving agent/tool
```

The handoff must include goal, constraints, relevant files, decisions, commands run, risks, and the exact ask.

## Tool Routing Defaults

| Task | Preferred Route |
|---|---|
| Large/vague planning in Claude | Claude + Superpowers, after confirmation |
| Domain vocabulary or overloaded terms | `domain-modeling` |
| Codex-only planning | `feature-planner` custom flow |
| Test-first implementation | `implementation-agent` + `tdd-seams` |
| Adversarial review | Codex when available |
| Rescue after repeated failure | Codex when available |
| Whole-repo or huge context scan | Gemini when available |
| Audio/video/large PDF | Gemini when available |
| Raster image generation/editing | imagegen when available |
| Pencil/.pen mockup or design-to-code | `human-ui-designer` + `pencil-design` |
| Product UI direction | `human-ui-designer` + project `DESIGN.md` |

Unavailable routes should degrade gracefully.

Note: `imagegen` is usually an agent skill/tool route, not a shell command. Claude should check for Codex/imagegen handoff before falling back to SVG/Pencil/external prompts.

## Project Files

Every serious project should eventually have:

```text
AGENTS.md
CLAUDE.md
.ai/project-context.md
.ai/agent-workflow.md
.ai/issue-tracker.md
.ai/domain.md
.ai/tech-stack.md
.ai/commands.md
.ai/DESIGN.md
.ai/styleguide.md
.ai/specs/
.ai/tickets/
.ai/decisions/
```

Keep `AGENTS.md` and `CLAUDE.md` as indexes. Put details in `.ai/` files.

## Memory And Context Rules

- Do not paste full docs into every conversation.
- Store durable project decisions in `.ai/decisions/`.
- Store durable vocabulary and overloaded terms in `.ai/domain.md`.
- Store feature specs in `.ai/specs/`.
- Keep global skills reusable and project-neutral.
- Put stack commands and styleguide details in project files.
- Use `project-memory-curator` to propose, not silently write, reusable project knowledge.
- Default communication is concise, direct, and no-fluff.
- Use `concise-communication` only when the user asks for brevity or the answer is simple enough that compression will not hide risk.
- Do not use Caveman-lite by default.
- Do not compress away planning, review, security, debugging, verification, skipped work, or production-risk nuance.

## Critical Thinking

You do not need to paste a "do not blindly agree" prompt into every session. `engineering-baseline` already instructs agents to challenge assumptions, call out weak ideas, compare tradeoffs, identify production failure modes, and ask targeted questions when information is missing.

## Evidence And Anti-Fabrication

Agents must not claim they read files, ran commands, verified behavior, or checked current docs unless they actually did. Pasted errors should route through `debugging-investigator`: preserve the concrete failure, inspect relevant project context, form hypotheses, run or recommend the cheapest verification step, and state what remains unverified.

## Completion Contract

For non-trivial work, final responses must make completion explicit:

- Completed: what was actually delivered.
- Verified: exact checks run and results.
- Not done / skipped: what was skipped, why, and the risk.
- Next step: required follow-up only when something remains.

Do not say "done" if required scope remains incomplete. If verification was skipped because the environment was unavailable, say that directly.

For implementation work, run a local final review pass before the final response. Compare the request/plan against actual changes, inspect changed files or diff when available, and decide whether external/adversarial review is needed.

For executable behavior, prefer seam-first feedback: identify the public seam, add or name the focused failing check where practical, implement one vertical slice, and run the focused verification before moving on.

## Worked Examples

Use [examples/workflows/configure-project](../examples/workflows/configure-project) as the reference shape for first-run project configuration after init.

Use [examples/workflows/billing-settings](../examples/workflows/billing-settings) as the reference shape for a complete feature workflow:

```text
grill-with-context
-> to-spec
-> to-tickets
-> implementation-agent with tdd-seams
-> code-review-swe
```

The example is intentionally framework-neutral. Real projects should replace placeholder verification commands with commands from `.ai/commands.md` and keep project facts in the local `.ai/` directory.

## Example Prompts

```text
/ai-workflow what should I use for this?
```

```text
/ai-setup-doctor
```

```text
/ai-setup-init set up this project
```

```text
/ai-setup-configure-project
```

`/ai-setup-configure-project` should inspect the repo after init, draft `.ai/project-context.md`, `.ai/agent-workflow.md`, `.ai/issue-tracker.md`, `.ai/domain.md`, `.ai/tech-stack.md`, `.ai/commands.md`, `.ai/DESIGN.md`, `.ai/styleguide.md`, and styleguide updates from evidence, then ask before writing. Commands should be marked verified only when actually run or sourced from trusted project docs/CI.

When `.ai/profile.md` exists, `/ai-setup-configure-project` should read it and tailor gaps/questions to the selected profile. It should present a `Configured Project Plan` with inspected evidence, detected profile, proposed writes, verified vs candidate commands, design-source status, unknowns, and risk before editing.

```text
/ai-setup-audit check this repo's AI setup
```

```text
/ai-setup-standardize make Claude, Codex, and project AI instructions consistent
```

`/ai-setup-standardize` should not stop at the shell report. The AI must inspect the actual instruction files, skills, styleguides, and `.ai` files, then produce prioritized recommendations with evidence, impact, destination, exact proposed change, and risk before editing.

```text
Use grill-with-context to pressure-test this idea before we plan.
```

```text
Use domain-modeling to clarify these terms before writing the spec.
```

```text
Use feature-planner to plan the billing settings page.
```

```text
/to-spec turn this conversation into a spec.
```

```text
/to-tickets split this approved spec into small implementation tickets.
```

```text
Use human-ui-designer to design this page. If design direction is unclear, ask before creating DESIGN.md.
```

```text
Use implementation-agent to implement the approved plan and run focused checks.
```

```text
Use code-review-swe to review this diff against the ticket and project standards.
```

```text
Use handoff-protocol to prepare a Codex review packet.
```
