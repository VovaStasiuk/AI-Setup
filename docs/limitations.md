# Limitations

AI Setup improves agent behavior, but it does not make AI reliably correct.

## What It Cannot Guarantee

- It cannot prevent all hallucinations, shortcuts, or wrong assumptions.
- It cannot guarantee production safety without human review.
- It cannot verify code unless the needed tools, services, data, and permissions are available.
- It cannot make Claude, Codex, Gemini, or other tools support identical features.
- It cannot keep project docs accurate if humans or agents approve bad memory/styleguide updates.

## Operational Limits

- Global skills influence behavior, but project instructions and user prompts still matter.
- Copy installs can become stale until updated.
- Link installs require keeping the source repo.
- `--doctor` checks file presence and basic wiring; it does not prove every skill works perfectly.
- `--audit-project` and `--standardize-project` are heuristic reports, not formal static analysis.

## Recommended Safety Practice

- Dry-run before install/update/project init.
- Use code review for non-trivial changes.
- Use external/adversarial review for security, auth, tenancy, billing, migrations, deployment, and large full-stack work.
- Require the completion contract: completed, verified, skipped, residual risk.
