{ config, pkgs, ... }:

{
  programs.kitty = {
    enable = true;

    font = {
      name = "Hack Nerd Font Mono";
      size = 14;
    };

    settings = {
      confirm_os_window_close = 0;
    };

    extraConfig = ''
      include ${./color.ini}

      # Ctrl+Tab/Ctrl+Shift+Tab pasan a Neovim (cambia de pestaña ahí) --
      # sin una segunda definición debajo que lo vuelva a pisar.
      map ctrl+tab send_text all \x1b[9;5u
      map ctrl+shift+tab send_text all \x1b[9;6u

      # pestañas de KITTY (ya no en ctrl+tab)
      map ctrl+page_up   previous_tab
      map ctrl+page_down next_tab

      # libera Ctrl+Shift+Izq/Der para que le llegue a las apps
      # (Neovim lo usa para seleccionar por palabra)
      map ctrl+shift+left no_op
      map ctrl+shift+right no_op
    '';
 
   };
}
