{ config, pkgs, ... }:

{
  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;

        modules-left = [
          "hyprland/workspaces"
        ];

        modules-center = [
          "clock"
        ];

        modules-right = [
          "network"
          "battery"
          "pulseaudio"
          "tray"
        ];

        "hyprland/workspaces" = {
          format = "{id}";
          on-click = "activate";
        };

        clock = {
          format = "{:%H:%M  %d/%m}";
          tooltip-format = "{:%A, %d de %B de %Y}";
        };

        network = {
          format-wifi = "  {essid}";
          format-ethernet = "󰈀 Ethernet";
          format-disconnected = "󰖪 Offline";
          tooltip = true;
        };

        battery = {
          format = "{capacity}% {icon}";
          format-charging = "󰂄 {capacity}%";
          format-icons = [
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
        };

        pulseaudio = {
          format = "{volume}% ";
          format-muted = "󰖁";
        };

        tray = {
          spacing = 10;
        };
      };
    };

    style = ''
      * {
        font-family: JetBrainsMono Nerd Font;
        font-size: 13px;
      }

      window#waybar {
        background: rgba(20,20,20,0.9);
        color: #ffffff;
      }

      #workspaces button {
        padding: 0 8px;
        color: #888;
      }

      #workspaces button.active {
        color: #ffffff;
      }

      #clock,
      #battery,
      #network,
      #pulseaudio {
        padding: 0 10px;
      }
    '';
  };
}
