---
name: ticket
description: Lock work to what a ticket actually asks for. Use when the user runs /ticket <ID> or starts work on a Plane or Linear ticket. Pulls the ticket and every comment into a requirements checklist with sources, refuses work nobody asked for, and keeps a per-ticket log of what was built and posted.
---

# Ticket scope

Work only on what the ticket and its comments ask for. Every requirement has a source.

## 1. Load the ticket

- **Plane:** use the Plane MCP tools: `workitem` retrieve by identifier, then `workitem_comment` list, plus links and sub-items. If a tool seems to fail, retry once and check the parameters before saying it can't be done.
- **Linear or other:** use a connected tool if there is one; otherwise ask the user to paste the ticket and its comments.
- Read every comment. Later comments override earlier ones.

## 2. Write the log

Create or update `<repo>/.ai/tickets/<ID>.md`:

```
# <ID> — <title>
Source: <link>   Loaded: <date>

## Requirements
- [ ] R1 <requirement> — source: description | comment by <name> on <date>
- [ ] R2 ...

## Can't / blocked
- R? <why> — what is needed from whom

## Out of scope (asked nowhere)
- <ideas noticed but not requested>

## Built
- <date> <what changed> (files, dashboards, IDs)

## Posted
- <date> <comment or message sent, where>
```

## 3. Rules while working

- Do not add features, blocks, fallbacks or "improvements" that no requirement names. Put them under "Out of scope" and mention them once at the end.
- If something is ambiguous, ask one plain question instead of guessing.
- Name where a fact came from when you state it (ticket, comment, code, data). Never invent lists, limits or numbers.
- Before saying the ticket is done, go through the checklist: each item done (with how it was checked), can't, or still open. Say plainly what is still open.
- Update "Built" and "Posted" as you go, so the next session can see what happened without asking.

## 4. Report

Short and plain: which requirements are done and how they were checked, which are blocked and why, what you propose next.

## Workflow state

Read the work item's state file at the start and, at the end, set `stage`, `done` and `next` as described in `engineering-baseline/references/workflow-state.md`.
