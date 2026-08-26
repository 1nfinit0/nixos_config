{ config, lib, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/system.nix
    ../../modules/system/boot.nix
    ../../modules/system/network.nix
    ../../modules/system/audio.nix
    ../../modules/system/login.nix
    ../../modules/user/user.nix
    ../../modules/user/shell.nix
  ];
  # Hostname
  networking.hostName = "nixos";
  # Unfree packages (ej. Cisco Packet Tracer)
  nixpkgs.config.allowUnfree = true;
  # Keyring
  security.pam.services.login.enableGnomeKeyring = true;
  # PostgreSQL
  services.postgresql = {
    enable = false;
    ensureDatabases = [ "tobi" ];
    ensureUsers = [
      {
        name = "tobi";
        ensureDBOwnership = true;
      }
    ];
    authentication = lib.mkOverride 10 ''
      local all all trust
      host  all all 127.0.0.1/32 trust
      host  all all ::1/128      trust
    '';
  };
  # Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };
  # Logind
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchDocked = "ignore";
    HandlePowerKey = "ignore";
    HandlePowerKeyLongPress = "ignore";
  };
  system.stateVersion = "25.11";
}
