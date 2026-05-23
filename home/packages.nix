{ config, pkgs, ... }:

{
  home.packages = with pkgs; [

    # -----------------------------
    # TERMINAL / SHELL
    # -----------------------------
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
    wl-clipboard
    unzip
  ];
}
