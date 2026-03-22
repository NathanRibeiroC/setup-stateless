#!/usr/bin/env bash
set -euo pipefail

required=(git curl jq)
missing=0

for cmd in "${required[@]}"; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Faltando: $cmd"
    missing=1
  else
    echo "OK: $cmd"
  fi
done

if [[ "$missing" -eq 1 ]]; then
  exit 1
fi

echo "Validacao concluida com sucesso."
