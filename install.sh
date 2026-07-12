#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DO_CLAUDE=0
DO_CODEX=0
DO_GLOBAL_FILES=1
DO_COMMANDS=1
DRY_RUN=0
LINK_MODE=0
FORCE=0
PROFILE_NAME="core"
SHARED_SKILLS_INSTALLED=0
INIT_PROJECT=""
AUDIT_PROJECT=""
STANDARDIZE_PROJECT=""
RUN_DOCTOR=0
RUN_STATUS=0
RUN_UPDATE=0
RUN_UNINSTALL=0
RUN_LIST_PROFILES=0
RESTORE_BACKUP=""
VERSION="0.1.0"

usage() {
  cat <<'USAGE'
AI Setup installer

Usage:
  ./install.sh --all
  ./install.sh --claude
  ./install.sh --codex
  ./install.sh --profile saas --all
  ./install.sh --init-project /path/to/project
  ./install.sh --profile enterprise --init-project /path/to/project
  ./install.sh --audit-project /path/to/project
  ./install.sh --standardize-project /path/to/project
  ./install.sh --doctor
  ./install.sh --status
  ./install.sh --list-profiles
  ./install.sh --update
  ./install.sh --uninstall
  ./install.sh --restore-backup /path/to/backup-dir

Options:
  --all                 Install shared skills for Claude and Codex
  --claude              Install shared skills for Claude
  --codex               Install shared skills for Codex
  --profile NAME        Use an install/project profile: core, saas, enterprise, mobile
  --list-profiles       List available profiles
  --no-global-files     Do not update ~/.claude/CLAUDE.md or ~/.codex/AGENTS.md
  --no-commands         Do not install Claude command wrappers
  --copy                Copy skills/templates (default; source repo can be deleted)
  --link                Symlink tool skill folders to this repo (maintainer mode)
  --force               Overwrite project kit files during --init-project
  --dry-run             Print actions without changing files
  --doctor              Check global AI Setup installation health
  --status              Report installed-vs-source drift without changing files
  --update              Refresh installed skills/commands from this repo
  --uninstall           Remove AI Setup installed skills/commands/templates
  --restore-backup PATH Restore global AGENTS.md/CLAUDE.md from backup dir
  --audit-project PATH  Check a project's AI setup files without changing them
  --standardize-project PATH
                        Report how to standardize a project's Claude/Codex/AI setup
  --help                Show this help
USAGE
}

log() {
  printf '%s\n' "$*"
}

check_path() {
  local label="$1"
  local path="$2"
  if [[ -e "$path" || -L "$path" ]]; then
    log "ok: $label -> $path"
    return 0
  fi
  log "missing: $label -> $path"
  return 1
}

check_command() {
  local name="$1"
  if command -v "$name" >/dev/null 2>&1; then
    log "ok: command $name -> $(command -v "$name")"
  else
    log "optional missing: command $name"
  fi
}

source_revision() {
  local revision=""
  local dirty=""

  if command -v git >/dev/null 2>&1 && [[ -d "$ROOT_DIR/.git" ]]; then
    revision="$(git -C "$ROOT_DIR" rev-parse --short HEAD 2>/dev/null || true)"
    dirty="$(git -C "$ROOT_DIR" status --porcelain 2>/dev/null || true)"
    if [[ -n "$revision" && -n "$dirty" ]]; then
      revision="${revision}-dirty"
    fi
  fi

  printf '%s\n' "${revision:-unknown}"
}

profile_path() {
  printf '%s/profiles/%s.json\n' "$ROOT_DIR" "$1"
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

profile_chain() {
  local profile="$1"
  local depth="${2:-0}"
  local file
  local parent

  if [[ "$depth" -gt 8 ]]; then
    log "profile inheritance appears to be recursive: $profile"
    exit 1
  fi

  file="$(profile_path "$profile")"
  if [[ ! -f "$file" ]]; then
    log "unknown profile: $profile"
    log "run ./install.sh --list-profiles to see available profiles"
    exit 1
  fi

  parent="$(json_string_value "extends" "$file")"
  if [[ -n "$parent" ]]; then
    profile_chain "$parent" $((depth + 1))
  fi
  printf '%s\n' "$profile"
}

profile_skill_names() {
  local seen=""
  local profile
  local file
  local skill

  for profile in $(profile_chain "$PROFILE_NAME"); do
    file="$(profile_path "$profile")"
    while IFS= read -r skill; do
      [[ -n "$skill" ]] || continue
      if [[ ! -d "$ROOT_DIR/setup/skills/$skill" ]]; then
        log "profile references missing skill: $profile -> $skill"
        exit 1
      fi
      case " $seen " in
        *" $skill "*) ;;
        *)
          seen="$seen $skill"
          printf '%s\n' "$skill"
          ;;
      esac
    done < <(json_array_values "skills" "$file")
  done
}

