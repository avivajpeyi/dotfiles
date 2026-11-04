# Modern Mac dotfiles

A clean macOS setup for **scientific Python development**. No legacy Bash,
Linux/HPC aliases, Vim plugin managers, Conda, or global Python installs.

## New Mac

1. Install Apple's developer command-line tools (if not already installed):

   ```sh
   xcode-select -p || xcode-select --install
   ```

2. Install [Homebrew](https://brew.sh):

   ```sh
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

3. Clone this repo and run:

   ```sh
   git clone https://github.com/avivajpeyi/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ./setup.sh
   ```

   The installer installs `Brewfile`, creates symlinks for Zsh/Vim/Git,
   and installs VS Code Python extensions (when its `code` command is on
   your PATH). Conflicting home-directory files are backed up in
   `~/.dotfiles-backups/`. Re-running is safe.

4. Authenticate GitHub. The CLI can offer to generate/upload a fresh SSH
   key (don't copy private keys to GitHub).

   ```sh
   gh auth login --git-protocol ssh --web
   gh auth status
   ssh -T git@github.com
   ```

5. Reopen Terminal to load the new Zsh settings. In VS Code, optionally
   enable **Settings Sync** to restore your editor preferences.

## Included by default

- **Python/science:** `uv` for Python versions, virtual environments and
  reproducible installs; `ruff` for linting and formatting; `cmake` and
  `pkgconf` for occasional native scientific dependencies. No forced
  global `numpy`/`scipy` or Python version.
- **Editor/Git:** VS Code with Python, Pylance, Jupyter, Ruff, TOML and
  Remote-SSH extensions; Vim for quick editing; `gh`, Git LFS, delta.
- **Terminal:** macOS Zsh with Starship, fzf and zoxide; ripgrep, fd, bat,
  tmux, jq and btop.
- **Mac utilities:** [Mole](https://github.com/tw93/Mole) CLI cleaner/health
  monitor, [Stats](https://github.com/exelban/stats) menu-bar monitor,
  Rectangle window management and iTerm2.

No background monitoring service, cleanup job or remote access is enabled
by the installer. Stats is a GUI app you can open and configure yourself.

## Everyday Python workflow

For an existing project with `pyproject.toml` and `uv.lock`:

```sh
cd path/to/project
uv sync
uv run pytest
uv run python
```

`uv` will use the project's declared Python version or fetch one as needed.
For a fresh scientific project:

```sh
uv init --package --python 3.13 my-science-project
cd my-science-project
uv add numpy scipy pandas matplotlib astropy
uv add --dev pytest ruff ipykernel
uv run --with jupyter jupyter lab
```

In VS Code notebooks, choose the project's `.venv/bin/python` kernel.
Notebook packages belong to each project, not a global environment. For
older astronomy stacks, pin the Python version supported by those packages.
See [uv with Jupyter](https://docs.astral.sh/uv/guides/integration/jupyter/).

## Optional: Godot and private remote networking

```sh
cd ~/dotfiles
./setup.sh --extras
```

`Brewfile.optional` installs Godot, Tailscale and ffmpeg. Godot's Homebrew
version may be newer than the editor used for a particular game project.
Tailscale requires a separate sign-in and setup; it is not enabled by this
installer. To install only one extra, use `brew install --cask godot`
or `brew install --cask tailscale-app`.

### SSH **into** this Mac

SSH *from* your Mac to GitHub needs `gh auth login` above. SSH *into* your Mac
is a separate, opt-in configuration:

1. Open **System Settings > General > Sharing > Remote Login**.
2. Enable Remote Login, set **Allow access for: Only these users**, and
   select your macOS account. Leave full-disk access for remote users off
   unless necessary.
3. On this Mac, run `~/dotfiles/scripts/ssh-info.sh`; it prints the
   local-network SSH command using your current macOS username and name.
4. From another machine on the same LAN, try the printed
   `ssh user@MacName.local` command. For key-based login, add the
   *client machine's public key* to this Mac's `~/.ssh/authorized_keys`.
   Do not commit private keys.
5. For remote access outside your LAN, install/sign in to
   [Tailscale](https://tailscale.com/) on both computers, then SSH to the
   Mac's Tailscale address (also displayed by the helper if available).
   Do not open/forward port 22 on your router.

Keep the Mac awake and connected while remote sessions are needed. For
long-running research processes, use `tmux` so SSH disconnections do not
terminate your terminal session. See [Apple's Remote Login guide](https://support.apple.com/guide/mac-help/allow-a-remote-computer-to-access-your-mac-mchlp1066/mac).

## Monitoring and cleanup

- Run `btop` for an interactive CPU/RAM/process dashboard.
- Open **Stats** for CPU, memory, temperatures (when supported), and network
  activity in the menu bar.
- Run `mo status` for Mole's terminal status dashboard.
- Run `mo analyze` to inspect disk usage.
- Before deleting anything with Mole, **preview first**:
  `mo clean --dry-run`, `mo purge --dry-run`. Review carefully—some
  cleanup operations permanently remove files, including developer caches.

## Maintaining the setup

```sh
cd ~/dotfiles
git pull
./setup.sh
```

Flags: `--extras`, `--skip-brew`, `--skip-vscode`, `--help`.
`brew bundle check --file ~/dotfiles/Brewfile` reports missing core packages.
Keep machine-specific Git overrides in `~/.gitconfig.local` rather than
tracking personal credentials or secrets.
