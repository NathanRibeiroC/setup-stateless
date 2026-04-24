#!/usr/bin/env bash
set -euo pipefail

is_wsl() {
  if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
    return 0
  fi

  if [[ -f /proc/sys/kernel/osrelease ]] && grep -qi microsoft /proc/sys/kernel/osrelease; then
    return 0
  fi

  if [[ -f /proc/version ]] && grep -qi microsoft /proc/version; then
    return 0
  fi

  return 1
}

required_cmds_desktop=(
  git
  curl
  wget
  jq
  rg
  tmux
  zsh
  python3
  pipx
  rclone
  node
  npm
  nvim
  code
  google-chrome
  brave-browser
  bitwarden
  dbeaver
  libreoffice
  snap
)

required_cmds_wsl=(
  git
  curl
  wget
  jq
  rg
  tmux
  zsh
  python3
  pipx
  rclone
  node
  npm
  nvim
  dbeaver
)

required_snaps=(
  notion-snap-reborn
  obsidian
)

required_systemd_units=(
  startup-snap-refresh.service
)

ok_items=()
failed_items=()

if is_wsl; then
  required_cmds=("${required_cmds_wsl[@]}")
else
  required_cmds=("${required_cmds_desktop[@]}")
fi

export PATH="${HOME}/.local/bin:${PATH}"
export NVM_DIR="${HOME}/.nvm"
if [[ -s "${NVM_DIR}/nvm.sh" ]]; then
  # shellcheck disable=SC1090
  . "${NVM_DIR}/nvm.sh"
fi

add_ok() {
  ok_items+=("$1")
}

add_failed() {
  failed_items+=("$1")
}

if command -v mise >/dev/null 2>&1 || [[ -x "${HOME}/.local/bin/mise" ]]; then
  add_ok "Command: mise"
else
  add_failed "Command: mise"
fi

if command -v starship >/dev/null 2>&1 || [[ -x "${HOME}/.local/bin/starship" ]]; then
  add_ok "Command: starship"
else
  add_failed "Command: starship"
fi

if [[ -f "${HOME}/.config/starship.toml" ]]; then
  add_ok "Starship config: ${HOME}/.config/starship.toml"
else
  add_failed "Starship config: ${HOME}/.config/starship.toml"
fi

for cmd in "${required_cmds[@]}"; do
  if command -v "$cmd" >/dev/null 2>&1; then
    add_ok "Command: $cmd"
  else
    add_failed "Command: $cmd"
  fi
done

if is_wsl; then
  if [[ -f /etc/wsl.conf ]] && grep -Eq '^\s*systemd\s*=\s*true\s*$' /etc/wsl.conf; then
    add_ok "WSL config: /etc/wsl.conf enables systemd"
  else
    add_failed "WSL config: /etc/wsl.conf enables systemd"
  fi
else
  for pkg in "${required_snaps[@]}"; do
    if snap list "$pkg" >/dev/null 2>&1; then
      add_ok "Snap: $pkg"
    else
      add_failed "Snap: $pkg"
    fi
  done

  for unit in "${required_systemd_units[@]}"; do
    if systemctl is-enabled "$unit" >/dev/null 2>&1; then
      add_ok "Systemd unit enabled: $unit"
    else
      add_failed "Systemd unit enabled: $unit"
    fi
  done
fi

if [[ -d "${HOME}/.config/nvim" ]]; then
  add_ok "LazyVim config: ${HOME}/.config/nvim"
else
  add_failed "LazyVim config: ${HOME}/.config/nvim"
fi

echo "==== Installed Successfully ===="
if [[ "${#ok_items[@]}" -eq 0 ]]; then
  echo "- None"
else
  for item in "${ok_items[@]}"; do
    echo "- ${item}"
  done
fi

echo
echo "==== Missing / Failed ===="
if [[ "${#failed_items[@]}" -eq 0 ]]; then
  echo "- None"
  echo
  echo "Validation completed successfully."
  exit 0
fi

for item in "${failed_items[@]}"; do
  echo "- ${item}"
done

echo
echo "Validation failed."
exit 1
