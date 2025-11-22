#!/usr/bin/env bash
# Instalador de yakuake para sistemas basados en apt (Debian/Ubuntu).

set -euo pipefail

if command -v yakuake >/dev/null 2>&1; then
  echo "yakuake ya está instalado en el sistema: $(command -v yakuake)"
  exit 0
fi

sudo apt install yakuake
