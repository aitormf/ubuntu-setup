#!/usr/bin/env bash
# Common helper to set SUDO variable for scripts.
# If running as root, SUDO is empty. Otherwise, set to 'sudo' if available.
set -u

if [ "$(id -u)" -eq 0 ]; then
  SUDO=""
else
  if command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
  else
    echo "No eres root y no se encontró 'sudo'. Ejecuta el script como root o instala sudo." >&2
    exit 1
  fi
fi

export SUDO
