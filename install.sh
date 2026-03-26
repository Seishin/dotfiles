#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_DIR="$SCRIPT_DIR"

usage() {
  cat <<'EOF'
Usage: ./install.sh [--dry-run] [--brew] [--backup-dir DIR] [--yes]

Symlinks this repo's dotfiles into $HOME and backs up any existing files first.

Options:
  --dry-run         Print actions without changing anything
  --brew            Install common dependencies via Homebrew (macOS)
  --backup-dir DIR  Backup destination (default: ~/.dotfiles-backup/<timestamp>)
  --yes             Non-interactive: overwrite conflicts (with backups)
  -h, --help        Show help
EOF
}

DRY_RUN=0
BREW=0
YES=0
BACKUP_DIR=""
SKIPPED_COUNT=0
APPLIED_COUNT=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    --brew) BREW=1; shift ;;
    --yes) YES=1; shift ;;
    --backup-dir) BACKUP_DIR="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 2 ;;
  esac
done

timestamp() { date +"%Y%m%d-%H%M%S"; }

log() { printf "%s\n" "$*"; }
run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "[dry-run] $*"
  else
    "$@"
  fi
}

backup_root_default="$HOME/.dotfiles-backup/$(timestamp)"
if [[ -z "$BACKUP_DIR" ]]; then
  BACKUP_DIR="$backup_root_default"
fi

ensure_parent_dir() {
  local path="$1"
  run mkdir -p "$(dirname -- "$path")"
}

prompt_yn() {
  local prompt="$1"
  local reply=""

  if [[ "$YES" -eq 1 ]]; then
    return 0
  fi

  while true; do
    if [[ -t 0 ]]; then
      read -r "reply?$prompt [y/N] " </dev/tty || true
    else
      read -r "reply?$prompt [y/N] " || true
    fi
    case "${reply:-}" in
      y|Y|yes|YES) return 0 ;;
      ""|n|N|no|NO) return 1 ;;
      *) log "Please answer y or n." ;;
    esac
  done
}

prompt_conflict() {
  local dst="$1"
  local reply=""

  if [[ "$YES" -eq 1 ]]; then
    printf "%s" "overwrite"
    return 0
  fi

  log "Conflict: $dst exists."
  log "Choose: [o]verwrite (backup then install), [s]kip, [c]ancel"
  while true; do
    if [[ -t 0 ]]; then
      read -r "reply?Selection (o/s/c): " </dev/tty || true
    else
      read -r "reply?Selection (o/s/c): " || true
    fi
    case "${reply:-}" in
      o|O) printf "%s" "overwrite"; return 0 ;;
      s|S) printf "%s" "skip"; return 0 ;;
      c|C) printf "%s" "cancel"; return 0 ;;
      *) log "Please enter o, s, or c." ;;
    esac
  done
}

backup_path_for() {
  # Preserve paths under backup dir to avoid collisions (config/init.vim/etc.)
  local target="$1"
  local rel="$target"
  rel="${rel/#$HOME\//HOME/}"
  printf "%s/%s" "$BACKUP_DIR" "$rel"
}

backup_if_exists() {
  local target="$1"
  if [[ -e "$target" || -L "$target" ]]; then
    local dest
    dest="$(backup_path_for "$target")"
    ensure_parent_dir "$dest"
    run mv -f "$target" "$dest"
  fi
}

link_file() {
  local src="$1"
  local dst="$2"

  if [[ ! -e "$src" ]]; then
    echo "Missing source: $src" >&2
    exit 1
  fi

  if ! prompt_yn "Install $dst -> $src?"; then
    log "Skip: $dst"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
    return 0
  fi

  ensure_parent_dir "$dst"

  if [[ -e "$dst" || -L "$dst" ]]; then
    local action
    action="$(prompt_conflict "$dst")"
    case "$action" in
      overwrite)
        backup_if_exists "$dst"
        ;;
      skip)
        log "Skip (exists): $dst"
        SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
        return 0
        ;;
      cancel)
        log "Cancelled."
        exit 1
        ;;
    esac
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "[dry-run] ln -s $src $dst"
    log "Would link: $dst -> $src"
    APPLIED_COUNT=$((APPLIED_COUNT + 1))
    return 0
  fi

  ln -s "$src" "$dst"
  log "Linked: $dst -> $src"
  APPLIED_COUNT=$((APPLIED_COUNT + 1))
}

ensure_homebrew_deps() {
  if [[ "$BREW" -ne 1 ]]; then
    return 0
  fi

  if [[ "$(uname -s)" != "Darwin" ]]; then
    log "Skip Homebrew installs: not macOS"
    return 0
  fi

  if ! command -v brew >/dev/null 2>&1; then
    log "Homebrew not found. Install it first, then re-run with --brew."
    log "See: https://brew.sh/"
    return 0
  fi

  # CLI tools referenced by .zshrc aliases/init
  run brew install eza fd ripgrep fzf zoxide

  # Editor/terminal used by these dotfiles
  run brew install neovim
  run brew install --cask ghostty || true

  # fzf post-install is safe to ignore if already configured
  run "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc || true
}

main() {
  log "Repo: $REPO_DIR"
  log "Backup dir: $BACKUP_DIR"
  [[ "$DRY_RUN" -eq 1 ]] && log "Mode: dry-run"
  [[ "$YES" -eq 1 ]] && log "Mode: non-interactive (--yes)"

  ensure_homebrew_deps

  # Home dotfiles
  link_file "$REPO_DIR/.zshrc" "$HOME/.zshrc"
  link_file "$REPO_DIR/.vimrc" "$HOME/.vimrc"

  # Neovim: prefer XDG config layout, but don't fight an existing ~/.config/nvim symlink.
  local xdg_config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
  local nvim_dir="$xdg_config_home/nvim"
  local nvim_init="$nvim_dir/init.vim"
  if [[ -L "$nvim_dir" ]]; then
    log "Neovim config is a symlink ($nvim_dir). Leaving it as-is."
  else
    ensure_parent_dir "$nvim_init"
    link_file "$HOME/.vimrc" "$nvim_init"
  fi

  # Ghostty (macOS default location)
  local ghostty_dir="$HOME/Library/Application Support/com.mitchellh.ghostty"
  link_file "$REPO_DIR/ghostty/config" "$ghostty_dir/config"
  link_file "$REPO_DIR/ghostty/themes" "$ghostty_dir/themes"

  log "Done."
  log "Summary: applied=$APPLIED_COUNT skipped=$SKIPPED_COUNT"
  if [[ -d "$BACKUP_DIR" ]]; then
    log "Backups saved to: $BACKUP_DIR"
  fi
}

main

