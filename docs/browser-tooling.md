# Optional Browser Tooling

AI Setup supports [Chrome DevTools MCP](https://github.com/ChromeDevTools/chrome-devtools-mcp) as an opt-in browser debugging and verification capability. It is not installed by `--all` and does not belong to the `core`, `saas`, `enterprise`, or `mobile` project profiles.

Use it when an agent needs evidence from a running web application that source inspection or a basic screenshot cannot provide:

- browser console messages and source-mapped errors
- request/response and network failure inspection
- responsive viewport and interaction checks
- Lighthouse and performance traces
- memory and heap investigation

Prefer an existing in-app browser or project test runner for basic navigation and screenshots. Chrome DevTools MCP is the deeper diagnostic route.

## Requirements

- Claude Code and/or Codex CLI
- Node.js LTS with `npx`
- current stable Google Chrome or Chrome for Testing

AI Setup pins `chrome-devtools-mcp@1.6.0`. Update that pin only as a reviewed repository change with the normal validation suite.

## Install

Choose the client explicitly and review the dry-run first.

Claude only:

```bash
./install.sh --dry-run --chrome-devtools-mcp claude
./install.sh --chrome-devtools-mcp claude
```

Codex only:

```bash
./install.sh --dry-run --chrome-devtools-mcp codex
./install.sh --chrome-devtools-mcp codex
```

Claude and Codex:

```bash
./install.sh --dry-run --chrome-devtools-mcp all
./install.sh --chrome-devtools-mcp all
```

This is independent from the global skill install. Running `./install.sh --all` alone never adds the MCP server.

If a client already has an MCP server named `chrome-devtools`, AI Setup preserves it and does not write an ownership marker. Review or update that registration manually.

## Safe Defaults

AI Setup registers the pinned package with:

```text
--isolated
--no-usage-statistics
--no-performance-crux
```

It also disables the package's update check. The isolated profile is temporary and avoids exposing a normal signed-in Chrome profile by default.

Chrome DevTools MCP can inspect and modify data visible in its browser. Do not connect it to a personal or production-authenticated browser profile, enable a remote debugging port, or expose sensitive customer/session data without explicit approval and a reviewed need.

If authenticated testing is required, use a dedicated test account and dedicated browser profile. Treat remote debugging endpoints as privileged local interfaces.

## Health And Status

When AI Setup creates a registration, it writes an ownership marker under:

```text
~/.agents/ai-setup/capabilities/chrome-devtools-mcp/
```

Then these commands check that the corresponding MCP registration still exists:

```bash
./install.sh --doctor
./install.sh --status
```

These checks do not launch Chrome or prove that a target application works. Verify the capability with a non-sensitive local page before relying on it.

## Remove

AI Setup does not automatically delete external MCP registrations during its general uninstall because the registration may have been customized after installation. Remove it explicitly:

```bash
claude mcp remove --scope user chrome-devtools
codex mcp remove chrome-devtools
```

After removing both registrations, delete the corresponding ownership-marker files if AI Setup is no longer installed.

