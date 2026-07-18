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

write_retired_skill_fixture() {
  local path="$1"
  mkdir -p "$path"
  # shellcheck disable=SC2016 # Markdown backticks below are literal.
  printf '%s\n' \
    '---' \
    'name: grill-me' \
    'description: Use when the user says "grill me" or invokes the older grill-me workflow. Prefer the docs-aware grill-with-context workflow for project, product, architecture, design, migration, and feature clarification.' \
    '---' \
    '' \
    '# Grill Me' \
    '' \
    "This is a compatibility alias. Use \`engineering-baseline\`, then use \`grill-with-context\`." \
    '' \
    'If `grill-with-context` is unavailable, fall back to this minimal behavior:' \
    '' \
    '- Apply the engineering-baseline critical thinking standard: do not assume the idea is good.' \
    '- Ask one focused question at a time.' \
    '- If a question can be answered by inspecting the repo or project docs, inspect instead of asking.' \
    '- For each question, provide your recommended answer and why, so the user can confirm quickly.' \
    '- Walk the decision tree: resolve dependencies between choices before moving to downstream details.' \
    '- Do not fill unknown requirements with optimistic assumptions; mark them as unknown and ask.' \
    '- Keep going until goal, audience, success criteria, constraints, non-goals, risks, and next workflow are clear.' \
    '- Do not implement during the grilling session.' \
    '' \
    '## Finish' \
    '' \
    'End with:' \
    '' \
    '- Decisions confirmed' \
    '- Shared language / terms clarified' \
    '- Open questions' \
    '- Candidate doc updates, if any, with recommended destination' \
    '- Recommended next route: `feature-planner`, `human-ui-designer`, `research-brief`, `implementation-agent`, or external review/handoff' \
    > "$path/SKILL.md"
}

write_retired_command_fixture() {
  local path="$1"
  mkdir -p "$(dirname "$path")"
  printf '%s\n' \
    "Use \`engineering-baseline\`, then \`grill-with-context\`." \
    '' \
    'Interview me about the idea, plan, architecture, design, or decision until we reach shared understanding. Ask one focused question at a time, inspect project facts/docs instead of asking when possible, challenge fuzzy language, and include your recommended answer for every question. At the end, ask whether I want proposed updates to project docs.' \
    > "$path"
}

seed_recognizable_retired_install() {
  write_retired_skill_fixture "$HOME/.agents/skills/grill-me"
  write_retired_skill_fixture "$HOME/.codex/skills/grill-me"
  write_retired_skill_fixture "$HOME/.claude/skills/grill-me"
  write_retired_command_fixture "$HOME/.claude/commands/grill-me.md"
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

echo "test: retired grill-me inventory is absent"
assert_absent "$ROOT_DIR/setup/skills/grill-me"
assert_absent "$ROOT_DIR/setup/claude-commands/grill-me.md"
if grep -Fq '"grill-me"' "$ROOT_DIR/profiles/core.json"; then
  fail_test "core profile still lists retired grill-me skill"
fi

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

echo "test: status and update retire recognizable grill-me installs"
seed_recognizable_retired_install
if "$ROOT_DIR/install.sh" --status --no-global-files; then
  fail_test "status unexpectedly passed with retired grill-me paths"
else
  echo "status reported retired grill-me paths as expected"
fi
RETIRED_DRY_RUN_LOG="$TMP_ROOT/retired-dry-run.log"
"$ROOT_DIR/install.sh" --dry-run --update --no-global-files > "$RETIRED_DRY_RUN_LOG"
grep -Fq 'retire AI Setup skill grill-me' "$RETIRED_DRY_RUN_LOG" || fail_test "retired skill missing from update dry-run"
grep -Fq 'retire AI Setup command grill-me.md' "$RETIRED_DRY_RUN_LOG" || fail_test "retired command missing from update dry-run"
assert_file "$HOME/.agents/skills/grill-me/SKILL.md"
assert_file "$HOME/.claude/commands/grill-me.md"
"$ROOT_DIR/install.sh" --update --no-global-files
assert_absent "$HOME/.agents/skills/grill-me"
assert_absent "$HOME/.codex/skills/grill-me"
assert_absent "$HOME/.claude/skills/grill-me"
assert_absent "$HOME/.claude/commands/grill-me.md"
"$ROOT_DIR/install.sh" --status --no-global-files

echo "test: update preserves unrecognized grill-me path"
mkdir -p "$HOME/.agents/skills/grill-me"
printf '%s\n' 'name: grill-me' 'custom user workflow' > "$HOME/.agents/skills/grill-me/SKILL.md"
CUSTOM_RETIRED_LOG="$TMP_ROOT/custom-retired.log"
"$ROOT_DIR/install.sh" --update --no-global-files > "$CUSTOM_RETIRED_LOG"
assert_file "$HOME/.agents/skills/grill-me/SKILL.md"
grep -Fq 'preserve unrecognized retired skill path' "$CUSTOM_RETIRED_LOG" || fail_test "custom retired path was not reported as preserved"
rm -rf "$HOME/.agents/skills/grill-me"

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
seed_recognizable_retired_install
"$ROOT_DIR/install.sh" --uninstall --no-global-files
assert_absent "$HOME/.agents/skills/grill-me"
assert_absent "$HOME/.codex/skills/grill-me"
assert_absent "$HOME/.claude/skills/grill-me"
assert_absent "$HOME/.claude/commands/grill-me.md"

echo "ok"
