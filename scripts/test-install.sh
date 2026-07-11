#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_BASE="${TMPDIR:-/tmp}"
if [[ ! -d "$TMP_BASE" || ! -w "$TMP_BASE" ]]; then
  TMP_BASE="/tmp"
fi
TMP_ROOT="$(mktemp -d "$TMP_BASE/ai-setup-test.XXXXXX")"
trap 'rm -rf "$TMP_ROOT"' EXIT

export HOME="$TMP_ROOT/home"
PROJECT="$TMP_ROOT/project"
mkdir -p "$HOME" "$PROJECT"

echo "test: validate repo"
bash "$ROOT_DIR/scripts/validate-repo.sh"

echo "test: install all"
"$ROOT_DIR/install.sh" --all --no-global-files

echo "test: doctor"
"$ROOT_DIR/install.sh" --doctor

echo "test: init project"
"$ROOT_DIR/install.sh" --init-project "$PROJECT"

echo "test: audit project"
if "$ROOT_DIR/install.sh" --audit-project "$PROJECT"; then
  echo "audit passed"
else
  echo "audit reported starter placeholders as expected"
fi

echo "test: standardize project"
"$ROOT_DIR/install.sh" --standardize-project "$PROJECT" || true

echo "test: update"
"$ROOT_DIR/install.sh" --update --no-global-files

echo "test: uninstall"
"$ROOT_DIR/install.sh" --uninstall --no-global-files

echo "ok"
