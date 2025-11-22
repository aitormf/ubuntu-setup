
#!/usr/bin/env bash
set -euo pipefail

if command -v firefox >/dev/null 2>&1; then
	echo "Firefox ya está instalado: $(command -v firefox)"
	exit 0
fi

echo "Preparando instalación de Firefox (repositorio oficial Mozilla)..."

echo "Instalando dependencias necesarias (wget, gnupg, apt-transport-https, ca-certificates)..."
sudo apt-get update -y
sudo apt-get install -y wget gnupg apt-transport-https ca-certificates

echo "Registrando la clave GPG de Mozilla..."
sudo install -d -m 0755 /etc/apt/keyrings
wget -qO- https://packages.mozilla.org/apt/repo-signing-key.gpg | gpg --dearmor > packages.mozilla.org.gpg
sudo install -D -o root -g root -m 644 packages.mozilla.org.gpg /etc/apt/keyrings/packages.mozilla.org.gpg
rm -f packages.mozilla.org.gpg

echo "Creando fichero de fuentes '/etc/apt/sources.list.d/mozilla.list'..."
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.gpg] https://packages.mozilla.org/apt mozilla main" | sudo tee /etc/apt/sources.list.d/mozilla.list > /dev/null

echo "Ajustando prioridades para preferir paquetes Mozilla cuando aplique..."
echo 'Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000\n' | sudo tee /etc/apt/preferences.d/mozilla > /dev/null

echo "Actualizando índices de paquetes..."
sudo apt-get update -y

echo "Instalando Firefox..."
sudo apt-get install -y firefox

echo "Instalación completada. Ejecuta 'firefox' para lanzar la aplicación."

