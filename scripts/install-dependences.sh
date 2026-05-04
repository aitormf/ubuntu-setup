#!/usr/bin/env bash
# Script: comprueba e instala curl, wget, python3 y docker (uno a uno).
# Añade el usuario actual al grupo `docker` si instala Docker.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON="$SCRIPT_DIR/common.sh"
if [ -f "$COMMON" ]; then
	# shellcheck source=/dev/null
	. "$COMMON"
fi


set -u





install_docker() {
	case "$PM" in
		apt)
			pkg_name=docker.io
			;;
		dnf)
			pkg_name=docker
			;;
		pacman)
			pkg_name=docker
			;;
		zypper)
			pkg_name=docker
			;;
		apk)
			pkg_name=docker
			;;
		*)
			echo "No puedo instalar docker: gestor de paquetes desconocido." >&2
			return 2
			;;
	esac

	echo "Instalando Docker (${pkg_name})..."
	if ! install_package "$pkg_name"; then
		echo "Error al instalar Docker con el paquete $pkg_name." >&2
		return 1
	fi

	if command_exists systemctl; then
		${SUDO} systemctl enable --now docker || true
	fi

	# Añadir usuario al grupo docker
	if getent group docker >/dev/null 2>&1; then
		if id -nG "$CURRENT_USER" | grep -qw docker; then
			echo "El usuario $CURRENT_USER ya pertenece al grupo 'docker'."
		else
			echo "Añadiendo $CURRENT_USER al grupo 'docker'..."
			${SUDO} usermod -aG docker "$CURRENT_USER"
			echo "Usuario añadido al grupo 'docker'. Cierra sesión y vuelve a iniciar sesión para aplicar los cambios." 
		fi
	else
		# Si el paquete creó el servicio pero no el grupo, intentar crearlo
		${SUDO} groupadd -f docker || true
		${SUDO} usermod -aG docker "$CURRENT_USER" || true
		echo "Grupo 'docker' creado y usuario añadido. Cierra sesión y vuelve a iniciar sesión para aplicar los cambios." 
	fi
}

main() {
	if [ "$PM" = "unknown" ]; then
		echo "No se ha detectado un gestor de paquetes soportado (apt, dnf, pacman, zypper, apk)." >&2
		exit 2
	fi

	echo "Gestor de paquetes detectado: $PM"

	# 1) curl
	curl_pkg=curl
	check_and_install curl "$curl_pkg"

	# 2) wget
	wget_pkg=wget
	check_and_install wget "$wget_pkg"

	# 3) python3
	case "$PM" in
		pacman) py_pkg=python ;;
		*) py_pkg=python3 ;;
	esac
	check_and_install python3 "$py_pkg"

	# 4) docker (instalar y añadir usuario al grupo)
	if command_exists docker; then
		echo "docker ya está instalado: $(command -v docker)"
		if id -nG "$CURRENT_USER" | grep -qw docker; then
			echo "El usuario $CURRENT_USER ya pertenece al grupo 'docker'."
		else
			echo "Añadiendo $CURRENT_USER al grupo 'docker'..."
			${SUDO} usermod -aG docker "$CURRENT_USER" && echo "Usuario añadido al grupo 'docker'. Cierra sesión y vuelve a iniciar sesión."
		fi
	else
		install_docker || echo "No se pudo instalar Docker automáticamente." >&2
	fi

	echo "Proceso completado. Si se añadió al grupo 'docker', cierra sesión y vuelve a iniciarla para aplicar los cambios." 
}

main "$@"
