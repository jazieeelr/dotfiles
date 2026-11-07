# Wallpaper not visible in niri

## Problem
The angel wallpaper (`wallpapers/wallhaven-xew6xd.png`) didn't show on the desktop, even after a reboot.

Context:
- niri 26.04, config linked from the repo (`~/.config/niri` → `LinuxRice/niri`).
- swaybg in `spawn-at-startup`, plus this rule:
  ```kdl
  layer-rule {
      match namespace="^wallpaper$"
      place-within-backdrop true
  }
  ```

## Log
Times are approximate (local).

- **20:08**: Configured swaybg and the `place-within-backdrop` rule in `niri/config.kdl`. Created the `~/.config/niri` symlink with `install.sh`. `niri validate`: OK.
- **20:13**: The user rebooted. The wallpaper still doesn't show.
- **20:15**: Launched a read-only auditor agent.
- **20:16**: Auditor results:
  - ✅ swaybg 1.2.2 installed and running (`pgrep -a swaybg` → PID 862 with the correct path). No errors in `journalctl --user -b`.
  - ✅ Valid PNG (1920x1080 RGBA), readable, correct path.
  - ✅ niri loads the repo config through the symlink. `$NIRI_CONFIG` is empty and `/etc/niri` doesn't exist.
  - ✅ The session started (20:13:53) after the symlink was created (20:08:44).
  - ✅ `niri msg layers` → `Background layer: Namespace "wallpaper"`. Nothing in Bottom, Top or Overlay.
  - ❌ **Cause:** `place-within-backdrop true` moves the wallpaper into the backdrop, which is only visible in the Overview and between workspaces. Each workspace paints its own opaque background (the default `layout.background-color`) on top of it.
  - ⚠️ Side finding: `waybar` isn't installed, so its `spawn-at-startup` does nothing.
  - ⚠️ Side finding: `xwayland-satellite` is missing (`error spawning xwayland-satellite` in the log), so X11 apps can't run.

## Proposals
1. **Delete the `layer-rule`.** Simple, but the wallpaper wouldn't show in the Overview.
2. **`background-color` with transparency in `layout {}`** (the approach in niri's docs). The wallpaper shows in normal view and in the Overview, and the opacity gives a tint that can be adjusted. ← **Chosen**
3. **A second wallpaper process with its own namespace for the backdrop** (swww/wpaperd). More complex, not needed.

## Changes applied
- **20:18**: `niri/config.kdl`, `layout {}` block → `background-color "#0c0c0c4d"` (black at ~30%). Approved by the user. `niri validate`: OK.
- **20:20**: Changed to `background-color "#0c0c0c29"` (~16%, about 20% brighter), at the user's request. `niri validate`: OK.
- Commit: «Paleta del ángel en alacritty y foco sin bordes en niri» (see `git log -- audits/`).

## Solution
The wallpaper was working but hidden: the backdrop rule sent it behind the workspaces' opaque background. Fixed by making `layout.background-color` semi-transparent (`#0c0c0c29`), which keeps the wallpaper in the Overview too.

Pending side issues (outside this problem):
- Install `waybar` (bar step).
- Install `xwayland-satellite` for X11 apps.

## Status
resolved
