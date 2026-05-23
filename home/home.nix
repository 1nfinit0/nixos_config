{ config, pkgs, ... }:
{
	imports = [
		./development/git/git.nix
		./development/python/python.nix
		./development/java/java.nix
		./development/netbeans/netbeans.nix
		./development/pgadmin/pgadmin.nix

		./apps/browser/browser.nix
		./apps/rofi/rofi.nix
		./apps/kitty/kitty.nix
		./apps/vscode/vscode.nix
		./apps/latex/latex.nix

		./desktop/hyprland.nix

		./shell/zsh.nix
		./fonts/fonts.nix

		./packages.nix
  ];

	home.sessionVariables = {
  CLIPHIST_MAX_ITEMS = "50";
  };

  home.stateVersion = "25.11";
}
