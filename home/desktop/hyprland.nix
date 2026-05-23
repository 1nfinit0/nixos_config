{ config, pkgs, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    configType = "hyprlang";
    settings = {
      input = {
        kb_layout = "latam";
      };

    exec-once = [
      # "waybar"
      "wl-paste --watch cliphist store"
    ];

    };
  };
  imports = [
    ./binds.nix
    ./look.nix
    ./waybar.nix
    ./osd.nix
    ./monitor.nix
    ./wallpaper.nix
  ];
}
