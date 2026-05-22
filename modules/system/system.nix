{ config, pkgs, ... }:

{
  # -----------------------------
  # SYSTEM BASE SETTINGS
  # -----------------------------

  time.timeZone = "America/Lima";
  i18n.defaultLocale = "en_US.UTF-8";

  console.keyMap = "la-latin1";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
	
  programs.nix-ld.enable = true;

  # -----------------------------
  # HARDWARE BASICS
  # -----------------------------
  hardware.graphics.enable = true;
  hardware.enableRedistributableFirmware = true;

  # -----------------------------
  # XDG PORTAL
  # -----------------------------
xdg.portal = {
  enable = true;

  config.common.default = "*";

  extraPortals = with pkgs; [
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
  ];
};
}
