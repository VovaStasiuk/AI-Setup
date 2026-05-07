# Styleguide

## Markdown

- Keep headings short.
- Prefer concrete commands and file paths.
- Avoid duplicating long instructions across docs.
- Link to the source doc instead of copying large sections.

## Bash

- Use `set -euo pipefail`.
- Prefer explicit flags over hidden behavior.
- Dry-run before mutating user files.
- Do not overwrite user files without `--force`.
- Keep commands portable across macOS and Linux where practical.
