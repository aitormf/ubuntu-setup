#!/usr/bin/env bash
# Instalador de Cursor (https://cursor.com/) para Linux.
# Detecta si ya está instalado, detecta arquitectura y gestor de paquetes
# y descarga el paquete apropiado (.deb/.rpm/AppImage) y lo instala.

set -euo pipefail

if command -v cursor >/dev/null 2>&1; then
  echo "Cursor ya está instalado: $(command -v cursor)"
  exit 0
fi

ARCH="$(uname -m)"
OS_TYPE=""
PKG_URL=""

choose_package() {
  # Cursor release links (stable 2.1). Update if you want newer versions.
  case "$ARCH" in
    x86_64|amd64)
      PKG_DEB="https://api2.cursor.sh/updates/download/golden/linux-x64-deb/cursor/2.1"
      PKG_RPM="https://api2.cursor.sh/updates/download/golden/linux-x64-rpm/cursor/2.1"
      PKG_APPIMAGE="https://api2.cursor.sh/updates/download/golden/linux-x64/cursor/2.1"
      ;;
    aarch64|arm64)
      PKG_DEB="https://api2.cursor.sh/updates/download/golden/linux-arm64-deb/cursor/2.1"
      PKG_RPM="https://api2.cursor.sh/updates/download/golden/linux-arm64-rpm/cursor/2.1"
      PKG_APPIMAGE="https://api2.cursor.sh/updates/download/golden/linux-arm64/cursor/2.1"
      ;;
    *)
      echo "Arquitectura no soportada: $ARCH" >&2
      exit 2
      ;;
  esac

  if command -v apt-get >/dev/null 2>&1; then
    OS_TYPE=deb
    PKG_URL="$PKG_DEB"
  elif command -v dnf >/dev/null 2>&1 || command -v yum >/dev/null 2>&1; then
    OS_TYPE=rpm
    PKG_URL="$PKG_RPM"
  else
    OS_TYPE=appimage
    PKG_URL="$PKG_APPIMAGE"
  fi
}

download() {
  out="$1"
  echo "Descargando $PKG_URL -> $out"
  if command -v wget >/dev/null 2>&1; then
    wget -O "$out" "$PKG_URL"
  elif command -v curl >/dev/null 2>&1; then
    curl -L -o "$out" "$PKG_URL"
  else
    echo "Necesitas 'wget' o 'curl' para descargar paquetes." >&2
    exit 1
  fi
}

install_deb() {
  tmpf="/tmp/cursor-$(date +%s).deb"
  download "$tmpf"
  echo "Instalando paquete deb..."
  sudo apt-get install -y "$tmpf" || {
    # fallback to dpkg then fix deps
    sudo dpkg -i "$tmpf" || true
    sudo apt-get install -f -y
  }
  rm -f "$tmpf"
}

install_rpm() {
  tmpf="/tmp/cursor-$(date +%s).rpm"
  download "$tmpf"
  echo "Instalando paquete rpm..."
  if command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y "$tmpf"
  else
    sudo yum localinstall -y "$tmpf"
  fi
  rm -f "$tmpf"
}

install_appimage() {
  tmpf="/tmp/cursor-$(date +%s).AppImage"
  download "$tmpf"
  chmod +x "$tmpf"
  # Mover a /usr/local/bin si es posible
  if [ -w /usr/local/bin ]; then
    sudo mv "$tmpf" /usr/local/bin/cursor && sudo chmod +x /usr/local/bin/cursor
    echo "Cursor AppImage instalado en /usr/local/bin/cursor"
  else
    echo "AppImage descargado en: $tmpf" 
    echo "Puedes moverlo a /usr/local/bin y hacerlo ejecutable para usar 'cursor'."
  fi
}

main() {
  choose_package

  echo "Arquitectura: $ARCH, método: $OS_TYPE"

  case "$OS_TYPE" in
    deb)
      install_deb
      ;;
    rpm)
      install_rpm
      ;;
    appimage)
      install_appimage
      ;;
  esac

  if command -v cursor >/dev/null 2>&1; then
    echo "Cursor instalado: $(command -v cursor)"
  else
    echo "La instalación finalizó, pero no se encontró el binario 'cursor' en el PATH." >&2
    echo "Comprueba manualmente o reinicia sesión si instalaste en /usr/local/bin." >&2
    exit 3
  fi
}

main "$@"
