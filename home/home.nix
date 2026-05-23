{ config, pkgs, ... }:
{
	imports = [
		./development/git/git.nix
		./development/python/python.nix

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
