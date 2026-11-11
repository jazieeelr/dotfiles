#!/usr/bin/env bash
# Links the repo configs into $HOME. Safe to run several times.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# "path in the repo|destination"
LINKS=(
  "alacritty|$HOME/.config/alacritty"
  "zsh/.zshrc|$HOME/.zshrc"
  "niri|$HOME/.config/niri"
  "waybar|$HOME/.config/waybar"
  "yazi|$HOME/.config/yazi"
  "fuzzel|$HOME/.config/fuzzel"
  "applications/xgps.desktop|$HOME/.local/share/applications/xgps.desktop"
  "applications/xgpsspeed.desktop|$HOME/.local/share/applications/xgpsspeed.desktop"
  "applications/qv4l2.desktop|$HOME/.local/share/applications/qv4l2.desktop"
  "applications/qvidcap.desktop|$HOME/.local/share/applications/qvidcap.desktop"
  "applications/Alacritty.desktop|$HOME/.local/share/applications/Alacritty.desktop"
  "applications/brave-browser.desktop|$HOME/.local/share/applications/brave-browser.desktop"
  "applications/yazi.desktop|$HOME/.local/share/applications/yazi.desktop"
)

link() {
  local src="$REPO/$1" dst="$2"

  if [[ ! -e "$src" ]]; then
    echo "!! missing in the repo: $1"
    return
  fi

  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    echo "ok $dst"
    return
  fi

  if [[ -e "$dst" || -L "$dst" ]]; then
    local bak="$dst.bak"
    [[ -e "$bak" || -L "$bak" ]] && bak="$dst.bak.$(date +%Y%m%d%H%M%S)"
    mv "$dst" "$bak"
    echo "-> backup: $bak"
  fi

  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  echo "+  $dst -> $src"
}

for entry in "${LINKS[@]}"; do
  link "${entry%%|*}" "${entry#*|}"
done
