{ config, pkgs, ... }:
{
  # SwayOSD: overlay para volumen y brillo
  services.swayosd = {
    enable = true;
  };

  home.packages = with pkgs; [
    swayosd
    brightnessctl   # control de brillo
  ];
}
