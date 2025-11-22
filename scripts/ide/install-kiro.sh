#!/usr/bin/env bash
# Instalador de Kiro CLI (https://kiro.dev/) para macOS/Linux style installer on Linux.
# Usa el instalador oficial: curl -fsSL https://cli.kiro.dev/install | bash

set -euo pipefail

if command -v kiro >/dev/null 2>&1; then
  echo "Kiro CLI ya está instalado: $(command -v kiro)"
  exit 0
fi

echo "Preparando instalación de Kiro CLI..."

# Asegurar que curl está disponible
if ! command -v curl >/dev/null 2>&1; then
  echo "curl no encontrado. Instalando curl..."
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update -y
    sudo apt-get install -y curl
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y curl
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Sy --noconfirm curl
  else
    echo "No se encontró un gestor de paquetes soportado para instalar curl. Instala curl manualmente e inténtalo de nuevo." >&2
    exit 2
  fi
fi

echo "Ejecutando el instalador oficial de Kiro..."
# Ejecutar script remoto de forma segura (usa bash). El instalador oficial puede requerir sudo.
curl -fsSL https://cli.kiro.dev/install | bash

if command -v kiro >/dev/null 2>&1; then
  echo "Kiro CLI instalado correctamente: $(command -v kiro)"
else
  echo "La instalación terminó pero no se encontró 'kiro' en el PATH." >&2
  echo "Revisa la salida del instalador para errores o añade manualmente la ruta donde se instaló." >&2
  exit 3
fi
