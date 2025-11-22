#!/usr/bin/env bash
# Instalador de kitty para sistemas basados en apt (Debian/Ubuntu).

set -euo pipefail

if command -v kitty >/dev/null 2>&1; then
  echo "kitty ya está instalado en el sistema: $(command -v kitty)"
  exit 0
fi

curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin