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

detect_pm
export PM

install_package() {
	local pkg="$1"
	local UPDATED=0
	case "$PM" in
		apt)
			if [ "$UPDATED" -eq 0 ]; then
				${SUDO} apt-get update -y
				UPDATED=1
			fi
			# When using sudo, prefix with 'env' so the environment assignment is applied
			if [ -n "$SUDO" ]; then
				${SUDO} env DEBIAN_FRONTEND=noninteractive apt-get install -y "$pkg"
			else
				DEBIAN_FRONTEND=noninteractive apt-get install -y "$pkg"
			fi
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

check_and_install() {
	local name="$1"
	local pkg_for_pm="$2"
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
