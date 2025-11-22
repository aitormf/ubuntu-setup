#!/usr/bin/env bash
# Instalador de ncdu para sistemas basados en apt (Debian/Ubuntu).

set -euo pipefail

if command -v ncdu >/dev/null 2>&1; then
  echo "ncdu ya está instalado en el sistema: $(command -v ncdu)"
  exit 0
fi

sudo apt install ncdu
