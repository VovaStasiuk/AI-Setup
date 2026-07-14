# Profiles

Profiles tune the install and project starter kit for a project type without bloating the global bootstrap.

For tool selection, copy-vs-link guidance, and a first-project checklist, see [Team Onboarding](team-onboarding.md).

List profiles:

```bash
./install.sh --list-profiles
```

Use a profile during global install:

```bash
./install.sh --dry-run --profile saas --all
./install.sh --profile saas --all
```

Use a profile during project init:

```bash
./install.sh --dry-run --profile enterprise --init-project /path/to/project
./install.sh --profile enterprise --init-project /path/to/project
```

## Available Profiles

| Profile | Use When | Adds |
|---|---|---|
| `core` | General software development | Shared skills, global bootstraps, Claude command wrappers, base project kit |
| `saas` | B2B SaaS products | `.ai/profile.md` guidance for workspaces, billing, onboarding, dashboards, admin workflows, tenant isolation |
| `enterprise` | Enterprise/GRC/internal operations software | `.ai/profile.md` guidance for access control, auditability, compliance, migrations, dense operations UI |
| `mobile` | iOS, Android, React Native, Flutter, or mobile-first products | `.ai/profile.md` guidance for platform conventions, devices, accessibility, offline behavior, release safety |

## Profile Schema

Profiles live in `profiles/*.json`.

```json
{
  "name": "saas",
  "description": "B2B SaaS product setup.",
  "extends": "core",
  "skills": [],
  "projectKitOverlays": [
    "setup/profile-kits/saas"
  ]
}
```

- `extends` inherits another profile first.
- `skills` lists extra global skills to install for the profile.
- `projectKit` points at a full base project kit. `core` uses `setup/project-kit`.
- `projectKitOverlays` are copied after the inherited/base kit.

Profiles should add focused guidance and starter files. They should not encode one company's stack, commands, or product facts.
