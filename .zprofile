# Homebrew is installed in different locations on Apple Silicon and Intel Macs.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Prefer GDVM's Godot shim when the optional version manager is installed.
if [[ -d "$HOME/.gdvm/bin" ]]; then
  typeset -U path
  path=("$HOME/.gdvm/bin" "$HOME/.gdvm/bin/current_godot" $path)
fi
