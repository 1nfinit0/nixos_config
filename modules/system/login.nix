{ config, pkgs, ... }:
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "uwsm start hyprland-uwsm.desktop";
        user = "tobi";
      };
    };
  };
}
