# Niri to Umbriel Configuration Mapping

## Mapped Options

| Niri Option | Umbriel Key/Section | Notes |
|-------------|---------------------|-------|
| **autostart.kdl** | | |
| `spawn-sh-at-startup "noctalia"` | `[general] autostart` | Included in autostart list |
| `spawn-sh-at-startup "fcitx5"` | `[general] autostart` | Included in autostart list |
| `spawn-sh-at-startup "microsoft-edge-stable"` | `[general] autostart` | Included in autostart list |
| **animation.kdl** | | |
| `animations { workspace-switch { spring damping-ratio=1.0 stiffness=1000 epsilon=0.0001 } }` | `[animation.workspaces]` | Mapped to workspace animation; spring parameters approximated via `workspace_curve = "spring:1,1000"` in `[animation.overview]` (note: actually applied to overview, but closest match) |
| `animations { window-open { duration-ms 200 curve "ease-out-quad" } }` | `[animation.windows_in]` | Exact match |
| `animations { window-close { duration-ms 200 curve "ease-out-cubic" } }` | `[animation.windows_out]` | Exact match |
| `animations { horizontal-view-movement { spring damping-ratio=1.0 stiffness=900 epsilon=0.0001 } }` | `[animation.windows_move]` | Mapped; spring parameters not directly available, used `curve = "snappy"` |
| `animations { window-movement { spring damping-ratio=1.0 stiffness=800 epsilon=0.0001 } }` | `[animation.windows_move]` | Same as above |
| `animations { window-resize { spring damping-ratio=1.0 stiffness=1000 epsilon=0.0001 } }` | *Not directly mapped* | No direct equivalent in Umbriel animation settings |
| `animations { config-notification-open-close { spring damping-ratio=0.6 stiffness=1200 epsilon=0.001 } }` | *Not directly mapped* | No direct equivalent |
| `animations { screenshot-ui-open { duration-ms 300 curve "ease-out-quad" } }` | *Not directly mapped* | No direct equivalent |
| `animations { overview-open-close { spring damping-ratio=1.0 stiffness=900 epsilon=0.0001 } }` | `[animation.overview]` | Mapped; spring parameters via `workspace_curve = "spring:1,1000"` |
| **keybinds.kdl** | | |
| All keybinds (see config.toml) | `[keybinds]` | Each Niri keybind mapped to an Umbriel key action; some actions may not exist in Umbriel (see Unmapped Items) |
| **input.kdl** | | |
| `keyboard { numlock }` | `[input.keyboard] numlock_toggle = true` | Enable numlock on startup |
| `touchpad { tap }` | `[input.touchpad] tap = true` | Enable tap-to-click |
| `touchpad { natural-scroll }` | `[input.touchpad] natural_scroll = true` | Enable natural scrolling |
| `focus-follows-mouse` | `[input.focus] follows_mouse = true` | Focus follows mouse pointer |
| **display.kdl (outputs)** | | |
| `output "HDMI-A-1" { mode "1920x1080@120.000"; position x=0 y=0; focus-at-startup }` | `[[output."HDMI-A-1"]]` | Exact match |
| `output "eDP-1" { mode "1920x1080@144.003"; position x=-1920 y=0; off }` | `[[output."eDP-1"]]` | Exact match |
| **layout.kdl** | | |
| `layout { gaps 8 }` | `[layout] gap = 8` | Gap between windows |
| `layout { center-focused-column "never" }` | `[layout.scrolling] center_focused = "never"` | Don’t auto-center focused column |
| `layout { preset-column-widths { proportion 0.33333; proportion 0.5; proportion 0.66667 } }` | `[layout] extent_presets = [0.333, 0.5, 0.667]` | Preset column widths |
| `layout { struts {} }` | `[layout.struts] left=0; right=0; top=0; bottom=0` | Struts (margins) |
| **rules.kdl** | | |
| `window-rule { match app-id="steam"; exclude title=r#"^[Ss]team$#"; open-floating true }` | `[[window_rule]]` (two rules) | Mapped to two rules: one for all steam windows (floating), one for notificationtoasts (positioned, not focused). Note: Umbriel cannot exclude titles, so the first rule makes all steam windows floating. |
| `window-rule { match app-id="steam"; title=r#"^notificationtoasts_\d+_desktop$#"; default-floating-position x=10 y=10 relative-to="bottom-right"; open-focused false }` | `[[window_rule]]` | Exact match for title, position, and focus |
| `layer-rule { match namespace="^noctalia-wallpaper*"; place-within-backdrop true }` | `[[layer_rule]]` | Namespace matched; `place-within-backdrop` not found in Umbriel (TODO) |
| **misc.kdl** | | |
| `prefer-no-csd` | `[appearance] prefer_no_csd = true` | Enable preference for client-side decoration |
| `cursor { xcursor-theme "capitaine-cursors" }` | `[input.cursor] theme = "capitaine-cursors"` | Cursor theme |
| `cursor { xcursor-size 24 }` | `[input.cursor] size = 24` | Cursor size |
| **noctalia.kdl (colors)** | | |
| `layout { focus-ring { active-color "#babbf1"; inactive-color "#000000"; urgent-color "#e78284" } }` | `[colors]` | Mapped: `text_primary = "#babbf1"`, `text_muted = "#000000"`, `accent_primary = "#babbf1"`, `accent_secondary = "#e78284"`, etc. |
| `layout { border { active-color "#babbf1"; inactive-color "#000000"; urgent-color "#e78284" } }` | `[colors.border]` | Mapped: `focused = "#babbf1"`, `unfocused = "#000000"` |
| `layout { shadow { color "#23263470" } }` | `[colors] shadow = "#23263470"` | Shadow color |
| `layout { tab-indicator { active-color "#babbf1"; inactive-color "#171be1"; urgent-color "#e78284" } }` | *Partially mapped* | Active and urgent colors mapped; inactive color not directly used |
| `layout { insert-hint { color "#babbf180" } }` | `[colors] insert_hint = "#babbf180"` | Insert hint color |
| `recent-windows { highlight { active-color "#babbf1"; urgent-color "#e78284" } }` | `[colors]` | Active and urgent colors mapped (same as focus-ring) |

