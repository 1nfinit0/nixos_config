{ config, pkgs, ... }:
{
  wayland.windowManager.hyprland.settings = {
    general = {
      gaps_in = 1;
      gaps_out = 0;
      border_size = 1;
	"col.active_border" = "rgba(88888888)";
	"col.inactive_border" = "rgba(44444444)";
    };
    decoration = {
      rounding = 6;
      blur = {
        enabled = true;
        size = 6;
        passes = 2;
      };
    };
    animations = {
      enabled = true;
      bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
      animation = [
        "workspaces, 1, 4, default, fade"
        "windows, 1, 4, myBezier"
        "windowsOut, 1, 4, default, popin 80%"
        "fade, 1, 4, default"
        "border, 1, 5, default"
      ];
    };
  };
}
