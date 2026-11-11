# LinuxRice

Dotfiles repo for customizing (ricing) Arch Linux. The roadmap is in `RICE.md`.

## System
- Arch Linux, **niri 26.04** (Wayland), monitor HDMI-A-1 at **1366x768** (keep it, don't change it to 1080p).
- Login: greetd + regreet via `cage` (`/etc/greetd/`). To be customized later; don't touch it unless asked.
- Terminal **alacritty**, shell **zsh** + starship. AUR helper: `yay`.

## Structure and links
- All config lives in the repo and is linked into `$HOME` with `./install.sh` (list `LINKS`, format `repo-path|destination`).
- `install.sh` is idempotent: it skips links that are already correct and backs up what it replaces as `*.bak` (or `*.bak.<date>`).
- Current links: `alacritty/` → `~/.config/alacritty`, `zsh/.zshrc` → `~/.zshrc`, `niri/` → `~/.config/niri`, `waybar/` → `~/.config/waybar`.
- **Never edit files in `~/.config` directly**: edit the repo copy and link it with `install.sh`.
- Originals backed up: `~/.zshrc.bak`, `~/.config/niri.bak/`.
- `audits/` and `notes/` are working folders: they are never added to `install.sh` and never linked into `$HOME`.

## Current state
- Fonts: `maplemono-nf` (AUR, `Maple Mono NF`, the one in use) and `ttf-lilex-nerd` (`Lilex Nerd Font Mono`, alternative).
- alacritty: Maple Mono NF 10.5 (Lilex commented out), opacity 0.6, padding 4 + `dynamic_padding`, live reload, angel palette applied.
- niri: `gaps 8`; `layout.background-color "#0c0c0c29"`; **no borders** (`focus-ring off`, `border off`); global `draw-border-with-background false`; active window = centered gold glow (`shadow` `#cdac7140`, `inactive-color` transparent); inactive windows at `opacity 0.5`.
- zsh: minimal config + zsh-autosuggestions, starship and zsh-syntax-highlighting (last).
- Wallpaper: `wallpapers/wallhaven-xew6xd.png` (black angel with a gold halo) via `swaybg` in `niri/config.kdl`, plus a `layer-rule` with `place-within-backdrop` for the Overview.
- waybar (`waybar/`, started by `spawn-at-startup` in niri): bottom, height 24, 6px margin on all sides, transparent bar (`exclusive` default, windows don't go under it), `reload_style_on_change`. Modules: `niri/workspaces` + `niri/window` (max 50) | `clock` | `pulseaudio` (level icons) + `network` (wifi icon + signal %, SSID in tooltip). No battery (desktop PC). Each module is a solid `gold` pill (radius 8) with `bg` text, hover `gold-light` with 200ms transition; active workspace inverted (`bg` background, `gold` number), inactive in `bronze-dark`. Tooltips: `bg` background, 1px `gold` border, radius 8, `fg` text (inner GTK layers made transparent so the corners round).
- Tried and discarded on waybar: glass bar with niri blur (`layer-rule` + `background-effect { blur true; xray false }`, which niri 26.04 supports) and semi-transparent gold modules over windows.
- **Next:** apply the "Palette" section to fuzzel, mako, swaylock, etc. (and decide whether to use the purple accent).

## Palette (from the angel)
Extracted with ImageMagick from `wallpapers/wallhaven-xew6xd.png`. **Use these values in every config** (alacritty, niri, waybar, fuzzel, mako, swaylock, regreet…).

Base (measured from the image):
| Name       | Hex       | Use                                   | Source          |
|------------|-----------|---------------------------------------|-----------------|
| `bg`       | `#121212` | main background                       | wallpaper background (dominant) |
| `surface`  | `#1f1f20` | bars, panels, inactive cells          | shadows |
| `overlay`  | `#272727` | hover, selection, separators          | statue |
| `stone`    | `#524d46` | inactive borders, comments, dim text  | warm stone of the statue |
| `fg`       | `#d8d2c4` | main text (warm marble)               | derived from the gold, desaturated |

Gold (measured from the halo):
| Name          | Hex       | Use                                    |
|---------------|-----------|----------------------------------------|
| `gold`        | `#cdac71` | **main accent**: focus, active workspace, cursor |
| `gold-light`  | `#d4bb89` | highlighted text, hover over accent    |
| `gold-dim`    | `#ac9162` | secondary accent                       |
| `bronze`      | `#8c6c36` | subtle borders, accent backgrounds     |
| `bronze-dark` | `#56462e` | very subtle accent background, selection |

Optional accent (**not** from the image, pending decision): deep purple `#4a2c6e`.

ANSI terminal colors (derived: muted and warm to match the base):
| Color   | normal    | bright    |
|---------|-----------|-----------|
| black   | `#1f1f20` | `#524d46` |
| red     | `#9e4b4b` | `#b86464` |
| green   | `#7d8c5c` | `#96a673` |
| yellow  | `#cdac71` | `#d4bb89` |
| blue    | `#5d6f8a` | `#7688a3` |
| magenta | `#7a5c8a` | `#9479a3` |
| cyan    | `#5f8580` | `#789e98` |
| white   | `#c8c2b6` | `#e6e0d4` |

Re-extract: `magick <img> -resize 25% -colors 16 -format '%c' histogram:info:- | sort -rn`

## Aesthetic
Dark, sober and elegant. Nothing bright. Black base; accents in gold (from the wallpaper) and possibly deep purple or strong blue.

## Auditor agents
When the user asks to "launch an auditor agent" for a problem:

1. **Communication channel**
   - Launch the agent in the background, **read-only**: no edits, installs, kills or launching processes.
   - In its prompt, require it to send a progress message (SendMessage to the main session) at every relevant step: what it checks, what it finds, and what it rules out.
   - Relay each report to the user in short messages, in Spanish, as they arrive. Don't wait until the end.
   - To ask for more detail or new checks, keep talking to the same agent with SendMessage instead of launching another.

2. **Log file (bitácora)**
   - Every log goes **only** in the `audits/` folder at the repo root, never next to the configs (`niri/`, `alacritty/`, `zsh/`, etc.). `audits/` is never added to `install.sh` and is never linked into `$HOME`.
   - One file per problem: `audits/YYYY-MM-DD-<problem-slug>.md`, created **before** launching the agent.
   - The main session maintains it (the auditor stays read-only). Update it with every report and with every change applied.
   - Sections:
     - `## Problem`: symptom and context.
     - `## Log`: timestamped entries (`HH:MM`): checks, findings, failures.
     - `## Proposals`: candidate fixes, with pros and cons.
     - `## Changes applied`: what was changed, in which file, and the commit.
     - `## Solution`: final cause and fix, or the reason it stays open.
     - `## Status`: `open` / `resolved` / `discarded`.
   - Only apply fixes once the user approves them, and record that in the log.

## Several agents in parallel
Several Claude sessions work on the repo at the same time. There are two roles. The role is given by the user in the first message.

### Component agents (default)
Every session is a component agent unless the user says "you are the JEFE".
- May only modify `CLAUDE.md` (only the lines of their component) and the files of their component (e.g. a waybar session: only `waybar/`; a yazi session: only `yazi/`).
- Changes to shared files (`install.sh`, `niri/config.kdl`, `RICE.md`, other components' folders…) are for the session that owns them. If yours needs one, tell the user and let them decide; don't edit it.
- **Do NOT commit, stage or push.** Leave your changes uncommitted in the working tree. The JEFE commits.
- Uncommitted changes you didn't make belong to another agent: don't revert or overwrite them.
- When you finish a change, append a short entry to `notes/<component>.md` (date, what changed, why, how it was validated). The JEFE reads it.
- When editing `CLAUDE.md`, touch only the lines for your component and keep the rest as it is.

### JEFE (only when the user says so)
Reviews and commits the work of the component agents; does not design components itself and does not edit component files (if something is wrong, report it to the user so the component agent fixes it).
- Flow:
  1. `git status` and `git diff` per component; read `notes/<component>.md`.
  2. Validate: `niri validate -c niri/config.kdl`, `zsh -n`, waybar `config.jsonc` parses and `style.css` has no syntax errors, etc.
  3. Check that each agent stayed inside its own folder, and that no secrets, tokens or personal data slipped in.
  4. One commit per component: `git add <component>/` (never `-A` or `.`). Message format: `waybar: short description`.
  5. `CLAUDE.md` is committed separately, in its own commit, after reviewing its diff line by line.
- If an agent touched files outside its component, don't commit those: report it to the user.
- `notes/` and `audits/` are not committed unless the user asks.
- Before `git push`, show the list of commits to be pushed and wait for the user's OK.

## How to work with the user
- Speak in Spanish.
- **Step by step**: do only what was asked, then wait. Don't chain extra steps.
- Prefer plain-text questions over multiple-choice dialogs.
- Bar: **waybar at the bottom** (not installed yet).
- Always validate before applying: `niri validate -c niri/config.kdl`, `zsh -n`, etc.
- The user installs packages themselves (sudo/yay); give them the command.