profile_project_kit_paths() {
  local seen=""
  local profile
  local file
  local kit

  for profile in $(profile_chain "$PROFILE_NAME"); do
    file="$(profile_path "$profile")"
    kit="$(json_string_value "projectKit" "$file")"
    [[ -n "$kit" ]] || continue
    case " $seen " in
      *" $kit "*) ;;
      *)
        seen="$seen $kit"
        printf '%s\n' "$kit"
        ;;
    esac
  done
}

profile_project_kit_overlay_paths() {
  local profile
  local file
  local overlay

  for profile in $(profile_chain "$PROFILE_NAME"); do
    file="$(profile_path "$profile")"
    while IFS= read -r overlay; do
      [[ -n "$overlay" ]] || continue
      printf '%s\n' "$overlay"
    done < <(json_array_values "projectKitOverlays" "$file")
  done
}

list_profiles() {
  local profile_file
  local name
  local description

  log "Available profiles"
  for profile_file in "$ROOT_DIR"/profiles/*.json; do
    [[ -f "$profile_file" ]] || continue
    name="$(json_string_value "name" "$profile_file")"
    description="$(json_string_value "description" "$profile_file")"
    log "- ${name:-$(basename "$profile_file" .json)}: ${description:-no description}"
  done
}

run() {
  if [[ "$DRY_RUN" == "1" ]]; then
    printf '[dry-run] %q' "$1"
    shift || true
    for arg in "$@"; do printf ' %q' "$arg"; done
    printf '\n'
  else
    "$@"
  fi
}

copy_skill_tree() {
  local skill="$1"
  local dst_root="$2"
  local src="$ROOT_DIR/setup/skills/$skill"
  local dst="$dst_root/$skill"

  run mkdir -p "$dst"
  if [[ "$DRY_RUN" == "1" ]]; then
    log "[dry-run] copy skill contents: $src -> $dst"
  else
    cp -R "$src"/. "$dst"/
  fi
}

copy_file() {
  local src="$1"
  local dst="$2"
  run mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" && "$FORCE" != "1" ]]; then
    log "skip existing: $dst"
    return
  fi
  run cp "$src" "$dst"
}

copy_project_kit_tree() {
  local kit_path="$1"
  local project="$2"
  local src="$ROOT_DIR/$kit_path"

  if [[ ! -d "$src" ]]; then
    log "profile references missing project kit path: $kit_path"
    exit 1
  fi

  while IFS= read -r -d '' file; do
    local rel="${file#"$src"/}"
    copy_file "$file" "$project/$rel"
  done < <(find "$src" -type f -print0)
}

copy_tree_contents() {
  local src="$1"
  local dst="$2"
  run mkdir -p "$dst"
  if [[ "$DRY_RUN" == "1" ]]; then
    log "[dry-run] copy contents: $src -> $dst"
  else
    cp -R "$src"/. "$dst"/
  fi
}

replace_tree() {
  local src="$1"
  local dst="$2"
  if [[ "$DRY_RUN" == "1" ]]; then
    log "[dry-run] replace tree: $src -> $dst"
    return
  fi
  rm -rf "$dst"
  mkdir -p "$(dirname "$dst")"
  cp -R "$src" "$dst"
}

link_or_copy_skill() {
  local skill="$1"
  local target_root="$2"
  local src="$ROOT_DIR/setup/skills/$skill"
  local dst="$target_root/$skill"

  run mkdir -p "$target_root"
  if [[ -e "$dst" || -L "$dst" ]]; then
    log "skip existing skill link/copy: $dst"
    return
  fi

  if [[ "$LINK_MODE" == "0" ]]; then
    if [[ "$DRY_RUN" == "1" ]]; then
      log "[dry-run] copy skill: $src -> $dst"
    else
      cp -R "$src" "$dst"
    fi
  else
    run ln -s "$src" "$dst"
  fi
}

refresh_tool_skill() {
  local skill="$1"
  local target_root="$2"
  local src="$HOME/.agents/skills/$skill"
  local dst="$target_root/$skill"

  run mkdir -p "$target_root"
  if [[ "$LINK_MODE" == "1" ]]; then
    if [[ "$DRY_RUN" == "1" ]]; then
      log "[dry-run] refresh link: $dst -> $src"
    else
      rm -rf "$dst"
      ln -s "$src" "$dst"
    fi
  else
    replace_tree "$src" "$dst"
  fi
}

write_install_metadata() {
  local tools="$1"
  local mode="copy"
  local can_delete_source="true"
  if [[ "$LINK_MODE" == "1" ]]; then
    mode="link"
    can_delete_source="false"
  fi

  run mkdir -p "$HOME/.agents/ai-setup"
  if [[ "$DRY_RUN" == "1" ]]; then
    log "[dry-run] write metadata: $HOME/.agents/ai-setup/install.json"
    return
  fi

  cat > "$HOME/.agents/ai-setup/install.json" <<JSON
{
  "version": "$VERSION",
  "installed_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "mode": "$mode",
  "profile": "$PROFILE_NAME",
  "source_path": "$ROOT_DIR",
  "source_revision": "$(source_revision)",
  "can_delete_source": $can_delete_source,
  "installed_tools": "$tools"
}
JSON
}

backup_global_file() {
  local path="$1"
  local backup_dir
  backup_dir="$HOME/.agents/backups/$(date +%Y%m%d-%H%M%S)-ai-setup"
  if [[ -e "$path" ]]; then
    run mkdir -p "$backup_dir"
    run cp "$path" "$backup_dir/$(basename "$path")"
    log "backup: $path -> $backup_dir/"
  fi
}

install_shared_skills() {
  local canonical="$HOME/.agents/skills"
  local skill
  if [[ "$SHARED_SKILLS_INSTALLED" == "1" ]]; then
    return
  fi
  run mkdir -p "$canonical"
  while IFS= read -r skill; do
    copy_skill_tree "$skill" "$canonical"
  done < <(profile_skill_names)
  SHARED_SKILLS_INSTALLED=1
}

refresh_shared_skills() {
  local canonical="$HOME/.agents/skills"
  local skill
  run mkdir -p "$canonical"
  while IFS= read -r skill; do
    replace_tree "$ROOT_DIR/setup/skills/$skill" "$canonical/$skill"
  done < <(profile_skill_names)
}

skill_names() {
  for skill_dir in "$ROOT_DIR"/setup/skills/*; do
    [[ -d "$skill_dir" ]] || continue
    basename "$skill_dir"
  done
}

command_names() {
  for cmd_file in "$ROOT_DIR"/setup/claude-commands/*.md; do
    [[ -f "$cmd_file" ]] || continue
    basename "$cmd_file"
  done
}

paths_match() {
  local src="$1"
  local dst="$2"

  if [[ -d "$src" ]]; then
    [[ -d "$dst" ]] || return 1
    diff -qr "$src" "$dst" >/dev/null 2>&1
  else
    [[ -f "$dst" || -L "$dst" ]] || return 1
    cmp -s "$src" "$dst"
  fi
}

status_path() {
  local label="$1"
  local src="$2"
  local dst="$3"
  local optional="${4:-0}"

  if [[ ! -e "$src" && ! -L "$src" ]]; then
    log "source-missing: $label -> $src"
    STATUS_MISSING=$((STATUS_MISSING + 1))
    return 1
  fi

  if [[ ! -e "$dst" && ! -L "$dst" ]]; then
    if [[ "$optional" == "1" ]]; then
      log "optional missing: $label -> $dst"
      STATUS_SKIPPED=$((STATUS_SKIPPED + 1))
      return 0
    fi
    log "missing: $label -> $dst"
    STATUS_MISSING=$((STATUS_MISSING + 1))
    return 1
  fi

  if paths_match "$src" "$dst"; then
    log "match: $label -> $dst"
    STATUS_MATCHED=$((STATUS_MATCHED + 1))
    return 0
  fi

  log "stale: $label -> $dst"
  STATUS_STALE=$((STATUS_STALE + 1))
  return 1
}

status_skill_root() {
  local label="$1"
  local target_root="$2"
  local active_skills="$3"
  local skill

  for skill in $active_skills; do
    status_path "$label skill $skill" "$ROOT_DIR/setup/skills/$skill" "$target_root/$skill" || true
  done
}

status_extra_source_skills() {
  local label="$1"
  local target_root="$2"
  local active_skills="$3"
  local skill

  [[ -d "$target_root" ]] || return 0

  while IFS= read -r skill; do
    case " $active_skills " in
      *" $skill "*) ;;
      *)
        if [[ -e "$target_root/$skill" || -L "$target_root/$skill" ]]; then
          log "extra: $label skill $skill -> $target_root/$skill"
          STATUS_EXTRA=$((STATUS_EXTRA + 1))
        fi
        ;;
    esac
  done < <(skill_names)
}

install_status() {
  local metadata="$HOME/.agents/ai-setup/install.json"
  local source_rev
  local installed_profile=""
  local installed_mode=""
  local installed_revision=""
  local installed_source=""
  local installed_tools=""
  local check_claude="$DO_CLAUDE"
  local check_codex="$DO_CODEX"
  local active_skills=""
  local skill
  local cmd

  STATUS_MATCHED=0
  STATUS_MISSING=0
  STATUS_STALE=0
  STATUS_EXTRA=0
  STATUS_SKIPPED=0

  source_rev="$(source_revision)"

  log "AI Setup status"
  log "version: $VERSION"
  log "profile: $PROFILE_NAME"
  log "root: $ROOT_DIR"
  log "source revision: $source_rev"

  if [[ -f "$metadata" ]]; then
    installed_profile="$(json_string_value "profile" "$metadata")"
    installed_mode="$(json_string_value "mode" "$metadata")"
    installed_revision="$(json_string_value "source_revision" "$metadata")"
    installed_source="$(json_string_value "source_path" "$metadata")"
    installed_tools="$(json_string_value "installed_tools" "$metadata")"
    log "installed profile: ${installed_profile:-unknown}"
    log "installed mode: ${installed_mode:-unknown}"
    log "installed source: ${installed_source:-unknown}"
    log "installed revision: ${installed_revision:-unknown}"
    log "installed tools: ${installed_tools:-unknown}"
    if [[ -n "$installed_revision" && "$installed_revision" != "$source_rev" ]]; then
      log "stale: install metadata revision differs from source"
      STATUS_STALE=$((STATUS_STALE + 1))
    fi
  else
    log "missing: installed metadata -> $metadata"
    STATUS_MISSING=$((STATUS_MISSING + 1))
  fi

  if [[ "$check_claude" == "0" && "$check_codex" == "0" ]]; then
    case ",$installed_tools," in
      *,claude,*) check_claude=1 ;;
    esac
    case ",$installed_tools," in
      *,codex,*) check_codex=1 ;;
    esac
  fi

  if [[ "$check_claude" == "0" && "$check_codex" == "0" ]]; then
    [[ -d "$HOME/.claude/skills" || -d "$HOME/.claude/commands" || -f "$HOME/.claude/CLAUDE.md" ]] && check_claude=1
    [[ -d "$HOME/.codex/skills" || -f "$HOME/.codex/AGENTS.md" ]] && check_codex=1
  fi

  while IFS= read -r skill; do
    active_skills="${active_skills:+$active_skills }$skill"
  done < <(profile_skill_names)

  log ""
  log "Canonical shared skills"
  status_skill_root "canonical" "$HOME/.agents/skills" "$active_skills"
  status_extra_source_skills "canonical" "$HOME/.agents/skills" "$active_skills"

  if [[ "$check_codex" == "1" ]]; then
    log ""
    log "Codex install"
    status_skill_root "codex" "$HOME/.codex/skills" "$active_skills"
    status_extra_source_skills "codex" "$HOME/.codex/skills" "$active_skills"
    if [[ "$DO_GLOBAL_FILES" == "1" ]]; then
      status_path "codex global AGENTS" "$ROOT_DIR/setup/global-files/AGENTS.md" "$HOME/.codex/AGENTS.md" 1 || true
    fi
  fi

  if [[ "$check_claude" == "1" ]]; then
    log ""
    log "Claude install"
    status_skill_root "claude" "$HOME/.claude/skills" "$active_skills"
    status_extra_source_skills "claude" "$HOME/.claude/skills" "$active_skills"
    if [[ "$DO_GLOBAL_FILES" == "1" ]]; then
      status_path "claude global CLAUDE" "$ROOT_DIR/setup/global-files/CLAUDE.md" "$HOME/.claude/CLAUDE.md" 1 || true
    fi
    if [[ "$DO_COMMANDS" == "1" ]]; then
      log ""
      log "Claude commands"
      while IFS= read -r cmd; do
        status_path "claude command $cmd" "$ROOT_DIR/setup/claude-commands/$cmd" "$HOME/.claude/commands/$cmd" || true
      done < <(command_names)
    fi
  fi

  log ""
  log "status summary: matched $STATUS_MATCHED, missing $STATUS_MISSING, stale $STATUS_STALE, extra $STATUS_EXTRA, optional-missing $STATUS_SKIPPED"
  if [[ "$STATUS_MISSING" -gt 0 || "$STATUS_STALE" -gt 0 || "$STATUS_EXTRA" -gt 0 ]]; then
    log "status result: issues found"
    return 1
  fi

  log "status result: ok"
}

install_codex() {
  local skill
  install_shared_skills
  while IFS= read -r skill; do
    link_or_copy_skill "$skill" "$HOME/.codex/skills"
  done < <(profile_skill_names)
  if [[ "$DO_GLOBAL_FILES" == "1" ]]; then
    backup_global_file "$HOME/.codex/AGENTS.md"
    run mkdir -p "$HOME/.codex"
    run cp "$ROOT_DIR/setup/global-files/AGENTS.md" "$HOME/.codex/AGENTS.md"
  fi
}

install_claude() {
  local skill
  install_shared_skills
  while IFS= read -r skill; do
    link_or_copy_skill "$skill" "$HOME/.claude/skills"
  done < <(profile_skill_names)
  if [[ "$DO_GLOBAL_FILES" == "1" ]]; then
    backup_global_file "$HOME/.claude/CLAUDE.md"
    run mkdir -p "$HOME/.claude"
    run cp "$ROOT_DIR/setup/global-files/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
  fi
  if [[ "$DO_COMMANDS" == "1" ]]; then
    run mkdir -p "$HOME/.claude/commands"
    copy_tree_contents "$ROOT_DIR/setup/claude-commands" "$HOME/.claude/commands"
  fi
}

init_project() {
  local project="$1"
  local kit_path
  local overlay_path
  if [[ ! -d "$project" ]]; then
    log "project path does not exist: $project"
    exit 1
  fi

  log "project profile: $PROFILE_NAME"
  while IFS= read -r kit_path; do
    copy_project_kit_tree "$kit_path" "$project"
  done < <(profile_project_kit_paths)
  while IFS= read -r overlay_path; do
    copy_project_kit_tree "$overlay_path" "$project"
  done < <(profile_project_kit_overlay_paths)
}

doctor() {
  local failures=0
  log "AI Setup doctor"
  log "version: $VERSION"
  log "profile: $PROFILE_NAME"
  log "root: $ROOT_DIR"

  check_path "setup skills" "$ROOT_DIR/setup/skills" || failures=$((failures + 1))
  check_path "setup project kit" "$ROOT_DIR/setup/project-kit" || failures=$((failures + 1))
  check_path "setup global AGENTS" "$ROOT_DIR/setup/global-files/AGENTS.md" || failures=$((failures + 1))
  check_path "setup global CLAUDE" "$ROOT_DIR/setup/global-files/CLAUDE.md" || failures=$((failures + 1))
  check_path "profile $PROFILE_NAME" "$(profile_path "$PROFILE_NAME")" || failures=$((failures + 1))
  check_path "installed metadata" "$HOME/.agents/ai-setup/install.json" || true
  check_path "installed agents skills" "$HOME/.agents/skills" || failures=$((failures + 1))
  check_path "codex global AGENTS" "$HOME/.codex/AGENTS.md" || true
  check_path "claude global CLAUDE" "$HOME/.claude/CLAUDE.md" || true

  local skill
  while IFS= read -r skill; do
    check_path "canonical skill $skill" "$HOME/.agents/skills/$skill/SKILL.md" || failures=$((failures + 1))
  done < <(profile_skill_names)

  check_command claude
  check_command codex
  check_command gemini

  if ! install_status; then
    failures=$((failures + 1))
  fi

  if find "$HOME/.claude/skills" "$HOME/.codex/skills" -xtype l -print 2>/dev/null | grep -q .; then
    log "warning: broken skill symlinks detected:"
    find "$HOME/.claude/skills" "$HOME/.codex/skills" -xtype l -print 2>/dev/null
    failures=$((failures + 1))
  else
    log "ok: no broken Claude/Codex skill symlinks detected"
  fi

  if [[ "$failures" -gt 0 ]]; then
    log "doctor result: issues found ($failures)"
    return 1
  fi
  log "doctor result: ok"
}

is_placeholder_file() {
  local path="$1"
  [[ -f "$path" ]] || return 1
  grep -Eq 'fill in|Describe what|Product type:|# fill in' "$path"
}

is_claude_agents_wrapper() {
  local path="$1"
  [[ -f "$path" ]] || return 1
  grep -Eq 'AGENTS\.md' "$path"
}

audit_project() {
  local project="$1"
  local issues=0
  if [[ ! -d "$project" ]]; then
    log "project path does not exist: $project"
    return 1
  fi

  log "AI Setup project audit"
  log "project: $project"

  local required=(
    "AGENTS.md"
    "CLAUDE.md"
    ".ai/project-context.md"
    ".ai/agent-workflow.md"
    ".ai/issue-tracker.md"
    ".ai/domain.md"
    ".ai/tech-stack.md"
    ".ai/commands.md"
    ".ai/DESIGN.md"
    ".ai/styleguide.md"
    ".ai/specs"
    ".ai/tickets"
    ".ai/decisions"
  )

  for rel in "${required[@]}"; do
    if [[ -e "$project/$rel" ]]; then
      log "ok: $rel"
    else
      log "missing: $rel"
      issues=$((issues + 1))
    fi
  done

  for rel in ".ai/project-context.md" ".ai/agent-workflow.md" ".ai/issue-tracker.md" ".ai/domain.md" ".ai/tech-stack.md" ".ai/commands.md" ".ai/DESIGN.md"; do
    if is_placeholder_file "$project/$rel"; then
      log "weak: $rel still appears to contain starter placeholders"
      issues=$((issues + 1))
    fi
  done

  if [[ -f "$project/AGENTS.md" ]] && ! grep -Eq '\.ai/|DESIGN|commands|tech-stack' "$project/AGENTS.md"; then
    log "weak: AGENTS.md does not appear to index .ai project context"
    issues=$((issues + 1))
  fi

  if [[ "$issues" -gt 0 ]]; then
    log "audit result: issues found ($issues)"
    return 1
  fi
  log "audit result: ok"
}

standardize_project() {
  local project="$1"
  local issues=0
  if [[ ! -d "$project" ]]; then
    log "project path does not exist: $project"
    return 1
  fi

  log "AI Setup standardization report"
  log "project: $project"
  log ""
  log "1. Instruction surfaces"
  for rel in "AGENTS.md" "CLAUDE.md" ".agents" ".claude" ".codex" ".ai"; do
    if [[ -e "$project/$rel" ]]; then
      log "present: $rel"
    else
      log "missing: $rel"
    fi
  done

  log ""
  log "2. Shared context candidates"
  for rel in "README.md" "Makefile" "package.json" "pyproject.toml" "uv.lock" "tailwind.config.js" "vite.config.mjs"; do
    [[ -e "$project/$rel" ]] && log "found: $rel"
  done

  log ""
  log "3. Project skills and styleguides"
  if [[ -d "$project/.agents/skills" ]]; then
    find "$project/.agents/skills" -maxdepth 3 \( -name SKILL.md -o -iname '*styleguide*.md' -o -iname '*Styleguide*.md' \) -print | sed "s#^$project/##" | sort
  else
    log "missing: .agents/skills"
    issues=$((issues + 1))
  fi

  log ""
  log "4. Likely gaps"
  [[ -f "$project/.ai/project-context.md" ]] || { log "gap: .ai/project-context.md missing"; issues=$((issues + 1)); }
  [[ -f "$project/.ai/agent-workflow.md" ]] || { log "gap: .ai/agent-workflow.md missing"; issues=$((issues + 1)); }
  [[ -f "$project/.ai/issue-tracker.md" ]] || { log "gap: .ai/issue-tracker.md missing"; issues=$((issues + 1)); }
  [[ -f "$project/.ai/domain.md" ]] || { log "gap: .ai/domain.md missing"; issues=$((issues + 1)); }
  [[ -f "$project/.ai/tech-stack.md" ]] || { log "gap: .ai/tech-stack.md missing"; issues=$((issues + 1)); }
  [[ -f "$project/.ai/commands.md" ]] || { log "gap: .ai/commands.md missing"; issues=$((issues + 1)); }
  [[ -f "$project/.ai/DESIGN.md" ]] || { log "gap: .ai/DESIGN.md missing"; issues=$((issues + 1)); }
  [[ -d "$project/.ai/specs" ]] || { log "gap: .ai/specs missing"; issues=$((issues + 1)); }
  [[ -d "$project/.ai/tickets" ]] || { log "gap: .ai/tickets missing"; issues=$((issues + 1)); }
  [[ -d "$project/.ai/decisions" ]] || { log "gap: .ai/decisions missing"; issues=$((issues + 1)); }

  if [[ -f "$project/AGENTS.md" && -f "$project/CLAUDE.md" ]] && ! cmp -s "$project/AGENTS.md" "$project/CLAUDE.md"; then
    if is_claude_agents_wrapper "$project/CLAUDE.md"; then
      log "ok: CLAUDE.md differs as an AGENTS.md wrapper"
    else
      log "gap: AGENTS.md and CLAUDE.md differ; review whether this is intentional"
      issues=$((issues + 1))
    fi
  fi

  log ""
  log "5. Recommended standard structure"
  log "AGENTS.md: shared index for all agents"
  log "CLAUDE.md: mirror of AGENTS.md or small Claude-specific wrapper"
  log ".ai/: canonical project context, workflow, tracker rules, domain, commands, design, specs, tickets, decisions"
  log ".agents/skills/: project-specific skills and stack/style guides"
  log ".claude/: Claude-only settings/commands only"
  log ".codex/: Codex-only config only"

  log ""
  log "6. Recommended next steps"
  log "Step 1: use ai-setup-manager deep standardization workflow; this shell report is only inventory"
  log "Step 2: inspect AGENTS.md, CLAUDE.md, .ai files, .agents/skills, .claude, .codex, README, Makefile, and stack configs"
  log "Step 3: compare content for stale references, duplicated rules, contradictions, missing commands, weak design/styleguide coverage, and Claude/Codex parity gaps"
  log "Step 4: produce prioritized recommendations with evidence, impact, destination, exact proposed change, and risk"
  log "Step 5: ask before editing; apply one safe batch at a time"
  log ""
  log "7. Deep standardization output contract"
  log "For each recommendation include: priority, issue, evidence, why it matters, proposed destination, exact change, risk if wrong, and whether user approval is required"

  if [[ "$issues" -gt 0 ]]; then
    log ""
    log "standardization result: recommendations found ($issues signals)"
    return 1
  fi
  log ""
  log "standardization result: already close to standard"
}

update_install() {
  local tools=""
  local skill
  if [[ "$DO_CLAUDE" == "0" && "$DO_CODEX" == "0" ]]; then
    DO_CLAUDE=1
    DO_CODEX=1
  fi

  if [[ "$DRY_RUN" == "1" ]]; then
    log "current install status before update"
    install_status || true
  fi

  log "updating AI Setup"
  refresh_shared_skills

  if [[ "$DO_CODEX" == "1" ]]; then
    while IFS= read -r skill; do
      refresh_tool_skill "$skill" "$HOME/.codex/skills"
    done < <(profile_skill_names)
    if [[ "$DO_GLOBAL_FILES" == "1" ]]; then
      backup_global_file "$HOME/.codex/AGENTS.md"
      run mkdir -p "$HOME/.codex"
      run cp "$ROOT_DIR/setup/global-files/AGENTS.md" "$HOME/.codex/AGENTS.md"
    fi
    tools="${tools}codex"
  fi

  if [[ "$DO_CLAUDE" == "1" ]]; then
    while IFS= read -r skill; do
      refresh_tool_skill "$skill" "$HOME/.claude/skills"
    done < <(profile_skill_names)
    if [[ "$DO_GLOBAL_FILES" == "1" ]]; then
      backup_global_file "$HOME/.claude/CLAUDE.md"
      run mkdir -p "$HOME/.claude"
      run cp "$ROOT_DIR/setup/global-files/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
    fi
    if [[ "$DO_COMMANDS" == "1" ]]; then
      run mkdir -p "$HOME/.claude/commands"
      copy_tree_contents "$ROOT_DIR/setup/claude-commands" "$HOME/.claude/commands"
    fi
    tools="${tools:+$tools,}claude"
  fi

  write_install_metadata "$tools"
  log "update complete"
}

uninstall_setup() {
  log "uninstalling AI Setup"

  for skill in $(skill_names); do
    run rm -rf "$HOME/.agents/skills/$skill"
    run rm -rf "$HOME/.codex/skills/$skill"
    run rm -rf "$HOME/.claude/skills/$skill"
  done

  for cmd in $(command_names); do
    run rm -f "$HOME/.claude/commands/$cmd"
  done

  if [[ "$DO_GLOBAL_FILES" == "1" ]]; then
    backup_global_file "$HOME/.codex/AGENTS.md"
    backup_global_file "$HOME/.claude/CLAUDE.md"
    run rm -f "$HOME/.codex/AGENTS.md"
    run rm -f "$HOME/.claude/CLAUDE.md"
  fi

  run rm -rf "$HOME/.agents/templates/project-kit"
  run rm -f "$HOME/.agents/ai-setup/install.json"
  log "uninstall complete"
  log "Backups, if created, are under $HOME/.agents/backups/"
}

restore_backup() {
  local backup="$1"
  if [[ ! -d "$backup" ]]; then
    log "backup path does not exist: $backup"
    return 1
  fi

  log "restoring backup: $backup"
  if [[ -f "$backup/AGENTS.md" ]]; then
    run mkdir -p "$HOME/.codex"
    run cp "$backup/AGENTS.md" "$HOME/.codex/AGENTS.md"
    log "restored: $HOME/.codex/AGENTS.md"
  elif [[ -f "$backup/codex-AGENTS.md" ]]; then
    run mkdir -p "$HOME/.codex"
    run cp "$backup/codex-AGENTS.md" "$HOME/.codex/AGENTS.md"
    log "restored: $HOME/.codex/AGENTS.md"
  else
    log "skip: no AGENTS.md backup found"
  fi

  if [[ -f "$backup/CLAUDE.md" ]]; then
    run mkdir -p "$HOME/.claude"
    run cp "$backup/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
    log "restored: $HOME/.claude/CLAUDE.md"
  elif [[ -f "$backup/claude-CLAUDE.md" ]]; then
    run mkdir -p "$HOME/.claude"
    run cp "$backup/claude-CLAUDE.md" "$HOME/.claude/CLAUDE.md"
    log "restored: $HOME/.claude/CLAUDE.md"
  else
    log "skip: no CLAUDE.md backup found"
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --all)
      DO_CLAUDE=1
      DO_CODEX=1
      ;;
    --claude)
      DO_CLAUDE=1
      ;;
    --codex)
      DO_CODEX=1
      ;;
    --profile)
      shift
      PROFILE_NAME="${1:-}"
      if [[ -z "$PROFILE_NAME" ]]; then
        log "--profile requires a name"
        exit 1
      fi
      ;;
    --list-profiles)
      RUN_LIST_PROFILES=1
      ;;
    --no-global-files)
      DO_GLOBAL_FILES=0
      ;;
    --no-commands)
      DO_COMMANDS=0
      ;;
    --copy)
      LINK_MODE=0
      ;;
    --link)
      LINK_MODE=1
      ;;
    --force)
      FORCE=1
      ;;
    --dry-run)
      DRY_RUN=1
      ;;
    --init-project)
      shift
      INIT_PROJECT="${1:-}"
      if [[ -z "$INIT_PROJECT" ]]; then
        log "--init-project requires a path"
        exit 1
      fi
      ;;
    --audit-project)
      shift
      AUDIT_PROJECT="${1:-}"
      if [[ -z "$AUDIT_PROJECT" ]]; then
        log "--audit-project requires a path"
        exit 1
      fi
      ;;
    --standardize-project)
      shift
      STANDARDIZE_PROJECT="${1:-}"
      if [[ -z "$STANDARDIZE_PROJECT" ]]; then
        log "--standardize-project requires a path"
        exit 1
      fi
      ;;
    --doctor)
      RUN_DOCTOR=1
      ;;
    --status)
      RUN_STATUS=1
      ;;
    --update)
      RUN_UPDATE=1
      ;;
    --uninstall)
      RUN_UNINSTALL=1
      ;;
    --restore-backup)
      shift
      RESTORE_BACKUP="${1:-}"
      if [[ -z "$RESTORE_BACKUP" ]]; then
        log "--restore-backup requires a path"
        exit 1
      fi
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      log "unknown option: $1"
      usage
      exit 1
      ;;
  esac
  shift
done

if [[ "$RUN_LIST_PROFILES" == "1" ]]; then
  list_profiles
  exit 0
fi

profile_chain "$PROFILE_NAME" >/dev/null

if [[ "$DO_CLAUDE" == "0" && "$DO_CODEX" == "0" && -z "$INIT_PROJECT" && -z "$AUDIT_PROJECT" && -z "$STANDARDIZE_PROJECT" && "$RUN_DOCTOR" == "0" && "$RUN_STATUS" == "0" && "$RUN_UPDATE" == "0" && "$RUN_UNINSTALL" == "0" && -z "$RESTORE_BACKUP" ]]; then
  usage
  exit 0
fi

if [[ -n "$RESTORE_BACKUP" ]]; then
  restore_backup "$RESTORE_BACKUP"
  log "done"
  exit 0
fi

if [[ "$RUN_UNINSTALL" == "1" ]]; then
  uninstall_setup
  log "done"
  exit 0
fi

if [[ "$RUN_UPDATE" == "1" ]]; then
  update_install
  log "done"
  exit 0
fi

if [[ "$RUN_DOCTOR" == "1" ]]; then
  doctor
fi

if [[ "$RUN_STATUS" == "1" ]]; then
  install_status
fi

if [[ "$DO_CODEX" == "1" ]]; then
  install_codex
fi

if [[ "$DO_CLAUDE" == "1" ]]; then
  install_claude
fi

if [[ "$DO_CODEX" == "1" || "$DO_CLAUDE" == "1" ]]; then
  tools=""
  [[ "$DO_CLAUDE" == "1" ]] && tools="${tools}claude"
  [[ "$DO_CODEX" == "1" ]] && tools="${tools:+$tools,}codex"
  write_install_metadata "$tools"
  log "profile: $PROFILE_NAME"
  if [[ "$LINK_MODE" == "0" ]]; then
    log "install mode: copy. The source repo/folder can be deleted after install."
  else
    log "install mode: link. Keep this source repo/folder; installed skills point to it."
  fi
fi

if [[ -n "$INIT_PROJECT" ]]; then
  init_project "$INIT_PROJECT"
fi

if [[ -n "$AUDIT_PROJECT" ]]; then
  audit_project "$AUDIT_PROJECT"
fi

if [[ -n "$STANDARDIZE_PROJECT" ]]; then
  standardize_project "$STANDARDIZE_PROJECT"
fi

log "done"
