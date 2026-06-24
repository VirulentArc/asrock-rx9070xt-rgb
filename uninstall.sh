#!/usr/bin/env bash
set -euo pipefail

PREFIX="${PREFIX:-$HOME/.local}"
BIN_DIR="$PREFIX/bin"
APP_DIR="$HOME/.local/share/applications"

rm -f "$BIN_DIR/gpu-rgb"
rm -f "$BIN_DIR/asrock-gpu-rgb-apply"
rm -f "$APP_DIR/gpu-rgb.desktop"

if command -v kbuildsycoca6 >/dev/null 2>&1; then
    kbuildsycoca6 >/dev/null 2>&1 || true
fi

echo "Uninstalled ASRock RX 9070 XT RGB tools."
