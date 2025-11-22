#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON="$SCRIPT_DIR/../common.sh"
if [ -f "$COMMON" ]; then
	# shellcheck source=/dev/null
	. "$COMMON"
fi

if command -v chromium >/dev/null 2>&1 || command -v chromium-browser >/dev/null 2>&1; then
	echo "Chromium ya está instalado: $(command -v chromium || command -v chromium-browser)"
	exit 0
fi

echo "Instalando Chromium desde los repositorios del sistema..."
${SUDO} apt-get update -y
${SUDO} apt-get install -y chromium-browser || ${SUDO} apt-get install -y chromium

echo "Instalación completada. Ejecuta 'chromium' o 'chromium-browser' para lanzar la aplicación."
