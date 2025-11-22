#!/usr/bin/env bash
set -euo pipefail

if command -v google-chrome >/dev/null 2>&1 || command -v google-chrome-stable >/dev/null 2>&1; then
	echo "Google Chrome ya está instalado: $(command -v google-chrome || command -v google-chrome-stable)"
	exit 0
fi

echo "Preparando instalación de Google Chrome..."

echo "Instalando dependencias necesarias (wget, gnupg, apt-transport-https, ca-certificates)..."
sudo apt-get update -y
sudo apt-get install -y wget gnupg apt-transport-https ca-certificates

echo "Registrando la clave GPG de Google..."
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor > google-chrome.gpg
sudo install -D -o root -g root -m 644 google-chrome.gpg /etc/apt/keyrings/google-chrome-archive-keyring.gpg
rm -f google-chrome.gpg

ARCH=$(dpkg --print-architecture)
echo "Creando fichero de fuentes '/etc/apt/sources.list.d/google-chrome.list'..."
echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/google-chrome-archive-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list >/dev/null

echo "Actualizando índices de paquetes..."
sudo apt-get update -y

echo "Instalando Google Chrome (paquete 'google-chrome-stable')..."
sudo apt-get install -y google-chrome-stable

echo "Instalación completada. Ejecuta 'google-chrome' para lanzar la aplicación."

