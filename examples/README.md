# Examples

These examples show how AI Setup workflows should look after a project has been initialized. They are human-readable fixtures, not runnable application code.

Use them when you want to understand the shape of a good agent-assisted development pass:

```text
grill-notes.md
-> spec.md
-> tickets/
-> implementation-notes.md
-> review.md
```

## Available Walkthroughs

- [SaaS Team Rollout](onboarding/team-rollout.md) - a new teammate installs Claude + Codex support, initializes a SaaS project, and completes approval-gated project configuration.
- [Billing Settings](workflows/billing-settings/) - a small B2B SaaS feature that moves from clarification to spec, tickets, implementation notes, and review.
- [Configure Project](workflows/configure-project/) - an example `Configured Project Plan` after project init with profile-aware gaps and command verification status.

## How To Read These

- Start with `grill-notes.md` to see the decisions that should be clarified before planning.
- Read `spec.md` as the stable implementation contract.
- Read the files in `tickets/` in order; each ticket is small enough for one focused implementation pass.
- Read `implementation-notes.md` for how an agent should choose public seams and verification commands.
- Read `review.md` for the expected review shape after implementation.

Keep real project facts in that project's `.ai/` directory. These examples should stay project-neutral and avoid framework-specific assumptions unless the example explicitly says they are placeholders.
