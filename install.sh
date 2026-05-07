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
INIT_PROJECT=""
AUDIT_PROJECT=""
STANDARDIZE_PROJECT=""
RUN_DOCTOR=0
RUN_UPDATE=0
RUN_UNINSTALL=0
RESTORE_BACKUP=""
VERSION="0.1.0"

usage() {
  cat <<'USAGE'
AI Setup installer

Usage:
  ./install.sh --all
  ./install.sh --claude
  ./install.sh --codex
  ./install.sh --init-project /path/to/project
  ./install.sh --audit-project /path/to/project
  ./install.sh --standardize-project /path/to/project
  ./install.sh --doctor
  ./install.sh --update
  ./install.sh --uninstall
  ./install.sh --restore-backup /path/to/backup-dir

Options:
  --all                 Install shared skills for Claude and Codex
  --claude              Install shared skills for Claude
  --codex               Install shared skills for Codex
  --no-global-files     Do not update ~/.claude/CLAUDE.md or ~/.codex/AGENTS.md
  --no-commands         Do not install Claude command wrappers
  --copy                Copy skills/templates (default; source repo can be deleted)
  --link                Symlink tool skill folders to this repo (maintainer mode)
  --force               Overwrite project kit files during --init-project
  --dry-run             Print actions without changing files
  --doctor              Check global AI Setup installation health
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
  "source_path": "$ROOT_DIR",
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
  run mkdir -p "$canonical"
  copy_tree_contents "$ROOT_DIR/setup/skills" "$canonical"
}

refresh_shared_skills() {
  local canonical="$HOME/.agents/skills"
  run mkdir -p "$canonical"
  for skill_dir in "$ROOT_DIR"/setup/skills/*; do
    [[ -d "$skill_dir" ]] || continue
    replace_tree "$skill_dir" "$canonical/$(basename "$skill_dir")"
  done
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

install_codex() {
  install_shared_skills
  for skill_dir in "$ROOT_DIR"/setup/skills/*; do
    [[ -d "$skill_dir" ]] || continue
    link_or_copy_skill "$(basename "$skill_dir")" "$HOME/.codex/skills"
  done
  if [[ "$DO_GLOBAL_FILES" == "1" ]]; then
    backup_global_file "$HOME/.codex/AGENTS.md"
    run mkdir -p "$HOME/.codex"
    run cp "$ROOT_DIR/setup/global-files/AGENTS.md" "$HOME/.codex/AGENTS.md"
  fi
}

install_claude() {
  install_shared_skills
  for skill_dir in "$ROOT_DIR"/setup/skills/*; do
    [[ -d "$skill_dir" ]] || continue
    link_or_copy_skill "$(basename "$skill_dir")" "$HOME/.claude/skills"
  done
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
  if [[ ! -d "$project" ]]; then
    log "project path does not exist: $project"
    exit 1
  fi

  while IFS= read -r -d '' file; do
    local rel="${file#"$ROOT_DIR"/setup/project-kit/}"
    copy_file "$file" "$project/$rel"
  done < <(find "$ROOT_DIR/setup/project-kit" -type f -print0)
}

doctor() {
  local failures=0
  log "AI Setup doctor"
  log "version: $VERSION"
  log "root: $ROOT_DIR"

  check_path "setup skills" "$ROOT_DIR/setup/skills" || failures=$((failures + 1))
  check_path "setup project kit" "$ROOT_DIR/setup/project-kit" || failures=$((failures + 1))
  check_path "setup global AGENTS" "$ROOT_DIR/setup/global-files/AGENTS.md" || failures=$((failures + 1))
  check_path "setup global CLAUDE" "$ROOT_DIR/setup/global-files/CLAUDE.md" || failures=$((failures + 1))
  check_path "installed metadata" "$HOME/.agents/ai-setup/install.json" || true
  check_path "installed agents skills" "$HOME/.agents/skills" || failures=$((failures + 1))
  check_path "codex global AGENTS" "$HOME/.codex/AGENTS.md" || true
  check_path "claude global CLAUDE" "$HOME/.claude/CLAUDE.md" || true

  for skill_dir in "$ROOT_DIR"/setup/skills/*; do
    [[ -d "$skill_dir" ]] || continue
    local skill
    skill="$(basename "$skill_dir")"
    check_path "canonical skill $skill" "$HOME/.agents/skills/$skill/SKILL.md" || failures=$((failures + 1))
  done

  check_command claude
  check_command codex
  check_command gemini

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
    ".ai/tech-stack.md"
    ".ai/commands.md"
    ".ai/DESIGN.md"
    ".ai/styleguide.md"
    ".ai/specs"
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

  for rel in ".ai/project-context.md" ".ai/tech-stack.md" ".ai/commands.md" ".ai/DESIGN.md"; do
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
  [[ -f "$project/.ai/tech-stack.md" ]] || { log "gap: .ai/tech-stack.md missing"; issues=$((issues + 1)); }
  [[ -f "$project/.ai/commands.md" ]] || { log "gap: .ai/commands.md missing"; issues=$((issues + 1)); }
  [[ -f "$project/.ai/DESIGN.md" ]] || { log "gap: .ai/DESIGN.md missing"; issues=$((issues + 1)); }
  [[ -d "$project/.ai/specs" ]] || { log "gap: .ai/specs missing"; issues=$((issues + 1)); }
  [[ -d "$project/.ai/decisions" ]] || { log "gap: .ai/decisions missing"; issues=$((issues + 1)); }

  if [[ -f "$project/AGENTS.md" && -f "$project/CLAUDE.md" ]] && ! cmp -s "$project/AGENTS.md" "$project/CLAUDE.md"; then
    log "gap: AGENTS.md and CLAUDE.md differ; review whether this is intentional"
    issues=$((issues + 1))
  fi

  log ""
  log "5. Recommended standard structure"
  log "AGENTS.md: shared index for all agents"
  log "CLAUDE.md: mirror of AGENTS.md or small Claude-specific wrapper"
  log ".ai/: canonical project context, commands, design, specs, decisions"
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
  if [[ "$DO_CLAUDE" == "0" && "$DO_CODEX" == "0" ]]; then
    DO_CLAUDE=1
    DO_CODEX=1
  fi

  log "updating AI Setup"
  refresh_shared_skills

  if [[ "$DO_CODEX" == "1" ]]; then
    for skill_dir in "$ROOT_DIR"/setup/skills/*; do
      [[ -d "$skill_dir" ]] || continue
      refresh_tool_skill "$(basename "$skill_dir")" "$HOME/.codex/skills"
    done
    if [[ "$DO_GLOBAL_FILES" == "1" ]]; then
      backup_global_file "$HOME/.codex/AGENTS.md"
      run mkdir -p "$HOME/.codex"
      run cp "$ROOT_DIR/setup/global-files/AGENTS.md" "$HOME/.codex/AGENTS.md"
    fi
    tools="${tools}codex"
  fi

  if [[ "$DO_CLAUDE" == "1" ]]; then
    for skill_dir in "$ROOT_DIR"/setup/skills/*; do
      [[ -d "$skill_dir" ]] || continue
      refresh_tool_skill "$(basename "$skill_dir")" "$HOME/.claude/skills"
    done
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

if [[ "$DO_CLAUDE" == "0" && "$DO_CODEX" == "0" && -z "$INIT_PROJECT" && -z "$AUDIT_PROJECT" && -z "$STANDARDIZE_PROJECT" && "$RUN_DOCTOR" == "0" && "$RUN_UPDATE" == "0" && "$RUN_UNINSTALL" == "0" && -z "$RESTORE_BACKUP" ]]; then
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
