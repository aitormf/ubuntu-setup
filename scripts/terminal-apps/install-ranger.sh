#!/usr/bin/env bash
# Instalador de ranger para sistemas basados en apt (Debian/Ubuntu).

set -euo pipefail

if command -v ranger >/dev/null 2>&1; then
  echo "ranger ya está instalado en el sistema: $(command -v ranger)"
  exit 0
fi

sudo apt install ranger
