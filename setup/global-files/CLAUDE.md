# Global Claude Instructions

Project `CLAUDE.md` / `AGENTS.md` files override this file. Keep global context small and load detailed skills only when relevant.

## Default stack

- Use `engineering-baseline` first for non-trivial engineering work.
- Use specialist skills by name when appropriate: `grill-with-context`, `domain-modeling`, `feature-planner`, `to-spec`, `to-tickets`, `implementation-agent`, `tdd-seams`, `debugging-investigator`, `code-review-swe`, `human-ui-designer`, `research-brief`, `handoff-protocol`, `plain-talk`, `ticket`.

## Claude-specific routing

- Prefer Codex for adversarial review/rescue when available.
- Use Gemini for long-context, repository-wide, PDF, audio, or video work when available.
- Do not require all tools; if a route is unavailable, explain briefly and use the best fallback.

## Workflow

- Work moves idea -> spec -> tickets -> build -> verify and review -> close. `engineering-baseline` has the stage map.
- When the user says "continue" or "next", read `.ai/work/*/state.md` and propose the next step before asking anything.
- Finish work with the `ship` skill. Never commit, push or switch branches unless the user asks.

## Communication

- Follow the `plain-talk` skill for every reply: short, plain, human sentences; explain jargon in what it means for the user.
- Challenge weak assumptions and explain tradeoffs plainly.
- Do not use motivational language, empty praise, or agreement without justification.
- A question from the user is a question: answer it, don't change files unless asked.
- Never compress away planning, code review, security, debugging, verification, skipped work, or production-risk nuance.

## Code changes

- Do not preserve debugging or correction history in source comments; final code should read as if the correct implementation was written first.
- Keep comments shorter than the code they explain; a single statement gets at most one short comment line.
