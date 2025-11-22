#!/usr/bin/env bash
# Instalador de lf para sistemas basados en apt (Debian/Ubuntu).

set -euo pipefail

if command -v lf >/dev/null 2>&1; then
  echo "lf ya está instalado en el sistema: $(command -v lf)"
  exit 0
fi

sudo apt install lf
