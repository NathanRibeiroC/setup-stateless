#!/usr/bin/env bash
set -euo pipefail

if ! command -v apt >/dev/null 2>&1; then
  echo "Este script suporta Ubuntu/Debian (apt)."
  exit 1
fi

sudo apt update
sudo apt install -y \
  curl \
  git \
  ca-certificates \
  build-essential \
  unzip \
  jq

echo "Setup base concluido."
