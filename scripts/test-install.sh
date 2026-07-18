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

fail_test() {
  printf 'test failure: %s\n' "$*"
  exit 1
}

assert_file() {
  local path="$1"
  [[ -f "$path" ]] || fail_test "expected file: $path"
}

assert_absent() {
  local path="$1"
  if [[ -e "$path" || -L "$path" ]]; then
    fail_test "expected path to be absent: $path"
  fi
}

run_install_route() {
  local name="$1"
  local profile="$2"
  local tool_flag="$3"
  local mode_flag="$4"
  local expected_tools="$5"
  local expect_claude="$6"
  local expect_codex="$7"
  local route_home="$TMP_ROOT/routes/$name/home"
  local route_log="$TMP_ROOT/routes/$name/install.log"
  local status_log="$TMP_ROOT/routes/$name/status.log"
  local metadata="$route_home/.agents/ai-setup/install.json"

  echo "test: install route $name"
  mkdir -p "$route_home"

  if ! HOME="$route_home" "$ROOT_DIR/install.sh" --dry-run --profile "$profile" "$tool_flag" "$mode_flag" --no-global-files > "$route_log" 2>&1; then
    cat "$route_log"
    fail_test "route dry-run failed: $name"
  fi
  if ! HOME="$route_home" "$ROOT_DIR/install.sh" --profile "$profile" "$tool_flag" "$mode_flag" --no-global-files >> "$route_log" 2>&1; then
    cat "$route_log"
    fail_test "route install failed: $name"
  fi
  if ! HOME="$route_home" "$ROOT_DIR/install.sh" --profile "$profile" --status --no-global-files > "$status_log" 2>&1; then
    cat "$status_log"
    fail_test "route status failed: $name"
  fi

  assert_file "$metadata"
  grep -Fq "\"profile\": \"$profile\"" "$metadata" || fail_test "wrong profile metadata: $name"
  grep -Fq "\"installed_tools\": \"$expected_tools\"" "$metadata" || fail_test "wrong tool metadata: $name"
  grep -Fq 'status result: ok' "$status_log" || fail_test "status did not report success: $name"
  assert_file "$route_home/.agents/skills/ai-setup-manager/SKILL.md"

  if [[ "$expect_claude" == "1" ]]; then
    assert_file "$route_home/.claude/skills/ai-setup-manager/SKILL.md"
    assert_file "$route_home/.claude/commands/ai-setup-onboard-team.md"
    if [[ "$mode_flag" == "--link" ]]; then
      [[ -L "$route_home/.claude/skills/ai-setup-manager" ]] || fail_test "expected linked Claude skill: $name"
    else
      [[ ! -L "$route_home/.claude/skills/ai-setup-manager" ]] || fail_test "expected copied Claude skill: $name"
    fi
  else
    assert_absent "$route_home/.claude"
  fi

  if [[ "$expect_codex" == "1" ]]; then
    assert_file "$route_home/.codex/skills/ai-setup-manager/SKILL.md"
    if [[ "$mode_flag" == "--link" ]]; then
      [[ -L "$route_home/.codex/skills/ai-setup-manager" ]] || fail_test "expected linked Codex skill: $name"
    else
      [[ ! -L "$route_home/.codex/skills/ai-setup-manager" ]] || fail_test "expected copied Codex skill: $name"
    fi
  else
    assert_absent "$route_home/.codex"
  fi

  if [[ "$mode_flag" == "--link" ]]; then
    grep -Fq '"mode": "link"' "$metadata" || fail_test "wrong link metadata: $name"
  else
    grep -Fq '"mode": "copy"' "$metadata" || fail_test "wrong copy metadata: $name"
  fi
}

echo "test: markdown links"
bash "$ROOT_DIR/scripts/check-markdown-links.sh"

echo "test: markdown links detect a missing target"
BROKEN_LINK_ROOT="$TMP_ROOT/broken-links"
mkdir -p "$BROKEN_LINK_ROOT"
printf '%s\n' '[missing](does-not-exist.md)' > "$BROKEN_LINK_ROOT/README.md"
if bash "$ROOT_DIR/scripts/check-markdown-links.sh" "$BROKEN_LINK_ROOT"; then
  echo "Markdown link check unexpectedly passed with a missing target"
  exit 1
else
  echo "Markdown link check reported the missing target as expected"
fi

echo "test: validate repo"
bash "$ROOT_DIR/scripts/validate-repo.sh"

echo "test: list profiles"
"$ROOT_DIR/install.sh" --list-profiles

echo "test: isolated install route matrix"
run_install_route "claude-core-copy" "core" "--claude" "--copy" "claude" 1 0
run_install_route "codex-core-copy" "core" "--codex" "--copy" "codex" 0 1
run_install_route "all-saas-copy" "saas" "--all" "--copy" "claude,codex" 1 1
run_install_route "all-enterprise-copy" "enterprise" "--all" "--copy" "claude,codex" 1 1
run_install_route "all-mobile-link" "mobile" "--all" "--link" "claude,codex" 1 1

echo "test: dry-run profile install"
"$ROOT_DIR/install.sh" --dry-run --profile saas --all --no-global-files

echo "test: install all"
"$ROOT_DIR/install.sh" --all --no-global-files

echo "test: doctor"
"$ROOT_DIR/install.sh" --doctor

echo "test: status"
"$ROOT_DIR/install.sh" --status --no-global-files

echo "test: status detects stale installed skill"
printf '\n# test drift\n' >> "$HOME/.agents/skills/ai-setup-manager/SKILL.md"
if "$ROOT_DIR/install.sh" --status --no-global-files; then
  echo "status unexpectedly passed with stale installed skill"
  exit 1
else
  echo "status reported stale installed skill as expected"
fi

echo "test: init project"
"$ROOT_DIR/install.sh" --init-project "$PROJECT"

echo "test: init every project profile"
for profile in core saas enterprise mobile; do
  PROFILE_PROJECT="$TMP_ROOT/profile-projects/$profile"
  PROFILE_LOG="$TMP_ROOT/profile-projects/$profile.log"
  mkdir -p "$PROFILE_PROJECT"
  "$ROOT_DIR/install.sh" --dry-run --profile "$profile" --init-project "$PROFILE_PROJECT" > "$PROFILE_LOG"
  "$ROOT_DIR/install.sh" --profile "$profile" --init-project "$PROFILE_PROJECT" >> "$PROFILE_LOG"
  assert_file "$PROFILE_PROJECT/AGENTS.md"
  if [[ "$profile" == "core" ]]; then
    assert_absent "$PROFILE_PROJECT/.ai/profile.md"
  else
    assert_file "$PROFILE_PROJECT/.ai/profile.md"
    grep -Eqi "^# Project Profile: $profile$" "$PROFILE_PROJECT/.ai/profile.md" || fail_test "wrong project profile overlay: $profile"
  fi
done

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

echo "test: status after update"
"$ROOT_DIR/install.sh" --status --no-global-files

echo "test: uninstall"
"$ROOT_DIR/install.sh" --uninstall --no-global-files

echo "ok"
