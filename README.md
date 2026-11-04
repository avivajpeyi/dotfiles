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

For per-project Godot versions, install [GDVM](https://gdvm.io/) explicitly
from a terminal:

```sh
./setup.sh --gdvm
# Skip Homebrew and VS Code installation if they are already set up:
./setup.sh --gdvm --skip-brew --skip-vscode
```

`--gdvm` is independent of `--extras` and off by default. It downloads
`https://gdvm.io/install.sh` over HTTPS to a temporary file, stops on download
or shell syntax errors, then runs the upstream installer as your user.
This executes the current upstream script; inspect the
[installer](https://gdvm.io/install.sh) before opting in. Existing GDVM
installations (on PATH or in `~/.gdvm/bin`) are left alone; update explicitly
with `gdvm upgrade`.

The wrapper disables upstream shell-profile edits because `.zshrc` is linked
into this repository. Its "Could not detect shell profile file" notice is
expected. These dotfiles manage GDVM's PATH and Zsh completion instead. The
upstream installer can ask about a shortcut and file associations; those
choices are yours. Restart Terminal afterward, then use `gdvm --help`,
`gdvm list`, or `gdvm run` inside a game project. Select/pin the editor version
that the project was tested with; this setup does not select one for you.

If you prefer a single Homebrew-managed Godot app, use the existing extras:

```sh
cd ~/dotfiles
./setup.sh --extras
```

`Brewfile.optional` installs Godot, Tailscale and ffmpeg. Godot's Homebrew
version may be newer than the editor used for a particular game project.
Tailscale requires a separate sign-in and setup; it is not enabled by this
installer. To install only one extra, use `brew install --cask godot`
or `brew install --cask tailscale-app`.
Choose GDVM or the Homebrew Godot app for your workflow. If both are installed,
these shell settings put GDVM first; `gdvm run` makes the choice explicit.

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

Flags: `--extras`, `--gdvm`, `--skip-brew`, `--skip-vscode`, `--help`.
`brew bundle check --file ~/dotfiles/Brewfile` reports missing core packages.
Keep machine-specific Git overrides in `~/.gitconfig.local` rather than
tracking personal credentials or secrets.

## A few optional next additions

Keep scientific packages and checks in each project's locked environment.
These are recommendations, not part of the installer:

- [direnv](https://direnv.net/): load project environment variables when
  entering a directory. Review each `.envrc` before `direnv allow`; it runs
  shell code and needs a [Zsh hook](https://direnv.net/docs/hook.html).
- [pre-commit](https://pre-commit.com/): run Ruff and basic file checks before
  committing. Configure hooks per repository; Ruff has a
  [supported integration](https://docs.astral.sh/ruff/integrations/#pre-commit).
- [GDScript Toolkit](https://github.com/Scony/godot-gdscript-toolkit):
  `gdlint` and `gdformat` for Godot projects. Match its major version to
  Godot; for Godot 4, add `uv add --dev 'gdtoolkit==4.*'` in the project's
  Python tooling environment and commit the lockfile.
- For monitoring, start with the included **Stats + btop** before adding
  another monitor. For secure remote access, use the optional **Tailscale
  app + macOS Remote Login + SSH keys**, as described above. The separate
  [Tailscale SSH server](https://tailscale.com/docs/features/tailscale-ssh)
  requires the open-source `tailscaled` variant on macOS; the GUI app alone
  does not provide it.
