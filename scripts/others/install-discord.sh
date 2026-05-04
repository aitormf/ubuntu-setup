#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON="$SCRIPT_DIR/../common.sh"
if [ -f "$COMMON" ]; then
	# shellcheck source=/dev/null
	. "$COMMON"
fi

case "$PM" in
	apt)
		cd /tmp/
		wget -O discord.deb "https://discord.com/api/download?platform=linux"
		${SUDO} apt install ./discord.deb
		;;
	pacman)
		${SUDO} pacman -Sy --noconfirm discord
		;;
	*)
		echo "Gestor de paquetes no soportado: $PM" >&2
		exit 1
		;;
esac