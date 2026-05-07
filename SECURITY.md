# Security Policy

## Supported Versions

AI Setup is in alpha (0.x). Only the latest tagged version receives fixes.

## Reporting a Vulnerability

Do not open a public issue for security problems.

Report privately via GitHub's [private security advisory](https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing/privately-reporting-a-security-vulnerability) feature on this repository.

Include:

- Affected file(s) or installer flag(s).
- Reproduction steps.
- Impact assessment (local file overwrite, privilege escalation, data leak, etc.).
- Suggested fix if known.

Expect an acknowledgement within 7 days.

## Scope

In scope:

- `install.sh` behavior (file overwrite, path traversal, unsafe expansion).
- Skill or template content that could exfiltrate data or execute unintended code.
- Backup/restore logic.

Out of scope:

- Behavior of third-party tools (Claude Code, Codex, Gemini).
- User-modified copies.

## Hardening Guidance

See [docs/security.md](docs/security.md) for install-time precautions, data handling, and uninstall steps.
