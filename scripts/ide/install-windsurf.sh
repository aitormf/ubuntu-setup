#!/usr/bin/env bash
# Instalador de WindSurf para sistemas basados en apt (Debian/Ubuntu).
# Sigue la misma estructura que `install-code.sh`.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON="$SCRIPT_DIR/../common.sh"
if [ -f "$COMMON" ]; then
  # shellcheck source=/dev/null
  . "$COMMON"
fi

if command -v windsurf >/dev/null 2>&1; then
  echo "WindSurf ('windsurf') ya está instalado en el sistema: $(command -v windsurf)"
  exit 0
fi

echo "Preparando instalación de WindSurf..."

echo "Instalando dependencias necesarias (wget, gnupg, apt-transport-https, ca-certificates)..."
${SUDO} apt-get update -y
${SUDO} apt-get install -y wget gnupg apt-transport-https ca-certificates

echo "Descargando y registrando la clave GPG de WindSurf..."
# Asegurar existencia del directorio de keyrings

# Obtener la clave y convertir a keyring
${SUDO} install -d -m 0755 /etc/apt/keyrings
wget -qO- "https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/windsurf.gpg" | gpg --dearmor > windsurf-stable.gpg
${SUDO} install -D -o root -g root -m 644 windsurf-stable.gpg /etc/apt/keyrings/windsurf-stable.gpg
rm -f windsurf-stable.gpg

echo "Creando fichero de fuentes '/etc/apt/sources.list.d/windsurf.list'..."
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/windsurf-stable.gpg] https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/apt stable main" | ${SUDO} tee /etc/apt/sources.list.d/windsurf.list >/dev/null

echo "Actualizando índices de paquetes..."
${SUDO} apt-get update -y

echo "Instalando WindSurf (paquete 'windsurf')..."
${SUDO} apt-get install -y windsurf

echo "Instalación completada. Ejecuta 'windsurf' para lanzar la aplicación (si procede)."
