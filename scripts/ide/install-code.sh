#!/usr/bin/env bash
# Instala Visual Studio Code en sistemas basados en apt (Debian/Ubuntu).
# Requisitos: se ejecuta con un usuario que tenga sudo.

set -euo pipefail

if command -v code >/dev/null 2>&1; then
	echo "Visual Studio Code ('code') ya está instalado en el sistema: $(command -v code)"
	exit 0
fi

echo "Preparando instalación de Visual Studio Code..."

echo "Instalando dependencias necesarias (wget, gnupg, apt-transport-https, ca-certificates)..."
sudo apt-get update -y
sudo apt-get install -y wget gnupg apt-transport-https ca-certificates

echo "Descargando y registrando la clave GPG de Microsoft..."
# Obtener la clave y convertir a formato 'gpg' (keyring)
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -D -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft.gpg
rm -f microsoft.gpg

echo "Creando fichero de fuentes '/etc/apt/sources.list.d/vscode.sources'..."
sudo tee /etc/apt/sources.list.d/vscode.sources >/dev/null <<'EOF'
Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64,arm64,armhf
Signed-By: /usr/share/keyrings/microsoft.gpg
EOF

echo "Actualizando índices de paquetes..."
sudo apt-get update -y

echo "Instalando Visual Studio Code (paquete 'code')..."
sudo apt-get install -y code

echo "Instalación completada. Ejecuta 'code' para lanzar Visual Studio Code." 