#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON="$SCRIPT_DIR/../common.sh"
if [ -f "$COMMON" ]; then
	# shellcheck source=/dev/null
	. "$COMMON"
fi

if command -v vivaldi >/dev/null 2>&1 || command -v vivaldi-stable >/dev/null 2>&1; then
	echo "Vivaldi ya está instalado: $(command -v vivaldi || command -v vivaldi-stable)"
	exit 0
fi

echo "Preparando instalación de Vivaldi..."

echo "Instalando dependencias necesarias (wget, gnupg, software-properties-common)..."
${SUDO} apt-get update -y
${SUDO} apt-get install -y wget gnupg2 software-properties-common ca-certificates

echo "Registrando la clave GPG de Vivaldi..."
${SUDO} install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://repo.vivaldi.com/archive/linux_signing_key.pub | gpg --dearmor > vivaldi.gpg
${SUDO} install -D -o root -g root -m 644 vivaldi.gpg /etc/apt/keyrings/vivaldi.gpg
rm -f vivaldi.gpg

ARCH=$(dpkg --print-architecture)
echo "Creando fichero de fuentes '/etc/apt/sources.list.d/vivaldi.list'..."
echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/vivaldi.gpg] https://repo.vivaldi.com/archive/deb/ stable main" | ${SUDO} tee /etc/apt/sources.list.d/vivaldi.list >/dev/null

echo "Actualizando índices de paquetes..."
${SUDO} apt-get update -y

echo "Instalando Vivaldi (paquete 'vivaldi-stable')..."
${SUDO} apt-get install -y vivaldi-stable

echo "Instalación completada. Ejecuta 'vivaldi' para lanzar la aplicación."
