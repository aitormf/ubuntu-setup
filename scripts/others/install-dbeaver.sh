#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON="$SCRIPT_DIR/../common.sh"
if [ -f "$COMMON" ]; then
	# shellcheck source=/dev/null
	. "$COMMON"
fi

${SUDO} add-apt-repository ppa:serge-rider/dbeaver-ce
${SUDO} apt-get update -y
${SUDO} apt-get install -y dbeaver-ce