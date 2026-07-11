# Commands

## Validate installer

```bash
bash scripts/validate-repo.sh
./install.sh --doctor
./install.sh --dry-run --all --no-global-files --no-commands
./install.sh --dry-run --init-project /tmp/ai-setup-test
./install.sh --audit-project .
```

## Workflow commands

```text
/ai-workflow what should I use?
/to-spec turn this conversation into a spec
/to-tickets split this spec into implementation tickets
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
