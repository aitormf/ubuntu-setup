#!/usr/bin/env bash
# Instalador de zellij para sistemas basados en apt (Debian/Ubuntu).

set -euo pipefail

if command -v zellij >/dev/null 2>&1; then
  echo "zellij ya está instalado en el sistema: $(command -v zellij)"
  exit 0
fi

bash <(curl -L zellij.dev/launch)
