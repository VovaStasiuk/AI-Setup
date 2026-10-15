# AI Setup mods

Small Claude Code mods that add behavior around the skills. Install with:

```bash
./install.sh --dry-run --claude --mods
./install.sh --claude --mods                      # cheap-lane, relay, cockpit, file-guard
./install.sh --claude --mods house-rules,cockpit  # pick your own
./install.sh --claude --mods all                  # adds house-rules
```

Restart Claude Code afterwards. `./install.sh --update` refreshes installed mods.

| Mod | What it does | Default |
|---|---|---|
| `cockpit` | Band above the prompt: cache timer, chat size, plan limits and cost with a handoff button; task progress with ETA; `/ship` checklist; clickable next steps | on |
| `cheap-lane` | `/commit-msg` (Haiku), `/quick` (Sonnet), `/explain` (Sonnet) without using the main chat | on |
| `relay` | `/delegate` a task to a fresh implementer through TASK/RESULT files; `/tasks` shows progress | on |
| `file-guard` | Asks before editing a file another open chat changed in the last 30 minutes | on |
| `house-rules` | Blocks git commits/pushes/branch switches, worktrees and test-DB rebuilds unless your message asks; no file edits on a question turn | opt-in |

## Notes

- Mods use Claude Code's mod API. If your Claude Code build does not support mods, they do nothing and skills still work.
- `house-rules` fails open: if it errors, it never blocks work.
- Remove all mods with `./install.sh --uninstall`, or edit `enabledPlugins` in `~/.claude/settings.json`.
- Mod tests live next to each mod (`hooks/*.test.ts`).
