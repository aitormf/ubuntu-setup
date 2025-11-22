#!/usr/bin/env bash
# Instalador de htop para sistemas basados en apt (Debian/Ubuntu).

set -euo pipefail

if command -v htop >/dev/null 2>&1; then
  echo "htop ya está instalado en el sistema: $(command -v htop)"
  exit 0
fi

sudo apt install htop
