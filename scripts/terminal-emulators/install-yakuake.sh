#!/usr/bin/env bash
# Instalador de yakuake para sistemas basados en apt (Debian/Ubuntu).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON="$SCRIPT_DIR/../common.sh"
if [ -f "$COMMON" ]; then
  # shellcheck source=/dev/null
  . "$COMMON"
fi

if command -v yakuake >/dev/null 2>&1; then
  echo "yakuake ya está instalado en el sistema: $(command -v yakuake)"
  exit 0
fi

${SUDO} apt install -y yakuake
