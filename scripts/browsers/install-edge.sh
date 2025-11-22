#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON="$SCRIPT_DIR/../common.sh"
if [ -f "$COMMON" ]; then
	# shellcheck source=/dev/null
	. "$COMMON"
fi

if command -v microsoft-edge >/dev/null 2>&1 || command -v microsoft-edge-stable >/dev/null 2>&1; then
	echo "Microsoft Edge ya está instalado: $(command -v microsoft-edge || command -v microsoft-edge-stable)"
	exit 0
fi

echo "Preparando instalación de Microsoft Edge..."

echo "Instalando dependencias necesarias (wget, gnupg, apt-transport-https, ca-certificates)..."
${SUDO} apt-get update -y
${SUDO} apt-get install -y wget gnupg apt-transport-https ca-certificates

echo "Registrando la clave GPG de Microsoft..."
${SUDO} install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
${SUDO} install -D -o root -g root -m 644 microsoft.gpg /etc/apt/keyrings/microsoft.gpg
rm -f microsoft.gpg

ARCH=$(dpkg --print-architecture)
echo "Creando fichero de fuentes '/etc/apt/sources.list.d/microsoft-edge.list'..."
echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/edge stable main" | ${SUDO} tee /etc/apt/sources.list.d/microsoft-edge.list >/dev/null

echo "Actualizando índices de paquetes..."
${SUDO} apt-get update -y

echo "Instalando Microsoft Edge (paquete 'microsoft-edge-stable')..."
${SUDO} apt-get install -y microsoft-edge-stable

echo "Instalación completada. Ejecuta 'microsoft-edge' para lanzar la aplicación."

