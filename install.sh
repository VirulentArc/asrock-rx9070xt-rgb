#!/usr/bin/env bash
set -euo pipefail

PREFIX="${PREFIX:-$HOME/.local}"
BIN_DIR="$PREFIX/bin"
APP_DIR="$HOME/.local/share/applications"
REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

install -Dm755 "$REPO_DIR/bin/asrock-gpu-rgb-apply" "$BIN_DIR/asrock-gpu-rgb-apply"
install -Dm755 "$REPO_DIR/bin/gpu-rgb" "$BIN_DIR/gpu-rgb"

if ! command -v i2ctransfer >/dev/null 2>&1; then
    cat <<WARN
Warning: i2ctransfer was not found.
Install i2c-tools before using this tool.

Arch/CachyOS:
  sudo pacman -S i2c-tools
WARN
fi

if [[ "${INSTALL_DESKTOP:-1}" != "0" ]]; then
    mkdir -p "$APP_DIR"

    terminal_exec=""
    if [[ -n "${TERMINAL_CMD:-}" ]]; then
        terminal_exec="$TERMINAL_CMD"
    elif command -v alacritty >/dev/null 2>&1; then
        terminal_exec="alacritty -e"
    elif command -v konsole >/dev/null 2>&1; then
        terminal_exec="konsole -e"
    elif command -v kitty >/dev/null 2>&1; then
        terminal_exec="kitty"
    elif command -v gnome-terminal >/dev/null 2>&1; then
        terminal_exec="gnome-terminal --"
    fi

    desktop_file="$APP_DIR/gpu-rgb.desktop"

    if [[ -n "$terminal_exec" ]]; then
        cat > "$desktop_file" <<DESKTOP
[Desktop Entry]
Type=Application
Name=GPU RGB
Comment=Set ASRock RX 9070 XT RGB color
Exec=${terminal_exec} ${BIN_DIR}/gpu-rgb
Icon=preferences-desktop-color
Terminal=false
Categories=Utility;
DESKTOP
    else
        cat > "$desktop_file" <<DESKTOP
[Desktop Entry]
Type=Application
Name=GPU RGB
Comment=Set ASRock RX 9070 XT RGB color
Exec=${BIN_DIR}/gpu-rgb
Icon=preferences-desktop-color
Terminal=true
Categories=Utility;
DESKTOP
    fi

    chmod 644 "$desktop_file"

    if command -v kbuildsycoca6 >/dev/null 2>&1; then
        kbuildsycoca6 >/dev/null 2>&1 || true
    fi
fi

cat <<DONE
Installed ASRock RX 9070 XT RGB tools.

Commands:
  gpu-rgb
  asrock-gpu-rgb-apply

Installed to:
  ${BIN_DIR}/gpu-rgb
  ${BIN_DIR}/asrock-gpu-rgb-apply

Next checks:
  1. Make sure ${BIN_DIR} is in your PATH.
  2. Make sure i2c-tools is installed.
  3. Make sure your user can access /dev/i2c-*.

Run:
  gpu-rgb
DONE
