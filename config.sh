#!/usr/bin/env bash
set -euo pipefail

# Script de control interactivo para ejecutar instaladores del repo
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPS_SCRIPT="$ROOT_DIR/scripts/install-dependences.sh"
INSTALL_PY="$ROOT_DIR/install.py"

function run_deps() {
  if [ ! -f "$DEPS_SCRIPT" ]; then
    echo "No se encuentra el script de dependencias: $DEPS_SCRIPT"
    return 1
  fi
  if [ "$EUID" -ne 0 ]; then
    echo "Ejecutando instalador de dependencias con sudo..."
    sudo bash "$DEPS_SCRIPT"
  else
    bash "$DEPS_SCRIPT"
  fi
}

function run_install_py() {
  if [ ! -f "$INSTALL_PY" ]; then
    echo "No se encuentra $INSTALL_PY"
    return 1
  fi
  if command -v python3 >/dev/null 2>&1; then
    python3 "$INSTALL_PY"
  elif command -v python >/dev/null 2>&1; then
    python "$INSTALL_PY"
  else
    echo "No se encontró intérprete Python (python3/python). Instale Python para continuar."
    return 1
  fi
}

function show_menu() {
  cat <<-EOF
Elige una opción:
  1) Instalar todo: instala dependencias y ejecuta install.py
  2) Instalar aplicaciones: ejecuta install.py
  3) Instalar dependencias
  4) Salir
EOF
}

while true; do
  show_menu
  read -rp "Opción: " opt || exit 0
  case "$opt" in
    1)
      run_deps || { echo "Fallo instalando dependencias."; exit 1; }
      run_install_py || { echo "Fallo ejecutando install.py."; exit 1; }
      ;;
    2)
      run_install_py || { echo "Fallo ejecutando install.py."; exit 1; }
      ;;
    3)
      run_deps || { echo "Fallo instalando dependencias."; exit 1; }
      ;;
    4|q|quit|exit)
      echo "Saliendo."; exit 0
      ;;
    *)
      echo "Opción inválida: $opt";
      ;;
  esac
done
