#!/usr/bin/env bash
set -euo pipefail

if command -v vivaldi >/dev/null 2>&1 || command -v vivaldi-stable >/dev/null 2>&1; then
	echo "Vivaldi ya está instalado: $(command -v vivaldi || command -v vivaldi-stable)"
	exit 0
fi

echo "Preparando instalación de Vivaldi..."

echo "Instalando dependencias necesarias (wget, gnupg, software-properties-common)..."
sudo apt-get update -y
sudo apt-get install -y wget gnupg2 software-properties-common ca-certificates

echo "Registrando la clave GPG de Vivaldi..."
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://repo.vivaldi.com/archive/linux_signing_key.pub | gpg --dearmor > vivaldi.gpg
sudo install -D -o root -g root -m 644 vivaldi.gpg /etc/apt/keyrings/vivaldi.gpg
rm -f vivaldi.gpg

ARCH=$(dpkg --print-architecture)
echo "Creando fichero de fuentes '/etc/apt/sources.list.d/vivaldi.list'..."
echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/vivaldi.gpg] https://repo.vivaldi.com/archive/deb/ stable main" | sudo tee /etc/apt/sources.list.d/vivaldi.list >/dev/null

echo "Actualizando índices de paquetes..."
sudo apt-get update -y

echo "Instalando Vivaldi (paquete 'vivaldi-stable')..."
sudo apt-get install -y vivaldi-stable

echo "Instalación completada. Ejecuta 'vivaldi' para lanzar la aplicación."
