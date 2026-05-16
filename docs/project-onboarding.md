# Project Onboarding

Use this when adding AI Setup to an existing project.

## 1. Dry-run

```bash
./install.sh --dry-run --init-project /path/to/project
```

## 2. Initialize

```bash
./install.sh --init-project /path/to/project
```

Existing files are skipped by default. Use `--force` only after reviewing diffs.

## 3. Fill Project Facts

Update:

- `.ai/project-context.md`
- `.ai/tech-stack.md`
- `.ai/commands.md`

## 4. Define Design Source

Update `.ai/DESIGN.md`.

If the project already has a design system, summarize it there and link to the source.

If not, answer:

- Who uses this product?
- What workflows matter most?
- What density is expected?
- What should the UI feel like?
- What should the UI avoid?
- What components already exist?

## 5. Keep AGENTS.md Small

Use `AGENTS.md` as an index. Do not paste every rule into it.

## 6. Use The Workflows

Examples:

```text
Use grill-with-context to pressure-test this idea before we plan.
Use feature-planner to plan this feature.
Use implementation-agent to implement the approved plan.
Use code-review-swe to review this diff.
Use human-ui-designer to design this page.
```
