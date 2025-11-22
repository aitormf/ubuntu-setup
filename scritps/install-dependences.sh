#!/usr/bin/env bash
# Script: comprueba e instala curl, wget, python3 y docker (uno a uno).
# Añade el usuario actual al grupo `docker` si instala Docker.

set -u

CURRENT_USER="$(logname 2>/dev/null || echo "$USER")"
SUDO=""
if [ "$(id -u)" -ne 0 ]; then
	if command -v sudo >/dev/null 2>&1; then
		SUDO="sudo"
	else
		echo "No eres root y no se encontró 'sudo'. Ejecuta el script como root o instala sudo." >&2
		exit 1
	fi
fi

command_exists() { command -v "$1" >/dev/null 2>&1; }

PM=""
detect_pm() {
	if command_exists apt-get; then
		PM=apt
	elif command_exists dnf; then
		PM=dnf
	elif command_exists pacman; then
		PM=pacman
	elif command_exists zypper; then
		PM=zypper
	elif command_exists apk; then
		PM=apk
	else
		PM=unknown
	fi
}

UPDATED=0
install_package() {
	pkg="$1"
	case "$PM" in
		apt)
			if [ "$UPDATED" -eq 0 ]; then
				${SUDO} apt-get update -y
				UPDATED=1
			fi
			${SUDO} DEBIAN_FRONTEND=noninteractive apt-get install -y "$pkg"
			;;
		dnf)
			${SUDO} dnf install -y "$pkg"
			;;
		pacman)
			${SUDO} pacman -Sy --noconfirm "$pkg"
			;;
		zypper)
			${SUDO} zypper --non-interactive install "$pkg"
			;;
		apk)
			${SUDO} apk add --no-cache "$pkg"
			;;
		*)
			echo "Gestor de paquetes no soportado: $PM" >&2
			return 2
			;;
	esac
}

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

check_and_install() {
	name="$1"
	pkg_for_pm="$2"
	if command_exists "$name"; then
		echo "$name ya está instalado: $(command -v $name)"
		return 0
	fi
	echo "$name no encontrado. Intentando instalar..."
	if install_package "$pkg_for_pm"; then
		echo "$name instalado correctamente."
		return 0
	else
		echo "Falló la instalación de $name." >&2
		return 1
	fi
}

main() {
	detect_pm
	if [ "$PM" = "unknown" ]; then
		echo "No se ha detectado un gestor de paquetes soportado (apt, dnf, pacman, zypper, apk)." >&2
		exit 2
	fi

	echo "Gestor de paquetes detectado: $PM"

	# 1) curl
	case "$PM" in
		pacman) curl_pkg=curl ;;
		*) curl_pkg=curl ;;
	esac
	check_and_install curl "$curl_pkg"

	# 2) wget
	case "$PM" in
		pacman) wget_pkg=wget ;;
		*) wget_pkg=wget ;;
	esac
	check_and_install wget "$wget_pkg"

	# 3) python3
	case "$PM" in
		pacman) py_pkg=python ;;
		apk) py_pkg=python3 ;;
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
