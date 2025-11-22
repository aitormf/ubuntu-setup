#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON="$SCRIPT_DIR/../common.sh"
if [ -f "$COMMON" ]; then
	# shellcheck source=/dev/null
	. "$COMMON"
fi

cd /tmp/
wget -O discord.deb "https://discord.com/api/download?platform=linux"
${SUDO} apt install ./discord.deb