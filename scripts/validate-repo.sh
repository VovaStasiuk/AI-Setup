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

log "AI Setup repository validation"

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
