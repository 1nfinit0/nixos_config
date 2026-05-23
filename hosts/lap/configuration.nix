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

  networking.hostName = "nixos";
  security.pam.services.login.enableGnomeKeyring = true;

	services.postgresql = {
  		enable = true;
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

	programs.hyprland = {
  		enable = true;
		xwayland.enable = true;
		withUWSM = true;
	};

  system.stateVersion = "25.11";
}
