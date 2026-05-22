{ config, pkgs, ... }:

{
  programs.kitty = {
    enable = true;

    font = {
      name = "Hack Nerd Font Mono";
      size = 13;
    };

    settings = {
      confirm_os_window_close = 0;
    };

    extraConfig = ''
      include ${./color.ini}
    '';
  };
}
