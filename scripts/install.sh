#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

TOOL=""
PROJECT_DIR="${PWD}"
PROJECT_DIR_SET=0

usage() {
  cat << 'USAGE'
Usage:
  ./scripts/install.sh --tool <name> [--project <path>]

Options:
  --tool <name>       Install one target: codex|claude|gemini|cursor.
  --project <path>    Project path for Cursor rule install.
                      If omitted with --tool cursor, current directory is used.
  -h, --help          Show this help.

Examples:
  ./scripts/install.sh --tool codex
  ./scripts/install.sh --tool claude
  ./scripts/install.sh --tool gemini
  ./scripts/install.sh --tool cursor --project /path/to/your/project
  ./scripts/install.sh --tool cursor
USAGE
}

ensure_import_line() {
  local file="$1"
  local line="$2"
  mkdir -p "$(dirname "$file")"
  touch "$file"
  if ! grep -Fqx "$line" "$file"; then
    printf "\n%s\n" "$line" >> "$file"
  fi
}

install_codex() {
  local codex_home="${CODEX_HOME:-$HOME/.codex}"
  local dest="$codex_home/skills/isaaclab-to-mjlab"
  mkdir -p "$(dirname "$dest")"
  rsync -a --delete --exclude '.git/' "$REPO_DIR/" "$dest/"
  echo "[codex] installed: $dest"
}

install_claude() {
  local rules_dir="$HOME/.claude/rules"
  local main_file="$HOME/.claude/CLAUDE.md"
  local rule_file="$rules_dir/isaaclab-to-mjlab.md"

  mkdir -p "$rules_dir"
  cp "$REPO_DIR/shared/isaaclab-to-mjlab-rules.md" "$rule_file"
  ensure_import_line "$main_file" "@$rule_file"
  echo "[claude] installed rule: $rule_file"
  echo "[claude] linked in: $main_file"
}

install_gemini() {
  local rules_dir="$HOME/.gemini/rules"
  local main_file="$HOME/.gemini/GEMINI.md"
  local rule_file="$rules_dir/isaaclab-to-mjlab.md"

  mkdir -p "$rules_dir"
  cp "$REPO_DIR/shared/isaaclab-to-mjlab-rules.md" "$rule_file"
  ensure_import_line "$main_file" "@$rule_file"
  echo "[gemini] installed rule: $rule_file"
  echo "[gemini] linked in: $main_file"
}

install_cursor() {
  local project_dir="$1"
  local rules_dir="$project_dir/.cursor/rules"
  local rule_file="$rules_dir/isaaclab-to-mjlab.mdc"

  mkdir -p "$rules_dir"
  cp "$REPO_DIR/adapters/cursor/isaaclab-to-mjlab.mdc" "$rule_file"
  echo "[cursor] installed project rule: $rule_file"
}

resolve_cursor_project_dir() {
  if [[ "$PROJECT_DIR_SET" -eq 1 ]]; then
    echo "$PROJECT_DIR"
    return
  fi

  if command -v git >/dev/null 2>&1; then
    local git_root
    git_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
    if [[ -n "$git_root" ]]; then
      echo "$git_root"
      return
    fi
  fi

  echo "$PWD"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tool)
      if [[ $# -lt 2 ]]; then
        echo "--tool requires a value" >&2
        exit 1
      fi
      TOOL="$2"
      shift 2
      ;;
    --project)
      if [[ $# -lt 2 ]]; then
        echo "--project requires a path" >&2
        exit 1
      fi
      PROJECT_DIR="$2"
      PROJECT_DIR_SET=1
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$TOOL" ]]; then
  echo "--tool is required (codex|claude|gemini|cursor)" >&2
  usage
  exit 1
fi

if [[ "$PROJECT_DIR_SET" -eq 1 && "$TOOL" != "cursor" ]]; then
  echo "[info] --project is ignored unless installing --tool cursor"
fi

case "$TOOL" in
  codex)
    install_codex
    ;;
  claude)
    install_claude
    ;;
  gemini)
    install_gemini
    ;;
  cursor)
    PROJECT_DIR="$(resolve_cursor_project_dir)"
    if [[ ! -d "$PROJECT_DIR" ]]; then
      echo "Project directory does not exist: $PROJECT_DIR" >&2
      exit 1
    fi
    PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"
    echo "[cursor] target project: $PROJECT_DIR"
    install_cursor "$PROJECT_DIR"
    ;;
  *)
    echo "Unsupported tool: $TOOL" >&2
    exit 1
    ;;
esac

echo "Done."
