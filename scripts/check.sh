#!/usr/bin/env bash
set -euo pipefail

required_cmds=(
  git
  curl
  wget
  jq
  rg
  tmux
  zsh
  python3
  pipx
  node
  npm
  nvim
  code
  google-chrome
  brave-browser
  bitwarden
  libreoffice
  snap
)

required_snaps=(
  notion-snap-reborn
  obsidian
)

missing=0

for cmd in "${required_cmds[@]}"; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing command: $cmd"
    missing=1
  else
    echo "OK command: $cmd"
  fi
done

if command -v mise >/dev/null 2>&1 || [[ -x "${HOME}/.local/bin/mise" ]]; then
  echo "OK command: mise"
else
  echo "Missing command: mise"
  missing=1
fi

if command -v jetbrains-toolbox >/dev/null 2>&1 \
  || [[ -x "${HOME}/.local/bin/jetbrains-toolbox" ]] \
  || [[ -x "/usr/local/bin/jetbrains-toolbox" ]] \
  || [[ -x "/opt/jetbrains-toolbox/jetbrains-toolbox" ]]; then
  echo "OK command: jetbrains-toolbox"
else
  echo "Missing command: jetbrains-toolbox"
  missing=1
fi

for pkg in "${required_snaps[@]}"; do
  if ! snap list "$pkg" >/dev/null 2>&1; then
    echo "Missing snap: $pkg"
    missing=1
  else
    echo "OK snap: $pkg"
  fi
done

if [[ ! -d "${HOME}/.config/nvim" ]]; then
  echo "Missing LazyVim config directory: ${HOME}/.config/nvim"
  missing=1
else
  echo "OK LazyVim config directory: ${HOME}/.config/nvim"
fi

if [[ "$missing" -eq 1 ]]; then
  echo "Validation failed."
  exit 1
fi

echo "Validation completed successfully."