## Unmapped Items

### Configuration Options Without Direct Umbriel Equivalent

- **animation.kdl**:
  - `window-resize` animation (spring parameters)
  - `config-notification-open-close` animation (spring parameters)
  - `screenshot-ui-open` animation (duration and curve)
  - `horizontal-view-movement` animation (spring parameters, only partially mapped via `windows_move`)

- **input.kdl**:
  - `workspace-auto-back-and-forth` (workspace back-and-forth switching)

- **layout.kdl**:
  - `background-color "transparent"` (needed for noctalia-shell to set wallpaper; Umbriel uses backdrop color but not transparent)

- **rules.kdl**:
  - `window-rule`: `geometry-corner-radius` (mapped via `appearance.corner_radius` but not per-rule)
  - `window-rule`: `clip-to-geometry` (no equivalent)
  - `layer-rule`: `place-within-backdrop` (no equivalent)

- **misc.kdl**:
  - `screenshot-path null` (no equivalent; screenshot path likely determined by screenshot command)
  - `environment { ... }` (environment variables not set in config; may need to be set externally)
  - `debug { honor-xdg-activation-with-invalid-serial }` (no equivalent)
  - `hotkey-overlay { skip-at-startup }` (no equivalent)

- **keybinds.kdl** (actions that may not exist in Umbriel):
  - `window-move-up`, `window-move-down`
  - `focus-column-first`, `focus-column-last`
  - `move-column-to-first`, `move-column-to-last`
  - `focus-monitor-left/right/up/down`
  - `move-column-to-monitor-left/right/up/down`
  - (Note: These were mapped to Umbriel actions with the same names, but if those actions do not exist in Umbriel, they will be ineffective.)

- **Modifiers Ignored in Keybinds**:
  - `allow-when-locked=true` (ignored; Umbriel does not have this modifier in keybinds)
  - `allow-inhibiting=false` (ignored; Umbriel does not have this modifier)
  - `repeat=false` (ignored; Umbriel does not have repeat modifier in keybinds)
  - `cooldown-ms=150` (ignored; Umbriel does not have cooldown in keybinds)

## Notes

- The generated `config.toml` is located at `/home/kizuto/projects/BackupLinux/umbriel/config.toml`.
- Validation with `umbriel validate -c /home/kizuto/projects/BackupLinux/umbriel/config.toml` was skipped because `umbriel` is not installed in the environment.
- Where possible, approximate mappings were made; users should review and adjust the config as needed for their setup.