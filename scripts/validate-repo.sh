#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
failures=0

log() {
  printf '%s\n' "$*"
}

fail() {
  log "fail: $*"
  failures=$((failures + 1))
}

ok() {
  log "ok: $*"
}

skill_in_core_profile() {
  local skill="$1"
  awk '
    /"skills"[[:space:]]*:/ { in_skills=1; next }
    in_skills && /\]/ { exit }
    in_skills { print }
  ' "$ROOT_DIR/profiles/core.json" | grep -Eq "\"$skill\""
}

core_profile_skills() {
  awk '
    /"skills"[[:space:]]*:/ { in_skills=1; next }
    in_skills && /\]/ { exit }
    in_skills {
      gsub(/[",]/, "")
      gsub(/^[[:space:]]+|[[:space:]]+$/, "")
      if ($0 != "") print
    }
  ' "$ROOT_DIR/profiles/core.json"
}

frontmatter_value() {
  local field="$1"
  local file="$2"
  awk -v field="$field" '
    NR == 1 && $0 == "---" { in_frontmatter=1; next }
    in_frontmatter && $0 == "---" { exit }
    in_frontmatter && $0 ~ "^" field ":" {
      sub("^" field ":[[:space:]]*", "")
      gsub(/^"|"$/, "")
      print
      exit
    }
  ' "$file"
}

command_skills() {
  local command_file="$1"
  local use_line
  use_line="$(sed -n '/^Use `/p' "$command_file" | head -n 1)"
  [[ -n "$use_line" ]] || return 0
  awk '
    {
      while (match($0, /`[^`]+`/)) {
        print substr($0, RSTART + 1, RLENGTH - 2)
        $0 = substr($0, RSTART + RLENGTH)
      }
    }
  ' <<<"$use_line"
}

json_string_value() {
  local field="$1"
  local file="$2"
  awk -v field="\"$field\"" '
    index($0, field) {
      line=$0
      sub(/^.*:[[:space:]]*"/, "", line)
      sub(/".*$/, "", line)
      if (line != $0) print line
      exit
    }
  ' "$file"
}

json_array_values() {
  local field="$1"
  local file="$2"
  awk -v field="\"$field\"" -v field_name="$field" '
    index($0, field) { in_array=1 }
    in_array {
      line=$0
      while (match(line, /"[^"]+"/)) {
        value=substr(line, RSTART + 1, RLENGTH - 2)
        if (value != field_name) print value
        line=substr(line, RSTART + RLENGTH)
      }
      if ($0 ~ /\]/) exit
    }
  ' "$file"
}

log "AI Setup repository validation"

if bash "$ROOT_DIR/scripts/check-markdown-links.sh"; then
  ok "local Markdown links resolve"
else
  fail "local Markdown links are broken"
fi

if [[ -d "$ROOT_DIR/setup/skills" ]]; then
  ok "setup/skills exists"
else
  fail "setup/skills missing"
fi

while IFS= read -r skill_dir; do
  skill="$(basename "$skill_dir")"
  if [[ -f "$skill_dir/SKILL.md" ]]; then
    ok "skill has SKILL.md: $skill"
    frontmatter_name="$(frontmatter_value name "$skill_dir/SKILL.md")"
    frontmatter_description="$(frontmatter_value description "$skill_dir/SKILL.md")"
    if [[ "$frontmatter_name" == "$skill" ]]; then
      ok "skill frontmatter name matches directory: $skill"
    else
      fail "skill frontmatter name mismatch: $skill -> ${frontmatter_name:-missing}"
    fi
    if [[ -n "$frontmatter_description" ]]; then
      ok "skill has frontmatter description: $skill"
    else
      fail "skill missing frontmatter description: $skill"
    fi
  else
    fail "skill missing SKILL.md: $skill"
  fi

  if skill_in_core_profile "$skill"; then
    ok "core profile lists skill: $skill"
  else
    fail "core profile missing skill: $skill"
  fi

  if grep -Eq "\`$skill\`" "$ROOT_DIR/README.md"; then
    ok "README lists skill: $skill"
  else
    fail "README missing skill: $skill"
  fi
done < <(find "$ROOT_DIR/setup/skills" -mindepth 1 -maxdepth 1 -type d | sort)

while IFS= read -r skill; do
  if [[ -d "$ROOT_DIR/setup/skills/$skill" ]]; then
    ok "core profile skill exists: $skill"
  else
    fail "core profile references missing skill: $skill"
  fi
done < <(core_profile_skills)

for expected_profile in core saas enterprise mobile; do
  if [[ -f "$ROOT_DIR/profiles/$expected_profile.json" ]]; then
    ok "profile exists: $expected_profile"
  else
    fail "profile missing: $expected_profile"
  fi
done

required_claude_commands=(
  "ai-setup-onboard-team"
)

for command in "${required_claude_commands[@]}"; do
  if [[ -f "$ROOT_DIR/setup/claude-commands/$command.md" ]]; then
    ok "required Claude command exists: /$command"
  else
    fail "required Claude command missing: /$command"
  fi
done

while IFS= read -r profile_file; do
  profile="$(basename "$profile_file" .json)"
  profile_name="$(json_string_value name "$profile_file")"
  profile_description="$(json_string_value description "$profile_file")"
  profile_extends="$(json_string_value extends "$profile_file")"
  profile_project_kit="$(json_string_value projectKit "$profile_file")"

  if [[ "$profile_name" == "$profile" ]]; then
    ok "profile name matches file: $profile"
  else
    fail "profile name mismatch: $profile -> ${profile_name:-missing}"
  fi

  if [[ -n "$profile_description" ]]; then
    ok "profile has description: $profile"
  else
    fail "profile missing description: $profile"
  fi

  if [[ -n "$profile_extends" ]]; then
    if [[ -f "$ROOT_DIR/profiles/$profile_extends.json" ]]; then
      ok "profile extends existing profile: $profile -> $profile_extends"
    else
      fail "profile extends missing profile: $profile -> $profile_extends"
    fi
  fi

  if [[ -n "$profile_project_kit" ]]; then
    if [[ -d "$ROOT_DIR/$profile_project_kit" ]]; then
      ok "profile project kit exists: $profile -> $profile_project_kit"
    else
      fail "profile project kit missing: $profile -> $profile_project_kit"
    fi
  fi

  while IFS= read -r profile_skill; do
    [[ -n "$profile_skill" ]] || continue
    if [[ -d "$ROOT_DIR/setup/skills/$profile_skill" ]]; then
      ok "profile skill exists: $profile -> $profile_skill"
    else
      fail "profile references missing skill: $profile -> $profile_skill"
    fi
  done < <(json_array_values skills "$profile_file")

  while IFS= read -r profile_overlay; do
    [[ -n "$profile_overlay" ]] || continue
    if [[ -d "$ROOT_DIR/$profile_overlay" ]]; then
      ok "profile overlay exists: $profile -> $profile_overlay"
    else
      fail "profile overlay missing: $profile -> $profile_overlay"
    fi
  done < <(json_array_values projectKitOverlays "$profile_file")

  if grep -Eq "\`$profile\`|--profile $profile" "$ROOT_DIR/docs/profiles.md"; then
    ok "profiles docs mention profile: $profile"
  else
    fail "profiles docs missing profile: $profile"
  fi
done < <(find "$ROOT_DIR/profiles" -mindepth 1 -maxdepth 1 -type f -name '*.json' | sort)

while IFS= read -r command_file; do
  command="$(basename "$command_file" .md)"
  if grep -Eq "\`/$command\`" "$ROOT_DIR/README.md"; then
    ok "README lists command: /$command"
  else
    fail "README missing command: /$command"
  fi

  referenced_skills=()
  while IFS= read -r referenced_skill; do
    referenced_skills+=("$referenced_skill")
  done < <(command_skills "$command_file")
  if [[ "${#referenced_skills[@]}" -eq 0 ]]; then
    fail "command has no primary skill invocation: $command_file"
  else
    for referenced_skill in "${referenced_skills[@]}"; do
      if [[ -d "$ROOT_DIR/setup/skills/$referenced_skill" ]]; then
        ok "command referenced skill exists: /$command -> $referenced_skill"
      else
        fail "command references missing skill: /$command -> $referenced_skill"
      fi
    done
  fi
done < <(find "$ROOT_DIR/setup/claude-commands" -mindepth 1 -maxdepth 1 -type f -name '*.md' | sort)

onboarding_command="$ROOT_DIR/setup/claude-commands/ai-setup-onboard-team.md"
backtick='`'
required_onboarding_contract=(
  "manager skill|Use ${backtick}ai-setup-manager${backtick}."
  "tool choices|${backtick}--claude${backtick}, ${backtick}--codex${backtick}, or ${backtick}--all${backtick}"
  "profile choices|${backtick}core${backtick}, ${backtick}saas${backtick}, ${backtick}enterprise${backtick}, or ${backtick}mobile${backtick}"
  "mode choices|${backtick}--copy${backtick} or ${backtick}--link${backtick}"
  "command plan|Present an ${backtick}Onboarding Command Plan${backtick}"
  'global dry-run|./install.sh --dry-run --profile <profile> <tool-flag> <mode>'
  'project dry-run|./install.sh --dry-run --profile <profile> --init-project <path>'
  "post-install doctor|${backtick}./install.sh --doctor${backtick}"
  "post-install status|${backtick}./install.sh --status${backtick}"
  "post-install configure|${backtick}/ai-setup-configure-project${backtick}"
  "mutation confirmation|Never run a real install, project init, update, use ${backtick}--force${backtick}, or edit project files until the user explicitly confirms"
  'separate approval gates|Treat global install and project init as separate approval gates'
)

for contract in "${required_onboarding_contract[@]}"; do
  contract_name="${contract%%|*}"
  contract_fragment="${contract#*|}"
  if grep -Fq -- "$contract_fragment" "$onboarding_command"; then
    ok "onboarding command contract: $contract_name"
  else
    fail "onboarding command missing contract: $contract_name"
  fi
done

required_project_kit_files=(
  "AGENTS.md"
  "CLAUDE.md"
  ".ai/project-context.md"
  ".ai/agent-workflow.md"
  ".ai/issue-tracker.md"
  ".ai/domain.md"
  ".ai/tech-stack.md"
  ".ai/commands.md"
  ".ai/styleguide.md"
  ".ai/DESIGN.md"
  ".ai/specs/.gitkeep"
  ".ai/tickets/.gitkeep"
  ".ai/decisions/.gitkeep"
  ".agents/skills/styleguides/Django-Styleguide.md"
  ".agents/skills/styleguides/React-Styleguide.md"
)

for rel in "${required_project_kit_files[@]}"; do
  if [[ -f "$ROOT_DIR/setup/project-kit/$rel" ]]; then
    ok "project kit file exists: $rel"
  else
    fail "project kit file missing: $rel"
  fi
done

required_profile_overlay_files=(
  "saas/.ai/profile.md"
  "enterprise/.ai/profile.md"
  "mobile/.ai/profile.md"
)

for rel in "${required_profile_overlay_files[@]}"; do
  if [[ -f "$ROOT_DIR/setup/profile-kits/$rel" ]]; then
    ok "profile overlay file exists: $rel"
  else
    fail "profile overlay file missing: $rel"
  fi
done

required_example_files=(
  "README.md"
  "onboarding/team-rollout.md"
  "workflows/configure-project/README.md"
  "workflows/configure-project/configuration-plan.md"
  "workflows/billing-settings/grill-notes.md"
  "workflows/billing-settings/spec.md"
  "workflows/billing-settings/tickets/01-user-can-view-billing-settings.md"
  "workflows/billing-settings/tickets/02-admin-can-update-billing-contact.md"
  "workflows/billing-settings/tickets/03-review-billing-settings-permissions.md"
  "workflows/billing-settings/implementation-notes.md"
  "workflows/billing-settings/review.md"
)

for rel in "${required_example_files[@]}"; do
  if [[ -f "$ROOT_DIR/examples/$rel" ]]; then
    ok "example file exists: $rel"
  else
    fail "example file missing: $rel"
  fi
done

required_docs=(
  "team-onboarding.md"
  "team-onboarding-usability-test.md"
)

for rel in "${required_docs[@]}"; do
  if [[ -f "$ROOT_DIR/docs/$rel" ]]; then
    ok "required doc exists: $rel"
  else
    fail "required doc missing: $rel"
  fi
done

if grep -Fq ".ai/profile.md" "$ROOT_DIR/setup/skills/ai-setup-manager/SKILL.md"; then
  ok "ai-setup-manager is profile-aware"
else
  fail "ai-setup-manager missing profile-aware configure guidance"
fi

if grep -Fq "Configured Project Plan" "$ROOT_DIR/setup/claude-commands/ai-setup-configure-project.md"; then
  ok "configure-project command requests a configuration plan"
else
  fail "configure-project command missing configuration plan guidance"
fi

for rel in "setup/global-files/AGENTS.md" "setup/global-files/CLAUDE.md" "setup/project-kit"; do
  if grep -Fq "\"$rel\"" "$ROOT_DIR/profiles/core.json"; then
    ok "core profile references existing path: $rel"
  else
    fail "core profile missing path reference: $rel"
  fi
done

if grep -R "graphify" "$ROOT_DIR/setup/global-files" >/dev/null; then
  fail "global bootstrap references optional graphify skill"
else
  ok "global bootstraps do not reference graphify"
fi

if [[ "$failures" -gt 0 ]]; then
  log "validation result: failed ($failures issues)"
  exit 1
fi

log "validation result: ok"
