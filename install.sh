#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -f /etc/os-release ]]; then
  echo "Cannot detect Linux distribution: /etc/os-release not found."
  exit 1
fi

# shellcheck disable=SC1091
. /etc/os-release

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

run_installer() {
  local installer="$1"
  if [[ ! -x "$installer" ]]; then
    chmod +x "$installer"
  fi
  bash "$installer"
}

run_check() {
  local check_script="${SCRIPT_DIR}/scripts/check.sh"
  if [[ ! -x "$check_script" ]]; then
    chmod +x "$check_script"
  fi
  echo
  echo "[setup] Running post-install validation..."
  bash "$check_script"
}

case "${ID:-}" in
  ubuntu)
    if is_wsl; then
      run_installer "${SCRIPT_DIR}/installers/wsl-ubuntu.sh"
    else
      run_installer "${SCRIPT_DIR}/installers/ubuntu.sh"
    fi
    ;;
  *)
    if [[ "${ID_LIKE:-}" == *"ubuntu"* || "${ID_LIKE:-}" == *"debian"* ]]; then
      if is_wsl; then
        run_installer "${SCRIPT_DIR}/installers/wsl-ubuntu.sh"
      else
        run_installer "${SCRIPT_DIR}/installers/ubuntu.sh"
      fi
    else
      echo "Unsupported distribution: ${ID:-unknown}"
      echo "Currently supported: ubuntu, ubuntu on WSL"
      exit 1
    fi
    ;;
esac

run_check
