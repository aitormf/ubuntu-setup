#!/usr/bin/env bash
# Instalador de Antigravity para sistemas basados en apt (Debian/Ubuntu).
# Sigue la misma estructura que los instaladores de Code/WindSurf.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON="$SCRIPT_DIR/../common.sh"
if [ -f "$COMMON" ]; then
  # shellcheck source=/dev/null
  . "$COMMON"
fi

if command -v antigravity >/dev/null 2>&1; then
  echo "Antigravity ('antigravity') ya está instalado en el sistema: $(command -v antigravity)"
  exit 0
fi

echo "Preparando instalación de Antigravity..."

echo "Instalando dependencias necesarias (curl, gnupg, apt-transport-https, ca-certificates)..."
${SUDO} apt-get update -y
${SUDO} apt-get install -y curl gnupg apt-transport-https ca-certificates

echo "Descargando y registrando la clave GPG de Antigravity..."
# Asegurar existencia del directorio de keyrings
${SUDO} install -d -m 0755 /etc/apt/keyrings

# Obtener la clave y convertir a keyring
curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | ${SUDO} gpg --dearmor -o /etc/apt/keyrings/antigravity-repo-key.gpg

echo "Creando fichero de fuentes '/etc/apt/sources.list.d/antigravity.list'..."
echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" | ${SUDO} tee /etc/apt/sources.list.d/antigravity.list >/dev/null

echo "Actualizando índices de paquetes..."
${SUDO} apt-get update -y

echo "Instalando Antigravity (paquete 'antigravity')..."
${SUDO} apt-get install -y antigravity

echo "Instalación completada. Ejecuta 'antigravity' si aplica para iniciar la aplicación." 