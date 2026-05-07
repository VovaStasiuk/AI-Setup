# Commands

## Validate installer

```bash
./install.sh --doctor
./install.sh --dry-run --all --no-global-files --no-commands
./install.sh --dry-run --init-project /tmp/ai-setup-test
./install.sh --audit-project .
```

## Install globally

```bash
./install.sh --all
./install.sh --claude
./install.sh --codex
```

## Maintainer mode

```bash
./install.sh --all --link
```

## Do not run

- Do not use `--force` unless the user has reviewed existing project files.
- Do not delete installed user files without an explicit uninstall/rollback plan.
