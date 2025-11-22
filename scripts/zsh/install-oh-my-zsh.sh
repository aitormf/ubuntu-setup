#!/usr/bin/env bash
set -euo pipefail

# Install Oh My Zsh non-interactively (the installer may switch shells)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install recommended plugins/themes
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Install Powerlevel10k fonts
mkdir -p "$HOME/.local/share/fonts"
cd "$HOME/.local/share/fonts"
curl -fLO https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
curl -fLO https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
curl -fLO https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
curl -fLO https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
fc-cache -f -v

# --- Copy repository 'oh-my-zsh' files into the user's home ---
# This will copy the contents of the repo's `oh-my-zsh/` directory into the
# target user's home directory, making a timestamped backup of any files
# that would be overwritten.

# Determine target user/home (respect SUDO_USER when run with sudo)
if [ -n "${SUDO_USER-}" ] && [ "$SUDO_USER" != "root" ]; then
	TARGET_USER="$SUDO_USER"
	TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
else
	TARGET_USER=$(id -un)
	TARGET_HOME="$HOME"
fi

# Locate repository root relative to this script and the oh-my-zsh dir
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OH_DIR="$REPO_ROOT/oh-my-zsh"

if [ -d "$OH_DIR" ]; then
	echo "Found oh-my-zsh directory at: $OH_DIR"
	TIMESTAMP=$(date +%Y%m%d%H%M%S)
	BACKUP_DIR="$TARGET_HOME/oh-my-zsh-backup-$TIMESTAMP"
	mkdir -p "$BACKUP_DIR"

	# Iterate files and backup existing before copying
	for SRC in "$OH_DIR"/.* "$OH_DIR"/*; do
		[ -e "$SRC" ] || continue
		NAME=$(basename "$SRC")
		# skip '.' and '..'
		if [ "$NAME" = "." ] || [ "$NAME" = ".." ]; then
			continue
		fi
		DEST="$TARGET_HOME/$NAME"
		if [ -e "$DEST" ]; then
			echo "Backing up existing $DEST -> $BACKUP_DIR/"
			mv "$DEST" "$BACKUP_DIR/"
		fi
		echo "Copying $SRC -> $DEST"
		cp -a "$SRC" "$DEST"
		# If running as root for another user, ensure ownership matches
		if [ "$TARGET_USER" != "$(id -un)" ]; then
			chown -R "$TARGET_USER":"$TARGET_USER" "$DEST" || true
		fi
	done
	echo "Files from $OH_DIR copied to $TARGET_HOME. Backups (if any) in $BACKUP_DIR"
else
	echo "No $OH_DIR directory found in repository; skipping copy step."
fi
