{ config, pkgs, ... }:
{
  home.file."Pictures/wall.png" = {
    source = ./wall.png;
  };

  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "${pkgs.swaybg}/bin/swaybg -i ${config.home.homeDirectory}/Pictures/wall.png -m fill"
    ];
  };
}
