#!/usr/bin/env bash
set -e

INSTALL_DIR="$HOME/.local/bin"
CR_URL="https://raw.githubusercontent.com/mudern/cr/main/cr"

mkdir -p "$INSTALL_DIR"

echo "Downloading cr to $INSTALL_DIR/cr ..."
curl -fsSL "$CR_URL" -o "$INSTALL_DIR/cr"

chmod +x "$INSTALL_DIR/cr"

if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
    echo "NOTE: Add $HOME/.local/bin to your PATH:"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

echo "Installation complete! Use 'cr --list' to test."