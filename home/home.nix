{ config, pkgs, ... }:
{
	imports = [
		./development/git/git.nix
		./development/python/python.nix

		./apps/browser/browser.nix
		./apps/rofi/rofi.nix
		./apps/kitty/kitty.nix
		./apps/vscode/vscode.nix

		./desktop/hyprland.nix

		./shell/zsh.nix
		./fonts/fonts.nix

		./packages.nix
  ];
  home.stateVersion = "25.11";
}
