
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON="$SCRIPT_DIR/../common.sh"
if [ -f "$COMMON" ]; then
	# shellcheck source=/dev/null
	. "$COMMON"
fi

if command -v brave-browser >/dev/null 2>&1; then
	echo "Brave ('brave-browser') ya está instalado en el sistema: $(command -v brave-browser)"
	exit 0
fi

echo "Preparando instalación de Brave Browser..."

echo "Instalando dependencias necesarias (wget, gnupg, apt-transport-https, ca-certificates)..."
${SUDO} apt-get update -y
${SUDO} apt-get install -y wget gnupg apt-transport-https ca-certificates

echo "Registrando la clave GPG de Brave..."
${SUDO} install -d -m 0755 /etc/apt/keyrings

# Descargar la clave y convertirla a keyring
curl -fsSL https://brave-browser-apt-release.s3.brave.com/brave-core.asc | gpg --dearmor > brave-core.gpg
${SUDO} install -D -o root -g root -m 644 brave-core.gpg /etc/apt/keyrings/brave-browser-archive-keyring.gpg
rm -f brave-core.gpg

ARCH=$(dpkg --print-architecture)
echo "Creando fichero de fuentes '/etc/apt/sources.list.d/brave-browser-release.list'..."
echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | ${SUDO} tee /etc/apt/sources.list.d/brave-browser-release.list >/dev/null

echo "Actualizando índices de paquetes..."
${SUDO} apt-get update -y

echo "Instalando Brave Browser (paquete 'brave-browser')..."
${SUDO} apt-get install -y brave-browser

echo "Instalación completada. Ejecuta 'brave-browser' para lanzar la aplicación."
