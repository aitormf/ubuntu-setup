#!/usr/bin/env bash
set -euo pipefail

if command -v chromium >/dev/null 2>&1 || command -v chromium-browser >/dev/null 2>&1; then
	echo "Chromium ya está instalado: $(command -v chromium || command -v chromium-browser)"
	exit 0
fi

echo "Instalando Chromium desde los repositorios del sistema..."
sudo apt-get update -y
sudo apt-get install -y chromium-browser || sudo apt-get install -y chromium

echo "Instalación completada. Ejecuta 'chromium' o 'chromium-browser' para lanzar la aplicación."
