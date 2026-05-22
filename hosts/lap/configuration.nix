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

	programs.hyprland = {
  		enable = true;
		xwayland.enable = true;
		withUWSM = true;
	};

  system.stateVersion = "25.11";
}
