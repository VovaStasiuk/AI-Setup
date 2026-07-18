# Team Onboarding Usability Test

Use this protocol before rolling AI Setup out broadly. It requires two real participants: one who uses only Claude Code and one who uses only Codex. A facilitator observes but does not coach unless the participant is about to make an unsafe or unintended change.

Automated tests can prove that commands work in isolated environments. They cannot prove that a new teammate understands which command to choose, what a dry-run means, or when approval is required.

## Prepare The Sessions

- Use teammates who have not previously installed AI Setup.
- Give each participant the repository URL and the project path, but do not preselect commands for them.
- Use a non-production project or disposable test repository for project init.
- Record the intended team profile, install mode, and approved version/tag before starting.
- Ask permission before recording screens or copying terminal output.

Run separate sessions for:

1. Claude only, using `/ai-setup-onboard-team` when the participant discovers or chooses it.
2. Codex only, using the README and the prompt `Use ai-setup-manager to configure this project after AI Setup init.`

## Participant Tasks

Ask the participant to complete these tasks without step-by-step help:

1. Find the correct Claude-only or Codex-only path.
2. Choose `core`, `saas`, `enterprise`, or `mobile` for the supplied project and explain why.
3. Choose copy or link mode and explain whether the source clone can be deleted.
4. Run the exact global dry-run and describe what it would change.
5. Decide whether to approve the real global install.
6. Run `./install.sh --doctor` and `./install.sh --status`, then explain the results.
7. Run the profiled project-init dry-run against the supplied project.
8. Identify files that will be added or skipped and avoid `--force`.
9. Approve project init only after reviewing the dry-run.
10. Start project configuration and wait for a `Configured Project Plan` before approving writes.

Stop the session if a participant is about to overwrite existing instructions, target the wrong project, or run a mutating command they do not understand. Record the intervention as a failed safety signal.

## Observation Sheet

Use one row per task or hesitation:

| Task | Time | Completed Without Help | What The Participant Expected | What Happened | Confusing Text Or Command |
|---|---:|---|---|---|---|
| Choose tool path | | Yes/No | | | |
| Choose profile | | Yes/No | | | |
| Choose mode | | Yes/No | | | |
| Global dry-run/install | | Yes/No | | | |
| Doctor/status | | Yes/No | | | |
| Project dry-run/init | | Yes/No | | | |
| Configure project | | Yes/No | | | |

Also capture the participant's exact words at points of confusion. Do not convert observations into assumed causes during the session.

## Pass Criteria

The onboarding flow is ready for team rollout only when both participants can:

- Select the correct tool flag, team profile, and install mode without facilitator instructions.
- Explain the difference between a dry-run and a mutating command.
- Recognize skipped existing files as preserved instructions, not an error to bypass with `--force`.
- Complete doctor and status checks and identify a reported problem.
- Reach project configuration without approving writes before the configuration plan.
- Finish without an unsafe facilitator intervention.

Treat any unsafe mutation, wrong-project init, unexplained `--force`, or approval-before-review behavior as a blocking onboarding defect. Treat repeated hesitation or coaching as a documentation defect even if the commands eventually succeed.

## Turn Findings Into Changes

For each finding, record:

- Evidence: task, exact text, terminal output, or observed action.
- Impact: blocked, unsafe, misleading, or merely slow.
- Proposed destination: README, team guide, wrapper, installer output, or validation.
- Smallest proposed change.
- How the next fresh-user session will verify it.

Re-run only the affected session after small wording fixes. Re-run both paths after command, profile, mode, or approval-flow changes.
