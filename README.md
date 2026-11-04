# Dotfiles — macOS setup

A small, repeatable development setup for macOS (Apple Silicon or Intel):
Homebrew, Zsh, Starship, Vim, Git/GitHub, `uv`, and Godot.

## New Mac: quick start

1. Install Apple's command line tools, if missing:

   ~~~bash
   xcode-select -p || xcode-select --install
   ~~~

2. Install [Homebrew](https://brew.sh):

   ~~~bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ~~~

3. Clone and run the setup:

   ~~~bash
   git clone https://github.com/avivajpeyi/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ./setup.sh
   ~~~

   The script installs the `Brewfile`, symlinks the configuration into your
   home directory, and installs Vim plugins with vim-plug. It backs up any
   existing conflicting files to `~/.dotfiles-backups/`; re-running it is safe.
   It does **not** delete packages or overwrite secrets.

4. Authenticate GitHub (the CLI can help create/upload a new SSH key):

   ~~~bash
   gh auth login --git-protocol ssh --web
   gh auth status
   ssh -T git@github.com
   ~~~

5. For Python research projects, let `uv` use the version declared by each
   project, rather than forcing a global Python or using global `pip`:

   ~~~bash
   cd path/to/project
   uv sync
   uv run python --version
   ~~~

## Updating

~~~bash
cd ~/dotfiles
git pull
./setup.sh
~~~

Optional flags: `--skip-brew`, `--skip-vim-plugins`, `--help`.
You can check installed Homebrew dependencies with
`brew bundle check --file ~/dotfiles/Brewfile`. The setup uses
`--no-upgrade` to avoid unexpectedly upgrading existing packages.

## Included config

- `Brewfile`: terminal tools plus iTerm2, VS Code, Godot, Rectangle,
  Hidden Bar and MeetingBar.
- `.zprofile`, `.zshrc`, `.zsh_aliases`, `.zsh_functions`:
  Zsh with fzf, zoxide, Starship and selected older convenience commands.
- `.vimrc`: vim-plug, NERDTree (toggle with F6 or Leader+n),
  fzf, lightline, ALE and lightweight editing defaults.
- `gitconfig`: existing Git identity and useful GitHub aliases.
  Use `~/.gitconfig.local` for private or machine-specific overrides.

The historical Bash files (`.bashrc`, `.bash_aliases`,
`.custom_functions`) are retained as a reference, but are **not**
linked or sourced by the macOS installer. Linux-specific utilities,
the unused Vundle setup, automatic NERDTree startup and fragile
hard-coded GitHub URL parsing are intentionally not carried over.

## Notes

- macOS Zsh is already installed; no framework or alternate Zsh is needed.
- GitHub SSH authentication is deliberately interactive. Never commit private
  SSH keys, tokens, `.env` files or machine-specific credentials.
- Your global `~/.gitconfig` is symlinked to this repository. Check
  `git diff` before committing if other software changes Git settings.
- Homebrew installs the **latest available Godot version**. For existing
  projects, use the editor version they were developed/tested against if
  a newer editor would require migration.
- For Vim plugins after an update, run `vim +PlugUpdate +qall`.
- Optional extras (such as MacTeX) are intentionally excluded from the
  default installation because they are large.
