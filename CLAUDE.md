# LinuxRice

Dotfiles repo for customizing (ricing) Arch Linux. The roadmap is in `RICE.md`.

## System
- Arch Linux, **niri 26.04** (Wayland), monitor HDMI-A-1 at **1366x768** (keep it, don't change it to 1080p).
- Login: greetd + regreet via `cage` (`/etc/greetd/`). To be customized later; don't touch it unless asked.
- Terminal **alacritty**, shell **zsh** + starship. AUR helper: `yay`.

## Structure and links
- All config lives in the repo and is linked into `$HOME` with `./install.sh` (list `LINKS`, format `repo-path|destination`).
- `install.sh` is idempotent: it skips links that are already correct and backs up what it replaces as `*.bak` (or `*.bak.<date>`).
- Current links: `alacritty/` → `~/.config/alacritty`, `zsh/.zshrc` → `~/.zshrc`, `niri/` → `~/.config/niri`.
- **Never edit files in `~/.config` directly**: edit the repo copy and link it with `install.sh`.
- Originals backed up: `~/.zshrc.bak`, `~/.config/niri.bak/`.

## Current state
- Fonts: `ttf-lilex-nerd` (default, `Lilex Nerd Font Mono`) and `maplemono-nf` (AUR, `Maple Mono NF`).
- alacritty: Lilex 10.5, opacity 0.6, padding 4, live reload. Provisional palette (it will change).
- zsh: minimal config + zsh-autosuggestions, starship and zsh-syntax-highlighting (last).
- Wallpaper: `wallpapers/wallhaven-xew6xd.png` (black angel with a gold halo) via `swaybg` in `niri/config.kdl`, plus a `layer-rule` with `place-within-backdrop` for the Overview.
- **Next:** extract the palette from the angel (base black/gray/marble + gold; possible deep-purple accent) and apply it to alacritty, niri, waybar, etc.

## Aesthetic
Dark, sober and elegant. Nothing bright. Black base; accents in gold (from the wallpaper) and possibly deep purple or strong blue.

## How to work with the user
- Speak in Spanish.
- **Step by step**: do only what was asked, then wait. Don't chain extra steps.
- Prefer plain-text questions over multiple-choice dialogs.
- Bar: **waybar at the bottom** (not installed yet).
- Always validate before applying: `niri validate -c niri/config.kdl`, `zsh -n`, etc.
- The user installs packages themselves (sudo/yay); give them the command.
