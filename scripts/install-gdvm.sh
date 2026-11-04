#!/usr/bin/env bash
# download and run the upstream GDVM installer as the current user.
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  printf 'This installer is for macOS only.\n' >&2
  exit 1
fi

if command -v gdvm >/dev/null 2>&1 || [[ -x "$HOME/.gdvm/bin/gdvm" ]]; then
  printf 'GDVM is already installed; skipping (use gdvm upgrade to update).\n'
  exit 0
fi

# Upstream asks about shortcuts via /dev/tty, even when stdin is redirected.
if ! ( : </dev/tty ) 2>/dev/null; then
  printf 'GDVM installation is interactive; rerun setup from a terminal.\n' >&2
  exit 1
fi

installer="$(mktemp "${TMPDIR:-/tmp}/gdvm-install.XXXXXX")"
trap 'rm -f "$installer"' EXIT

# Finish the HTTPS download before executing; never run a partial response.
curl --fail --silent --show-error --location --retry 3 \
  --proto '=https' --proto-redir '=https' \
  --output "$installer" https://gdvm.io/install.sh
bash -n "$installer"

# Upstream appends to the profile selected by SHELL. Our .zshrc is a symlink
# into this repository, so suppress those edits and manage PATH/completions here.
printf 'Running upstream GDVM installer; shell profile edits are disabled.\n'
printf 'Its "Could not detect shell profile file" notice is expected.\n'
SHELL='' bash "$installer"

"$HOME/.gdvm/bin/gdvm" --version
printf 'GDVM ready. Open a new Terminal window, then run gdvm --help.\n'
