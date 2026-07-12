# Project Onboarding

Use this when adding AI Setup to an existing project.

## 1. Dry-run

```bash
./install.sh --dry-run --init-project /path/to/project
```

For a project-type starter overlay:

```bash
./install.sh --dry-run --profile saas --init-project /path/to/project
```

## 2. Initialize

```bash
./install.sh --init-project /path/to/project
```

Or with a profile:

```bash
./install.sh --profile saas --init-project /path/to/project
```

Existing files are skipped by default. Use `--force` only after reviewing diffs.

## 3. Configure Project Facts

In Claude, use:

```text
/ai-setup-configure-project
```

The assistant should inspect existing docs, configs, source layout, commands, design sources, and styleguides, then draft updates before writing.

For Codex or another assistant, ask:

```text
Use ai-setup-manager to configure this project after AI Setup init.
```

Review the proposed changes before approving writes.

## 4. Fill Or Review Project Files

Update:

- `.ai/project-context.md`
- `.ai/profile.md` if a profile was installed
- `.ai/agent-workflow.md`
- `.ai/issue-tracker.md`
- `.ai/domain.md`
- `.ai/tech-stack.md`
- `.ai/commands.md`
- `.ai/styleguide.md`

The project kit includes starter Django and React styleguides under `.agents/skills/styleguides/`. Keep only the sections that match the project stack and customize them from real code patterns.

## 5. Define Design Source

Update `.ai/DESIGN.md`.

If the project already has a design system, summarize it there and link to the source.

If not, answer:

- Who uses this product?
- What workflows matter most?
- What density is expected?
- What should the UI feel like?
- What should the UI avoid?
- What components already exist?

## 6. Keep AGENTS.md Small

Use `AGENTS.md` as an index. Do not paste every rule into it.

## 7. Use The Workflows

Examples:

```text
Use grill-with-context to pressure-test this idea before we plan.
Use feature-planner to plan this feature.
Use to-spec to turn the clarified plan into a spec.
Use to-tickets to split the spec into implementation tickets.
Use implementation-agent to implement the approved plan.
Use code-review-swe to review this diff against the ticket and project standards.
Use human-ui-designer to design this page.
```
