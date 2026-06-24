# ASRock RX 9070 XT RGB Controller

![GPU RGB menu screenshot](docs/screenshot.png)

A small Linux RGB control tool for the **ASRock RX 9070 XT Steel Legend** GPU.

It gives you a terminal menu called `gpu-rgb` and a lower-level command called `asrock-gpu-rgb-apply`. The scripts talk directly to the GPU RGB controller over I2C.

> [!WARNING]
> This tool has only been tested on the **ASRock RX 9070 XT Steel Legend**. Do not use it on another GPU unless you know the correct I2C bus, address, channel numbers, and mode values.
>
> During testing, mode values `0x10` and higher could wedge the RGB controller until a cold power cycle. This tool does not use those values.

## Current Status

Version: **0.1.0**

Tested on:

| Item | Value |
|---|---|
| GPU | ASRock RX 9070 XT Steel Legend |
| OS | CachyOS / Arch Linux |
| RGB controller I2C bus | `7` |
| RGB controller I2C address | `0x36` |

This is an early release based on one tested card.

## What Gets Installed

The installer copies two commands into `~/.local/bin`:

| Command | Purpose |
|---|---|
| `gpu-rgb` | Opens the interactive RGB menu. |
| `asrock-gpu-rgb-apply` | Low-level RGB writer used by the menu. |

It also installs a desktop launcher named **GPU RGB** into:

```text
~/.local/share/applications/gpu-rgb.desktop
```

## Quick Install: CachyOS / Arch Linux

These are the easiest instructions if you are on CachyOS, Arch, or an Arch-based distro.

### 1. Install the required package

```bash
sudo pacman -S i2c-tools
```

### 2. Load the I2C device module

```bash
sudo modprobe i2c-dev
```

### 3. Allow your user to access I2C devices

```bash
sudo groupadd -f i2c
sudo usermod -aG i2c "$USER"
echo 'KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"' | sudo tee /etc/udev/rules.d/99-i2c.rules
sudo udevadm control --reload-rules
sudo udevadm trigger
```

Now **log out and log back in**.

After logging back in, check that your user is in the `i2c` group:

```bash
groups
```

You should see `i2c` somewhere in the output.

### 4. Download and extract the release

Download either the `.tar.gz` or `.zip` file from the GitHub Releases page.

For the `.tar.gz` release:

```bash
cd ~/Downloads
tar -xzf asrock-rx9070xt-rgb-v0.1.0.tar.gz
cd asrock-rx9070xt-rgb
```

For the `.zip` release:

```bash
cd ~/Downloads
unzip asrock-rx9070xt-rgb-v0.1.0.zip
cd asrock-rx9070xt-rgb
```

### 5. Run the installer

```bash
./install.sh
```

### 6. Make sure `~/.local/bin` is in your PATH

If you use fish:

```fish
fish_add_path ~/.local/bin
```

If you use bash or zsh:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.profile
source ~/.profile
```

### 7. Run the menu

```bash
gpu-rgb
```

## Install From Git Instead

Use this if you want to clone the repository instead of downloading a release archive.

```bash
git clone https://github.com/YOUR_USERNAME/asrock-rx9070xt-rgb.git
cd asrock-rx9070xt-rgb
./install.sh
```

Replace `YOUR_USERNAME` with the account that owns the repository.

If `gpu-rgb` is not found after installing, make sure `~/.local/bin` is in your PATH as shown above.

## Other Linux Distros

Install `i2c-tools` using your distro package manager.

Debian / Ubuntu:

```bash
sudo apt install i2c-tools
```

Fedora:

```bash
sudo dnf install i2c-tools
```

openSUSE:

```bash
sudo zypper install i2c-tools
```

Then follow the same steps from the Arch section starting at **Load the I2C device module**.

## Usage

Open the menu:

```bash
gpu-rgb
```

Show help:

```bash
gpu-rgb --help
asrock-gpu-rgb-apply --help
```

Show the installed version:

```bash
gpu-rgb --version
```

Set a static color directly without opening the menu:

```bash
asrock-gpu-rgb-apply '#00A0FF'
```

Turn the lighting off:

```bash
asrock-gpu-rgb-apply off
```

## Menu Modes

These are the modes currently exposed by the menu.

| Menu Number | Mode Value | Menu Name | Color Choice | Notes |
|---:|---:|---|---|---|
| `1` | `0x01` | Static Color | Yes | Static color. |
| `2` | `0x02` | Breathing | Yes | Confirmed working. |
| `3` | `0x03` | Strobe | Yes | ASRock-style strobe/blinking effect. |
| `4` | `0x04` | RGB Cycle | No | Uses a custom speed table because the normal slowest speed can skip red. |
| `5` | `0x05` | Random | No | Random color changing effect. |
| — | `0x06` | Not used | No | Likely software-driven music mode; not exposed in the menu. |
| `6` | `0x07` | Color Shift / Fade | No | Hardware animation. |
| `7` | `0x08` | Visor / Back-And-Forth | Yes | Possibly broken on this card; may go black after each cycle. |
| `8` | `0x09` | Stacking Light, Right To Left | Yes | Hardware animation. |
| `9` | `0x0A` | Fill Wave, Left To Right | Yes | Hardware animation. |
| `10` | `0x0B` | Traveling Wave, Left To Right | Yes | Hardware animation. |
| `11` | `0x0C` | Marquee - Color Choice | Yes | Hardware animation. |
| `12` | `0x0D` | Marquee - Random Color Shift | No | Hardware animation. |
| `13` | `0x0E` | Color Wave | No | Hardware animation. |
| `14` | `0x0F` | Rainbow | No | Hardware animation. |

## Zone Choices

| Menu Choice | Channels Used |
|---|---|
| All Zones, Including GPU ARGB Header | `3 6 7` |
| GPU Body Only, Top + Fan | `6 7` |
| Top Side Only | `6` |
| Fan Only | `7` |
| ARGB Header Only | `3` |

Known channels on the tested card:

| Channel | Meaning |
|---:|---|
| `3` | GPU ARGB header |
| `6` | Top side / logo lighting |
| `7` | Fan lighting |

## Desktop Launcher

The installer creates a launcher named **GPU RGB**.

It tries to use one of these terminal emulators, in this order:

1. `alacritty`
2. `konsole`
3. `kitty`
4. `gnome-terminal`

Choose the terminal manually during install:

```bash
TERMINAL_CMD="alacritty -e" ./install.sh
```

Skip the desktop launcher:

```bash
INSTALL_DESKTOP=0 ./install.sh
```

## Advanced: Environment Overrides

Most users do not need this section.

The low-level writer accepts these environment variables:

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

## Advanced: Packet Format

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

From the repository folder, run:

```bash
./uninstall.sh
```

This removes the installed scripts and desktop launcher.

## Notes

- Hardware animation modes keep running after the menu closes.
- The RGB state may persist across reboot.
- Music mode is not implemented because it is likely software-driven.
- This project is not affiliated with ASRock.

## License

MIT License. See [`LICENSE`](LICENSE).
