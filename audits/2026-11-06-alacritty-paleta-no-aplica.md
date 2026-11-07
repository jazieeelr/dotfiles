# alacritty doesn't show the angel palette

## Problem
After applying the angel palette in `alacritty/alacritty.toml` (bg `#121212`, fg `#d8d2c4`, gold cursor `#cdac71`, warm ANSI colors), alacritty doesn't show those colors.

Context:
- `~/.config/alacritty` → symlink to `LinuxRice/alacritty`.
- `live_config_reload = true`, opacity 0.6.
- `alacritty migrate --dry-run` passed with no errors.
- Font changed to `Maple Mono NF` shortly before.

## Log
- **20:31**: Log created. Launching a read-only auditor agent.
- **20:32**: Report 1 (config resolution):
  - ✅ alacritty 0.17.0. `XDG_CONFIG_HOME` is unset. `~/.config/alacritty` → repo. No `~/.alacritty.toml`, `/etc/alacritty` or `.yml` files to compete with it.
  - ✅ The TOML parses cleanly and `migrate --dry-run` exits 0.
  - ✅ Two processes, both plain `alacritty`, with no `--config-file` or `-o`.
  - ⚠️ PID 1531 started at 20:26:51, **before** the config was saved (20:29:46). PID 1871 started at 20:30:09, **after** it.
  - Next: logs, git diff, how niri launches it, opacity.
- **20:33**: Report 2 (**key finding**):
  - ✅ **Both windows already use the new palette.** `alacritty msg ... get-config` on each socket (PID 1531 and PID 1871) returns bg `#121212`, fg `#d8d2c4`, cursor `#cdac71`, opacity 0.6.
  - ✅ Live reload works through the symlink: PID 1531 started before the change and still reloaded.
  - ✅ niri launches plain `alacritty` (Mod+T). No `.desktop` override.
  - ❌ Ruled out: config resolution, TOML validity, live reload.
  - Hypothesis: the colors are applied but **look** different. Next: opacity 0.6 over the wallpaper, niri's `background-color #0c0c0c29`, and OSC sequences from zsh/the prompt.
- **20:35**: Report 3 (conclusion):
  - ✅ zsh doesn't override colors: no OSC 4/10/11 sequences. starship has no config, so it uses the palette's 16 ANSI colors. `TERM=alacritty`, `COLORTERM=truecolor`.
  - ✅ **alacritty is not at fault.**
  - 🔍 The wallpaper behind the terminal is an almost uniform dark gray (`#121212`–`#151514`). At opacity 0.6, the old background composited to about `#0e0e11` and the new one to about `#121212`, **only about 4 levels apart**. The change in background can't be seen.
  - The visible changes are in the text (`fg`), the cursor, the selection and the ANSI colors.

- **20:40**: The user reports that **the terminal looks blue**. That rules out the "imperceptible difference" explanation and points to something blue behind the window.
  - 🔍 `niri/config.kdl`: `focus-ring { width 4; active-color "#7fc8ff" }` (niri's default light blue).
  - 🔍 The comment in the config itself (lines ~148–158) says niri draws the focus ring and border **as a solid background behind the window** (because of client-side decorations), so they **show through semi-transparent windows**.
  - ❌ **Real cause:** alacritty at opacity 0.6 lets through 40% of the focus ring's **blue `#7fc8ff`**, which is painted behind the focused window. The auditor didn't detect it because it only looked at the wallpaper and the workspace overlay.

## Proposals
1. **Do nothing**: the palette is applied. Confirm with `printf '\e[33mgold \e[35mpurple \e[31mred\e[0m\n'`, the gold cursor, and a text selection (bronze).
2. **Raise the opacity** (e.g. 0.85–0.9) so the terminal shows its own background more and blends less with the wallpaper.
3. **Make the difference stand out**: use `surface` `#1f1f20` as the terminal background, so it's set apart from the wallpaper's black.
4. (Auditor's suggestion) A **warm** background such as `#1a1714` to keep the transparency and still tell it apart from the neutral wallpaper.

Instant test with no changes: `alacritty -o window.opacity=1.0` opens a new window with the solid `#121212` background.

Note: the palette change in `alacritty/alacritty.toml` isn't committed yet.

Proposals for the real cause (blue focus ring):
5. **`window-rule { draw-border-with-background false }`** (global) in `niri/config.kdl`: niri draws the ring only *around* the window, never behind it. ← recommended
6. **`prefer-no-csd`**: niri asks apps to drop their own decorations and draws the ring around them. alacritty already uses `decorations = "None"`, but this affects GTK apps too. Can be combined with 5.
7. Also change the focus ring to the palette: `active-color` `gold` `#cdac71`, `inactive-color` `stone` `#524d46`.

## Changes applied
- **20:36**: Proposal 5 approved by the user (only that one; proposal 7, the gold focus ring, was not applied). `niri/config.kdl`: added a global `window-rule { draw-border-with-background false }` before the other window-rules. `niri validate`: OK. niri reloads it live.
- **20:37**: The user notes that the focus ring is still blue. Trying proposal 7 (approved as a test): `focus-ring` → `active-color "#cdac71"` (gold), `inactive-color "#524d46"` (stone). `niri validate`: OK. Afterwards the user will compare it with `focus-ring off`.
- **20:38**: At the user's request: `focus-ring` colors at ~70% opacity (`#cdac71b3` / `#524d46b3`) and `gaps` 16 → 8. `niri validate`: OK.
- **20:39**: Asymmetric padding in alacritty (more space at the bottom/right, from cell rounding) → `dynamic_padding = true` in `alacritty/alacritty.toml`.
- **20:40**: Comparison test: `focus-ring { off }` (the gold colors stay in the config, ready to reactivate). `niri validate`: OK.
- **20:42**: The user prefers no border, but needs to see which window is active. Applied option 3: `shadow { on; color "#000000b3"; inactive-color "#00000000" }` (shadow only on the active window) + `window-rule { match is-focused=false; opacity 0.8 }`. `niri validate`: OK.
- **20:43**: The active window's shadow becomes a gold glow: `color "#cdac7140"` (gold at 25%), `offset x=0 y=0` (centered halo). Inactive opacity 0.8 stays. `niri validate`: OK.
- **20:44**: Stronger dimming: inactive windows' opacity 0.8 → 0.65. `niri validate`: OK.
- **20:45**: Even stronger dimming: 0.65 → 0.5. `niri validate`: OK.
- Commit: «Paleta del ángel en alacritty y foco sin bordes en niri» (see `git log -- audits/`).

## Solution
**Cause:** the angel palette was applied correctly in alacritty (confirmed over IPC). The blue came from **niri**: the default focus ring (`#7fc8ff`) is drawn as a solid background behind each window, and it showed through alacritty at opacity 0.6.

**Fix:**
- `window-rule { draw-border-with-background false }`: niri no longer paints anything behind windows.
- The user chose **no borders**: `focus-ring { off }` (the semi-transparent gold colors stay in the config for reuse).
- Active-window indicator with no border:
  - centered gold glow (`shadow { on; color "#cdac7140"; offset 0 0; inactive-color "#00000000" }`);
  - strong dimming of inactive windows (`window-rule { match is-focused=false; opacity 0.5 }`).

**Adjustments along the way:** `gaps` 16 → 8 and `dynamic_padding = true` in alacritty (symmetric padding).

**Lesson:** for semi-transparent windows in niri, check focus-ring/border before blaming the app's config.

## Status
resolved
