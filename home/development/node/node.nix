{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    nodejs
    nodePackages.typescript
    nodePackages.typescript-language-server
    nodePackages.pnpm
  ];

  home.sessionVariables = {
    NODE_PATH = "$HOME/.npm-global/lib/node_modules";
  };

  home.sessionPath = [
    "$HOME/.npm-global/bin"
  ];
}
