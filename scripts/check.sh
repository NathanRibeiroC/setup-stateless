#!/usr/bin/env bash
set -euo pipefail

required=(
  git
  curl
  wget
  jq
  rg
  tmux
  zsh
  python3
  pipx
)
missing=0

for cmd in "${required[@]}"; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing: $cmd"
    missing=1
  else
    echo "OK: $cmd"
  fi
done

if [[ "$missing" -eq 1 ]]; then
  echo "Validation failed."
  exit 1
fi

echo "Validation completed successfully."
