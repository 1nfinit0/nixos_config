{ config, pkgs, ... }:

let
  cycleLayout = pkgs.writeShellScriptBin "hyprland-cycle-layout" ''
    state_file="/tmp/hyprland-layout-mode"
    current_layout="$(cat "$state_file" 2>/dev/null || echo master)"

    if [ "$current_layout" = "master" ]; then
      hyprctl keyword general:layout dwindle
      printf '%s\n' dwindle > "$state_file"
    else
      hyprctl keyword general:layout master
      printf '%s\n' master > "$state_file"
    fi
  '';
in
{
  home.packages = [ cycleLayout ];

  wayland.windowManager.hyprland.settings.bind = [
    # apps básicas
    "SUPER, RETURN, exec, kitty"
    "SUPER, D, exec, rofi -show drun"
    "SUPER SHIFT, W, exec, brave"

    # waybar
    "SUPER, B, exec, if pgrep waybar; then pkill waybar && hyprctl keyword general:gaps_out 0; else waybar & hyprctl keyword general:gaps_out '2,0,0,0'; fi"

    # Volumen osd
    ", XF86AudioMute,        exec, swayosd-client --output-volume mute-toggle"
    ", XF86AudioLowerVolume, exec, swayosd-client --output-volume lower"
    ", XF86AudioRaiseVolume, exec, swayosd-client --output-volume raise"
    "SUPER, F9, exec, mic-toggle"

    # Brillo osd
    ", XF86MonBrightnessDown, exec, swayosd-client --brightness lower"
    ", XF86MonBrightnessUp,   exec, swayosd-client --brightness raise"

    # grimblast - Screenshot
    ", Print, exec, grimblast copy screen"
    "SUPER SHIFT, S, exec, grimblast copy area"
    # cliphist - Clipboard manager
    "SUPER, V, exec, cliphist list | rofi -dmenu -p 'Clipboard' | cliphist decode | wl-copy"

    # cerrar ventana activa
    "SUPER, Q, killactive"

    # reorganiza el workspace activo alternando entre master y dwindle
    "SUPER, SPACE, exec, hyprland-cycle-layout"

    # mover foco entre ventanas
    "SUPER, left, movefocus, l"
    "SUPER, right, movefocus, r"
    "SUPER, up, movefocus, u"
    "SUPER, down, movefocus, d"
    "ALT, Tab, cyclenext"

    # workspaces (1–4)
    "SUPER, 1, workspace, 1"
    "SUPER, 2, workspace, 2"
    "SUPER, 3, workspace, 3"
    "SUPER, 4, workspace, 4"

    # mover ventana a workspace
    "SUPER SHIFT, 1, movetoworkspace, 1"
    "SUPER SHIFT, 2, movetoworkspace, 2"
    "SUPER SHIFT, 3, movetoworkspace, 3"
    "SUPER SHIFT, 4, movetoworkspace, 4"

    # mover la posición entre ventanas
    "SUPER SHIFT, left, swapwindow, l"
    "SUPER SHIFT, right, swapwindow, r"
    "SUPER SHIFT, up, swapwindow, u"
    "SUPER SHIFT, down, swapwindow, d"

    # resize de ventanas (CTRL + SUPER + flechas)
    "SUPER CTRL, left, resizeactive, -50 0"
    "SUPER CTRL, right, resizeactive, 50 0"
    "SUPER CTRL, up, resizeactive, 0 -50"
    "SUPER CTRL, down, resizeactive, 0 50"
  ];
}
