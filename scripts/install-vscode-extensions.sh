#!/usr/bin/env bash
# The VS Code CLI is not always on PATH immediately after installation.
set -euo pipefail
if ! command -v code >/dev/null 2>&1; then
  printf "VS Code 'code' CLI not on PATH; skipping extensions.\n"
  printf 'In VS Code: Command Palette > Shell Command: Install code command in PATH.\n'
  exit 0
fi

extensions=(
  ms-python.python
  ms-python.vscode-pylance
  ms-toolsai.jupyter
  charliermarsh.ruff
  tamasfe.even-better-toml
  ms-vscode-remote.remote-ssh
)

for extension in "${extensions[@]}"; do
  if ! code --install-extension "$extension"; then
    printf 'Warning: VS Code extension failed: %s\n' "$extension" >&2
  fi
done
