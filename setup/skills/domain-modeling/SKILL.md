---
name: domain-modeling
description: Clarify and maintain project domain language. Use when requirements, specs, tickets, code, tests, UI labels, or reviews involve ambiguous terms, overloaded words, naming choices, lifecycle/status semantics, permissions, ownership, or durable vocabulary that belongs in `.ai/domain.md`.
---

# Domain Modeling

Use this as a model-invoked discipline. It helps agents speak the project language consistently and avoid inventing or drifting domain terms.

## Inputs

Inspect only what is relevant:

- `.ai/domain.md`
- `.ai/project-context.md`
- `.ai/specs/`, `.ai/tickets/`, and `.ai/decisions/`
- nearby code, tests, API names, database names, UI labels, or docs where the terms appear

If no domain file exists, propose one through `project-memory-curator` rather than silently creating it.

## Flow

1. Identify the terms that matter for the current task.
2. Check whether each term already has a project meaning.
3. Detect overloaded words: one label used for different concepts, states, actors, scopes, or lifecycle phases.
4. Prefer names already established in product docs, APIs, database models, tests, and UI labels.
5. When naming a new concept, choose a term that exposes domain meaning, not implementation detail.
6. If durable vocabulary should be saved, propose a `.ai/domain.md` update through `project-memory-curator`.

Do not rename code or docs only to improve taste. Rename only when ambiguity creates delivery risk, test confusion, UI confusion, or repeated translation cost.

## What to capture

Good `.ai/domain.md` candidates:

- product/business terms that recur across features;
- actors, roles, ownership, tenant/account/team scope;
- lifecycle statuses and allowed transitions;
- overloaded words and the preferred replacement for each meaning;
- naming conventions for files, specs, tickets, tests, UI labels, APIs, or database fields;
- links to decisions when a term is tied to an architecture or product tradeoff.

Avoid capturing:

- one-off feature wording;
- speculative future names;
- private implementation helper names;
- terms already obvious from the language/framework.

## Output

When used explicitly, return:

- Terms inspected.
- Ambiguities or overloaded terms.
- Recommended vocabulary.
- Proposed `.ai/domain.md` update, if durable.
- Whether approval is needed before writing.
