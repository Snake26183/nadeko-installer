#!/usr/bin/env bash
echo ""
echo "Welcome to NadekoBot."
echo "Downloading the latest installer..."

wget -qO- https://raw.githubusercontent.com/Snake26183/nadeko-installer/refs/heads/main/n-menu.sh | bash
exit 0