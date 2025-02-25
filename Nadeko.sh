#!/bin/bash
set -xeo pipefail
echo ""
echo "Welcome to NadekoBot."
echo "Downloading the latest installer..."

curl -fsSL https://raw.githubusercontent.com/Snake26183/nadeko-installer/refs/heads/main/n-menu.sh | bash -s -- "$@"
exit 0
