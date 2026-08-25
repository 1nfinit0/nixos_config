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
    glow

    # -----------------------------
    # NETWORKING
    # -----------------------------
    networkmanagerapplet
    wget
    curl

    # -----------------------------
    # DEVELOPMENT / CLI TOOLS
    # -----------------------------
    grimblast
    cliphist
    wl-clipboard
    unzip
    zip
    unrar
  ];
}
