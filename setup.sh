#!/usr/bin/env bash
# Safe, repeatable setup for a new Mac.
set -euo pipefail

repo_dir="$(cd "$(dirname "$0")" && pwd -P)"
install_brew=true
install_extras=false
install_vscode=true
backup_dir=""

usage() {
  cat <<'HELP'
Usage: ./setup.sh [--extras] [--skip-brew] [--skip-vscode] [--help]

Installs the core Brewfile, backs up and symlinks dotfiles, and installs
VS Code Python extensions if the 'code' CLI is available.
--extras enables the optional Godot, Tailscale and ffmpeg Brewfile.
No services, remote login, SSH keys, or cleanup jobs are enabled.
HELP
}

while (( $# > 0 )); do
  case "$1" in
    --extras) install_extras=true ;;
    --skip-brew) install_brew=false ;;
    --skip-vscode) install_vscode=false ;;
    --help|-h) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

if [[ "$(uname -s)" != "Darwin" ]]; then
  printf 'This installer is for macOS only.\n' >&2
  exit 1
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

if [[ "$install_brew" == true ]]; then
  if ! command -v brew >/dev/null 2>&1; then
    printf 'Install Homebrew from https://brew.sh first, then rerun.\n' >&2
    exit 1
  fi
  brew bundle --file="$repo_dir/Brewfile" --no-upgrade
  if [[ "$install_extras" == true ]]; then
    brew bundle --file="$repo_dir/Brewfile.optional" --no-upgrade
  fi
elif [[ "$install_extras" == true ]]; then
  printf 'Note: --extras ignored because --skip-brew was specified.\n'
fi

link_file() {
  local source="$repo_dir/$1"
  local destination="$HOME/$2"
  [[ -f "$source" ]] || { printf 'Missing source: %s\n' "$source" >&2; return 1; }
  if [[ -L "$destination" ]] && [[ "$(readlink "$destination")" == "$source" ]]; then
    printf 'Already linked: %s\n' "$destination"
    return 0
  fi
  if [[ -e "$destination" || -L "$destination" ]]; then
    if [[ -z "$backup_dir" ]]; then
      mkdir -p "$HOME/.dotfiles-backups"
      backup_dir="$(mktemp -d "$HOME/.dotfiles-backups/$(date +%Y%m%d).XXXXXX")"
    fi
    mv "$destination" "$backup_dir/$2"
    printf 'Backed up %s\n' "$destination"
  fi
  ln -s "$source" "$destination"
  printf 'Linked %s -> %s\n' "$destination" "$source"
}

link_file .zprofile .zprofile
link_file .zshrc .zshrc
link_file .zsh_aliases .zsh_aliases
link_file .zsh_functions .zsh_functions
link_file .vimrc .vimrc
link_file gitconfig .gitconfig

mkdir -p "$HOME/.vim/undo"

if [[ "$install_vscode" == true ]]; then
  "$repo_dir/scripts/install-vscode-extensions.sh"
fi

printf '\nSetup complete. Open a new Terminal window.\n'
printf 'GitHub login: gh auth login --git-protocol ssh --web\n'
printf 'Local SSH details: ./scripts/ssh-info.sh\n'
printf 'Scientific Python: uv sync, then uv run python (inside a project).\n'
if [[ -n "$backup_dir" ]]; then
  printf 'Existing files backed up in: %s\n' "$backup_dir"
fi
