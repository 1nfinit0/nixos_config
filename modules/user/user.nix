{ config, pkgs, ... }:

{
  users.users.tobi = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
  };
}
