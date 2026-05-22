{ config, pkgs, ... }:

{
  home.packages = with pkgs; [

    # -----------------------------
    # TERMINAL / SHELL 
    # -----------------------------
    kitty
    fastfetch
    eza
    bat
    fd
    ripgrep
    fzf
    zoxide

    # -----------------------------
    # NETWORKING
    # -----------------------------
    networkmanagerapplet
    wget
    curl

    # -----------------------------
    # DEVELOPMENT / CLI TOOLS
    # -----------------------------
    git
    unzip
  ];
}
