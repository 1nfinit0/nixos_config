{ pkgs, ... }:
{
  services.dunst = {
    enable = true;
    settings = {
      global = {
        monitor = 0;
        follow = "mouse";
        width = 300;
        height = 100;
        origin = "top-right";
        offset = "10x10";
        corner_radius = 8;
        font = "JetBrainsMono Nerd Font 10";
        timeout = 5;
      };
    };
  };
}
