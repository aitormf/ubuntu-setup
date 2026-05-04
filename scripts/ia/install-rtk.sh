#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON="$SCRIPT_DIR/../common.sh"
if [ -f "$COMMON" ]; then
	# shellcheck source=/dev/null
	. "$COMMON"
fi

curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | $SHELL

rtk init --global
