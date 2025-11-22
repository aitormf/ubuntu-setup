#!/usr/bin/env bash
# Instalador de glances para sistemas basados en apt (Debian/Ubuntu).

set -euo pipefail

if command -v glances >/dev/null 2>&1; then
  echo "glances ya está instalado en el sistema: $(command -v glances)"
  exit 0
fi

sudo apt install glances
