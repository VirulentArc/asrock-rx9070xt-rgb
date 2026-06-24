# ASRock RX 9070 XT RGB Controller

![GPU RGB menu screenshot placeholder](docs/screenshot.png)

Linux RGB control scripts for the **ASRock RX 9070 XT Steel Legend** GPU.

This project provides a terminal menu and a low-level I2C writer for controlling the GPU RGB controller directly from Linux.

> [!WARNING]
> This tool writes directly to the GPU RGB controller over I2C. It has only been tested on the ASRock RX 9070 XT Steel Legend. Do not use it on other GPUs unless you know the correct I2C bus, address, channels, and mode values.

## Status

Version: **0.1.0**

This is an early release based on one tested card and one tested Linux system.

Tested environment:

- GPU: ASRock RX 9070 XT Steel Legend
- OS: CachyOS / Arch Linux
- RGB controller I2C bus: `7`
- RGB controller I2C address: `0x36`

## What This Includes

```text
asrock-rx9070xt-rgb/
├── README.md
├── LICENSE
├── VERSION
├── install.sh
├── uninstall.sh
├── bin/
│   ├── gpu-rgb
│   └── asrock-gpu-rgb-apply
└── desktop/
    └── gpu-rgb.desktop
```

`gpu-rgb` is the interactive terminal menu.

`asrock-gpu-rgb-apply` is the low-level script that sends RGB packets to the controller using `i2ctransfer`.

## Screenshot

Replace this placeholder with a screenshot before publishing the repo:

```markdown
![GPU RGB menu](docs/screenshot.png)
```

## Requirements

You need:

- Linux
- `bash`
- `i2c-tools`
- access to the relevant `/dev/i2c-*` device

On Arch/CachyOS:

```bash
sudo pacman -S i2c-tools
```

Make sure the `i2c-dev` module is loaded:

```bash
sudo modprobe i2c-dev
```

## I2C Permissions

The scripts should not need `sudo` once your user has access to the I2C devices.

One common setup is:

```bash
sudo groupadd -f i2c
sudo usermod -aG i2c "$USER"
echo 'KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"' | sudo tee /etc/udev/rules.d/99-i2c.rules
sudo udevadm control --reload-rules
sudo udevadm trigger
```

Then log out and log back in.

## Installation

Clone the repository and run:

```bash
chmod +x install.sh uninstall.sh
./install.sh
```

This installs:

```text
~/.local/bin/gpu-rgb
~/.local/bin/asrock-gpu-rgb-apply
~/.local/share/applications/gpu-rgb.desktop
```

The installer tries to use one of these terminal emulators for the desktop launcher:

1. `alacritty`
2. `konsole`
3. `kitty`
4. `gnome-terminal`

You can override the terminal command:

```bash
TERMINAL_CMD="alacritty -e" ./install.sh
```

Skip the desktop launcher:

```bash
INSTALL_DESKTOP=0 ./install.sh
```

## Usage

Open the interactive menu:

```bash
gpu-rgb
```

Show help:

```bash
gpu-rgb --help
asrock-gpu-rgb-apply --help
```

Set a static color directly:

```bash
asrock-gpu-rgb-apply '#00A0FF'
```

Turn lighting off:

```bash
asrock-gpu-rgb-apply off
```

Set only the GPU body zones:

```bash
env GPU_RGB_CHANNELS='6 7' asrock-gpu-rgb-apply '#00A0FF'
```

## Known Channels

| Channel | Meaning |
|---:|---|
| `3` | GPU ARGB header |
| `6` | Top side / logo lighting |
| `7` | Fan lighting |

The menu zone choices are:

| Menu Choice | Channels |
|---|---|
| All Zones, Including GPU ARGB Header | `3 6 7` |
| GPU Body Only, Top + Fan | `6 7` |
| Top Side Only | `6` |
| Fan Only | `7` |
| ARGB Header Only | `3` |

## Known Modes

These are the modes currently exposed by the menu.

| Mode | Menu Name | Color Choice | Notes |
|---:|---|---|---|
| `0x01` | Static Color | Yes | Static color. |
| `0x02` | Breathing | Yes | Confirmed working. |
| `0x03` | Strobe | Yes | Previously labelled Blinking. |
| `0x04` | RGB Cycle | No | Uses a custom speed table because normal slowest speed can skip red. |
| `0x05` | Random | No | Random color changing effect. |
| `0x06` | Not used | No | Likely software-driven music mode; not exposed in the menu. |
| `0x07` | Color Shift / Fade | No | Hardware animation. |
| `0x08` | Visor / Back-And-Forth | Yes | Possibly broken on this card; may go black after each cycle. |
| `0x09` | Stacking Light, Right To Left | Yes | Hardware animation. |
| `0x0A` | Fill Wave, Left To Right | Yes | Hardware animation. |
| `0x0B` | Traveling Wave, Left To Right | Yes | Hardware animation. |
| `0x0C` | Marquee - Color Choice | Yes | Hardware animation. |
| `0x0D` | Marquee - Random Color Shift | No | Hardware animation. |
| `0x0E` | Color Wave | No | Hardware animation. |
| `0x0F` | Rainbow | No | Hardware animation. |

> [!CAUTION]
> Do **not** test mode values `0x10` or higher. During testing, those values could wedge the RGB controller until a cold power cycle.

## Environment Overrides

The menu and low-level writer can be adjusted without editing the scripts.

Common overrides:

```bash
GPU_RGB_BUS=7
GPU_RGB_ADDR=0x36
GPU_RGB_CHANNELS='3 6 7'
GPU_RGB_MODE=0x01
GPU_RGB_PARAM_A=0x80
GPU_RGB_PARAM_B=0xFF
GPU_RGB_PARAM_C=0x00
```

The menu also accepts:

```bash
GPU_RGB_APPLY=/path/to/asrock-gpu-rgb-apply
GPU_RGB_ALL_CHANNELS='3 6 7'
GPU_RGB_BODY_CHANNELS='6 7'
GPU_RGB_TOP_CHANNEL=6
GPU_RGB_FAN_CHANNEL=7
GPU_RGB_HEADER_CHANNEL=3
GPU_RGB_SKIP_WARNING=1
```

Legacy variable names are still accepted by the low-level writer:

```bash
BUS=7
ADDR=0x36
CHANNELS='3 6 7'
MODE=0x01
BRIGHTNESS=0x80
SPEED=0xFF
DIRECTION=0x00
```

## Direct Packet Format

The low-level script sends one 12-byte write per channel:

```text
0x10 0x00 CHANNEL MODE R G B PARAM_A PARAM_B PARAM_C 0x1A 0x00
```

On the tested controller:

- `PARAM_A` behaves like animation speed.
- `PARAM_B` behaves like brightness.
- `PARAM_C` is usually `0x00` for static and `0x01` for animation modes.

Observed speed values:

| Speed | Value |
|---|---:|
| Slowest | `0xFF` |
| Slow | `0xC0` |
| Medium | `0x80` |
| Fast | `0x40` |
| Fastest | `0x20` |

RGB Cycle uses a custom slowest value of `0xE0` because `0xFF` could skip red.

Observed brightness values:

| Brightness | Value |
|---|---:|
| Dimmest | `0x20` |
| Dim | `0x40` |
| Medium | `0x80` |
| Bright | `0xC0` |
| Brightest | `0xFF` |

## Uninstall

```bash
./uninstall.sh
```

## Notes

- Hardware animation modes keep running after the menu closes.
- The RGB state may persist across reboot.
- Music mode is not implemented because it is likely software-driven.
- This project is not affiliated with ASRock.

## License

MIT License. See [`LICENSE`](LICENSE).
