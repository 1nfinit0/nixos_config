{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland.settings.bind = [
    # apps básicas
    "SUPER, RETURN, exec, kitty"
    "SUPER, D, exec, rofi -show drun"

    # cerrar ventana activa
    "SUPER, Q, killactive"

    # mover foco entre ventanas
    "SUPER, left, movefocus, l"
    "SUPER, right, movefocus, r"
    "SUPER, up, movefocus, u"
    "SUPER, down, movefocus, d"

    # workspaces (1–4)
    "SUPER, 1, workspace, 1"
    "SUPER, 2, workspace, 2"
    "SUPER, 3, workspace, 3"
    "SUPER, 4, workspace, 4"

    # mover ventana a workspace (SHIFT + SUPER + número)
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
    "SUPER CTRL, left, resizeactive, -20 0"
    "SUPER CTRL, right, resizeactive, 20 0"
    "SUPER CTRL, up, resizeactive, 0 -20"
    "SUPER CTRL, down, resizeactive, 0 20"
  ];
}
