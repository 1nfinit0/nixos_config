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
          "clock"
        ];

        modules-center = [
          "hyprland/workspaces"
        ];

        modules-right = [
          "network"
          "battery"
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
          format-wifi = "";
          format-ethernet = "";
          format-disconnected = "󰖪";
          tooltip = true;
        };

        battery = {
          format = "{icon}";
          format-charging = "󰂄";
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
