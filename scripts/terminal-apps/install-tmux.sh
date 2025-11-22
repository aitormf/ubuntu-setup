#!/usr/bin/env bash
# Instalador de tmux para sistemas basados en apt (Debian/Ubuntu).

set -euo pipefail

if command -v tmux >/dev/null 2>&1; then
  echo "tmux ya está instalado en el sistema: $(command -v tmux)"
  exit 0
fi

sudo apt install tmux
