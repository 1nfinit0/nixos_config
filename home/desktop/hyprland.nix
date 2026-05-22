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
    };
  };
  imports = [
    ./binds.nix
    ./look.nix
    ./monitor.nix
    ./wallpaper.nix
  ];
}
