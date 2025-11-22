#!/usr/bin/env bash
# Instalador de ghostty para sistemas basados en apt (Debian/Ubuntu).

set -euo pipefail

if command -v ghostty >/dev/null 2>&1; then
  echo "ghostty ya está instalado en el sistema: $(command -v ghostty)"
  exit 0
fi

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"