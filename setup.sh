#!/usr/bin/env bash
# Idempotent macOS setup: install packages, link dotfiles, then install Vim plugins.
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
install_brew=true
install_vim_plugins=true
backup_dir=""

usage() {
  cat <<'HELP'
Usage: ./setup.sh [--skip-brew] [--skip-vim-plugins] [--help]

Install packages from Brewfile and symlink macOS/Zsh, Git and Vim settings.
Existing files are backed up under ~/.dotfiles-backups/.
Run again safely after pulling updates; existing correct symlinks are left alone.
HELP
}

while (( $# > 0 )); do
  case "$1" in
    --skip-brew) install_brew=false ;;
    --skip-vim-plugins) install_vim_plugins=false ;;
    --help|-h) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

if [[ "$(uname -s)" != "Darwin" ]]; then
  printf 'This installer is for macOS. Use --help for options.\n' >&2
  exit 1
fi

if [[ "$install_brew" == true ]]; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  if ! command -v brew >/dev/null 2>&1; then
    printf 'Install Homebrew first: https://brew.sh (then rerun this script).\n' >&2
    exit 1
  fi
  brew bundle --file="$repo_dir/Brewfile" --no-upgrade
fi

link_file() {
  local source="$repo_dir/$1"
  local destination="$HOME/$2"
  [[ -f "$source" ]] || { printf 'Missing dotfile: %s\n' "$source" >&2; return 1; }

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

if [[ "$install_vim_plugins" == true ]]; then
  mkdir -p "$HOME/.vim/autoload" "$HOME/.vim/undo"
  if [[ ! -f "$HOME/.vim/autoload/plug.vim" ]]; then
    curl -fL --retry 3 \
      -o "$HOME/.vim/autoload/plug.vim" \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  fi
  if command -v vim >/dev/null 2>&1; then
    if ! vim -Nu "$HOME/.vimrc" -n -es -c 'PlugInstall --sync' -c 'qa!'; then
      printf 'Vim plugins did not fully install. Try: vim +PlugInstall +qall\n' >&2
    fi
  fi
fi

printf '\nSetup complete. Open a new Terminal window.\n'
printf 'Authenticate GitHub separately: gh auth login --git-protocol ssh --web\n'
printf 'For Python projects: uv sync (inside each project directory).\n'
if [[ -n "$backup_dir" ]]; then
  printf 'Backups: %s\n' "$backup_dir"
fi
