# Workflow State

One small file per piece of work tells every session, in any tool, where the work is and what comes next. The developer should never have to re-explain it.

## Where

`.ai/work/<slug>/state.md` in the project repo. Create it when a request will take more than one session or more than one stage. Skip it for questions and one-file fixes.

## Format

```markdown
# <short title>
stage: idea | spec | tickets | build | verify | review | close
updated: YYYY-MM-DD
ticket: <ID or none>
decided: <decisions that are settled, one line each>
open: <questions still unanswered>
done: <what is finished>
next: <one sentence, plus the skill to use>
```

## Rules

- At the start of a session, or when the user says "continue", "next" or "where were we", read the most recently updated state file that is not `stage: close`. Say: "Resuming <title> at <stage>. Next: <next>." Then wait for a yes or a correction.
- At the end of every stage skill, set `stage`, `updated`, `done` and `next`. One edit, no ceremony.
- Link specs, tickets and handoffs from the state file instead of copying them into it.
- Keep it under 30 lines. Durable decisions go to `.ai/decisions/`, not here.
- If two state files are open and the user's request does not say which, ask which one.
