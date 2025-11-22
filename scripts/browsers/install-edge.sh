#!/usr/bin/env bash
set -euo pipefail

if command -v microsoft-edge >/dev/null 2>&1 || command -v microsoft-edge-stable >/dev/null 2>&1; then
	echo "Microsoft Edge ya está instalado: $(command -v microsoft-edge || command -v microsoft-edge-stable)"
	exit 0
fi

echo "Preparando instalación de Microsoft Edge..."

echo "Instalando dependencias necesarias (wget, gnupg, apt-transport-https, ca-certificates)..."
sudo apt-get update -y
sudo apt-get install -y wget gnupg apt-transport-https ca-certificates

echo "Registrando la clave GPG de Microsoft..."
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -D -o root -g root -m 644 microsoft.gpg /etc/apt/keyrings/microsoft.gpg
rm -f microsoft.gpg

ARCH=$(dpkg --print-architecture)
echo "Creando fichero de fuentes '/etc/apt/sources.list.d/microsoft-edge.list'..."
echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/edge stable main" | sudo tee /etc/apt/sources.list.d/microsoft-edge.list >/dev/null

echo "Actualizando índices de paquetes..."
sudo apt-get update -y

echo "Instalando Microsoft Edge (paquete 'microsoft-edge-stable')..."
sudo apt-get install -y microsoft-edge-stable

echo "Instalación completada. Ejecuta 'microsoft-edge' para lanzar la aplicación."

