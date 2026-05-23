{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    nodejs
    typescript
    typescript-language-server
    pnpm
  ];

  home.sessionVariables = {
    PNPM_HOME = "$HOME/.local/share/pnpm";
  };

  home.sessionPath = [
    "$HOME/.local/share/pnpm"
  ];
}
