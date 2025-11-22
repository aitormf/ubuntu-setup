#!/usr/bin/env bash
# Instalador de btop para sistemas basados en apt (Debian/Ubuntu).

set -euo pipefail

if command -v btop >/dev/null 2>&1; then
  echo "btop ya está instalado en el sistema: $(command -v btop)"
  exit 0
fi

sudo apt install btop
