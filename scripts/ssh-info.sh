#!/usr/bin/env bash
# Prints how to connect to this Mac; does not change SSH or network settings.
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  printf 'This helper is intended for macOS.\n' >&2
  exit 1
fi

username="$(id -un)"
computer_name="$(scutil --get LocalHostName 2>/dev/null || hostname -s)"
printf 'Mac user: %s\n' "$username"
printf 'Local network: ssh %s@%s.local\n' "$username" "$computer_name"

if command -v tailscale >/dev/null 2>&1; then
  tailnet_ip="$(tailscale ip -4 2>/dev/null | head -n 1 || true)"
  if [[ -n "$tailnet_ip" ]]; then
    printf 'Over Tailscale: ssh %s@%s\n' "$username" "$tailnet_ip"
  fi
fi

printf '\nRemote Login must be enabled manually:\n'
printf 'System Settings > General > Sharing > Remote Login.\n'
printf 'Choose Only these users and prefer SSH key authentication.\n'
