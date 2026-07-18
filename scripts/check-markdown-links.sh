#!/usr/bin/env bash
set -euo pipefail

DEFAULT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT_DIR="${1:-$DEFAULT_ROOT}"
failures=0
checked=0

if [[ ! -d "$ROOT_DIR" ]]; then
  printf 'fail: Markdown root does not exist: %s\n' "$ROOT_DIR"
  exit 1
fi

ROOT_DIR="$(cd "$ROOT_DIR" && pwd)"

if ! command -v perl >/dev/null 2>&1; then
  printf '%s\n' "fail: perl is required to extract Markdown links"
  exit 1
fi

extract_markdown_targets() {
  # The Perl program must receive its $ARGV and $. expressions literally.
  # shellcheck disable=SC2016
  find "$ROOT_DIR" \
    -path "$ROOT_DIR/.git" -prune -o \
    -type f -name '*.md' -print0 |
    xargs -0 perl -ne '
      while (/\]\(([^)]+)\)/g) {
        print "$ARGV\t$.\t$1\n";
      }
      if (/^\s*\[[^]]+\]:\s*(<[^>]+>|\S+)/) {
        print "$ARGV\t$.\t$1\n";
      }
      close ARGV if eof;
    '
}

while IFS=$'\t' read -r file line raw_target; do
  target="$raw_target"

  if [[ "$target" == \<* ]]; then
    target="${target#<}"
    target="${target%%>*}"
  else
    target="${target%% *}"
  fi

  [[ -n "$target" ]] || continue

  case "$target" in
    \#*|//*|[a-zA-Z][a-zA-Z0-9+.-]*:*)
      continue
      ;;
  esac

  target="${target%%#*}"
  target="${target%%\?*}"
  [[ -n "$target" ]] || continue

  checked=$((checked + 1))
  candidate="$(dirname "$file")/$target"
  if [[ ! -e "$candidate" ]]; then
    relative_file="${file#"$ROOT_DIR"/}"
    printf 'broken: %s:%s -> %s\n' "$relative_file" "$line" "$raw_target"
    failures=$((failures + 1))
  fi
done < <(extract_markdown_targets)

if [[ "$failures" -gt 0 ]]; then
  printf 'Markdown link check: failed (%s broken local links)\n' "$failures"
  exit 1
fi

printf 'Markdown link check: ok (%s local links)\n' "$checked"
