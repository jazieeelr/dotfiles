# LinuxRice — Hoja de ruta

Rice para **Arch Linux + niri (Wayland)** · monitor 1366x768 · login greetd.

**Estética:** oscura, sobria y elegante. Base negra con acento morado profundo / azul fuerte. Nada brillante.

| Rol        | Color     |
|------------|-----------|
| Fondo      | `#0b0b10` |
| Superficie | `#16161e` |
| Texto      | `#c8c8d8` |
| Acento 1   | `#5b3fa0` (morado) |
| Acento 2   | `#2a4a9a` (azul)   |

> La paleta se ajustará al wallpaper final.

---

## Estructura del repo

```
LinuxRice/
├── alacritty/alacritty.toml
├── niri/config.kdl
├── waybar/{config.jsonc,style.css}
├── zsh/.zshrc
├── starship/starship.toml
├── fuzzel/fuzzel.ini
├── mako/config
├── wallpapers/
├── scripts/
├── install.sh        # crea symlinks repo → ~/.config (respalda originales en *.bak)
└── RICE.md
```

Regla: **toda config vive en el repo** y se enlaza a `~/.config`. Commit después de cada paso.

---

## Paso 1 — Fuentes

```sh
sudo pacman -S ttf-lilex-nerd
yay -S maplemono-nf
```

- `maplemono-nf` = Maple Mono con Nerd Font y *hinting* (mejor nitidez a 1366x768).
- Verificar nombres exactos para las configs:
  ```sh
  fc-list : family | grep -iE 'lilex|maple'
  ```
- Fuente de UI (barra, launcher, notificaciones): se puede usar la misma mono o añadir una sans (`inter-font` o `ttf-ibm-plex`).

## Paso 2 — Terminal: alacritty

- Crear `alacritty/alacritty.toml`:
  - `live_config_reload = true` para probar cambios al instante.
  - Fuente 10.5 pt, Lilex y Maple alternables comentando una línea.
  - Padding ~8 px, opacidad 0.95, colores de la paleta.
- `scripts/font-preview.sh` para comparar: código, iconos, `0O 1lI`, ligaduras `-> => !=`, cursiva/negrita.
- Elegir la fuente definitiva.

## Paso 3 — Shell: zsh + starship

Ya instalados: `zsh`, `starship`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, `zsh-completions` (falta cargarlos).

- Mover `.zshrc` al repo (`zsh/.zshrc`) y añadir:
  ```sh
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh  # siempre al final
  eval "$(starship init zsh)"
  ```
- `starship/starship.toml`: prompt minimalista de una o dos líneas con acentos morado/azul.
- Extras opcionales: `eza` (ls con iconos), `bat` (cat con color), `fzf` + `zoxide` (navegación), `fastfetch`.

## Paso 4 — Wallpaper: swaybg

```sh
sudo pacman -S swaybg
```

- Buscar en Wallhaven/repos de wallpapers: oscuro, ≥1366x768, 16:9, tonos negro/morado/azul.
- Guardar en `wallpapers/`.
- En `niri/config.kdl`:
  ```kdl
  spawn-at-startup "swaybg" "-m" "fill" "-i" "/home/jazi/Escritorio/LinuxRice/wallpapers/<archivo>"

  layer-rule {
      match namespace="^wallpaper$"
      place-within-backdrop true
  }
  ```
  (la layer-rule muestra el fondo también detrás del Overview).

## Paso 5 — niri

- Copiar `~/.config/niri/config.kdl` al repo.
- Ajustar a la paleta: `focus-ring` (acento morado), `border`, `gaps` (~8 px), esquinas redondeadas (`geometry-corner-radius`).
- `prefer-no-csd` para quitar decoraciones de cliente.
- Validar siempre antes de aplicar: `niri validate`.

## Paso 6 — Barra inferior: waybar

```sh
sudo pacman -S waybar
```

- `"position": "bottom"`, altura ~28 px.
- Módulos: izquierda `niri/workspaces` · centro `niri/window` · derecha `pulseaudio`, `network`, `clock`, `tray`.
- `style.css`: fondo oscuro translúcido, workspace activo en morado, iconos Nerd.

## Paso 7 — Launcher y notificaciones

- **fuzzel** (ya instalado): tema con la paleta en `fuzzel/fuzzel.ini`.
- **mako** (`sudo pacman -S mako`): notificaciones con la misma paleta, bordes en acento.
- **swaylock** (`Super+Alt+L`): colores y wallpaper a juego.

## Paso 8 — Tema GTK/Qt y cursores

- GTK oscuro (p. ej. `adw-gtk-theme` en modo dark) + `nwg-look` para aplicarlo.
- Iconos: `papirus-icon-theme` (variante dark, carpetas en morado con `papirus-folders`).
- Cursor sobrio (p. ej. `bibata-cursor-theme`) definido también en `niri/config.kdl` (`cursor { xcursor-theme ... }`).

## Paso 9 — Login: greetd + regreet

- `/etc/greetd/regreet.toml`: `[background] path = "/usr/share/backgrounds/<wallpaper>"`, tema GTK oscuro, misma fuente.
- Copiar el wallpaper a `/usr/share/backgrounds/` (el usuario `greeter` no lee `/home`).
- Guardar copia de referencia en `greetd/` del repo.

## Paso 10 — `install.sh` y README

- Script idempotente que crea los symlinks y respalda lo existente.
- README con capturas del resultado.

---

## Verificación en cada paso

- `niri validate` antes de recargar niri.
- Lanzar `waybar` / `mako` desde terminal para ver errores.
- `git commit` al terminar cada paso.
