
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON="$SCRIPT_DIR/../common.sh"
if [ -f "$COMMON" ]; then
	# shellcheck source=/dev/null
	. "$COMMON"
fi

if command -v firefox >/dev/null 2>&1; then
	echo "Firefox ya está instalado: $(command -v firefox)"
	exit 0
fi

echo "Preparando instalación de Firefox (repositorio oficial Mozilla)..."

echo "Instalando dependencias necesarias (wget, gnupg, apt-transport-https, ca-certificates)..."
${SUDO} apt-get update -y
${SUDO} apt-get install -y wget gnupg apt-transport-https ca-certificates

echo "Registrando la clave GPG de Mozilla..."
${SUDO} install -d -m 0755 /etc/apt/keyrings
wget -qO- https://packages.mozilla.org/apt/repo-signing-key.gpg | gpg --dearmor > packages.mozilla.org.gpg
${SUDO} install -D -o root -g root -m 644 packages.mozilla.org.gpg /etc/apt/keyrings/packages.mozilla.org.gpg
rm -f packages.mozilla.org.gpg

echo "Creando fichero de fuentes '/etc/apt/sources.list.d/mozilla.list'..."
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.gpg] https://packages.mozilla.org/apt mozilla main" | ${SUDO} tee /etc/apt/sources.list.d/mozilla.list > /dev/null

echo "Ajustando prioridades para preferir paquetes Mozilla cuando aplique..."
echo 'Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000\n' | ${SUDO} tee /etc/apt/preferences.d/mozilla > /dev/null

echo "Actualizando índices de paquetes..."
${SUDO} apt-get update -y

echo "Instalando Firefox..."
${SUDO} apt-get install -y firefox

echo "Instalación completada. Ejecuta 'firefox' para lanzar la aplicación."

