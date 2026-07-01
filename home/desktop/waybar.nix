{ config, pkgs, ... }:

{
  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 32;

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
          format = "●";
          on-click = "activate";
          show-special = false;
          all-outputs = false;
          # persistent-workspaces garantiza que siempre se vean los 4 dots
          # sin importar cuáles tengan ventanas abiertas.
          # Agrega o quita entradas según cuántos workspaces quieras fijar.
          persistent-workspaces = {
            "1" = [];
            "2" = [];
            "3" = [];
            "4" = [];
          };
        };

        clock = {
          format = "{:%H:%M  %d/%m}";
          tooltip-format = "{:%A, %d de %B de %Y}";
          on-click = "kitty --class calendar-popup -e sh -c 'cal -3; read -n 1'";
        };

        network = {
          format-wifi = "󰖩";
          format-ethernet = "󰈀";
          format-disconnected = "󰖪";
          tooltip-format-wifi = "{essid} ({signalStrength}%)";
          tooltip-format-ethernet = "{ifname}";
          tooltip-format-disconnected = "Sin conexión";
          tooltip = true;
          on-click = "kitty --title 'nmtui' -e nmtui";
        };

        battery = {
          format = "{capacity}% {icon}";
          format-charging = "{capacity}% 󰂄";
          format-plugged = "{capacity}% 󰚥";
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
          tooltip-format = "{timeTo} — {power:.1f}W";
          states = {
            warning = 30;
            critical = 15;
          };
        };
      };
    };

    style = ''
      /* ── Tokyo Night Dark ── */
      * {
        font-family: "Hack Nerd Font", monospace;
        font-size: 13px;
        border: none;
        border-radius: 0;
        min-height: 0;
      }

      /* ── Barra principal ── */
      window#waybar {
        background: #1a1b26;
        color: #c0caf5;
      }

      /* ── Módulos base ── */
      #clock,
      #battery,
      #network {
        padding: 0 7px;
        background: transparent;
        transition: color 0.2s;
      }

      /* ── Reloj ── */
      #clock {
        color: #9ece6a;
        font-weight: 600;
        letter-spacing: 0.03em;
      }

      /* ── Workspaces ── */
      #workspaces {
        background: transparent;
      }

      #workspaces button {
        padding: 0 5px;
        color: #3b4261;        /* dot inactivo: gris azulado oscuro */
        background: transparent;
        font-size: 16px;
        transition: color 0.15s;
        box-shadow: none;
        text-shadow: none;
      }

      #workspaces button:hover {
        background: transparent;
        color: #565f89;
        box-shadow: none;
      }

      #workspaces button.active {
        color: #7aa2f7;        /* dot activo: azul Tokyo Night */
        font-size: 20px;
      }

      #workspaces button.urgent {
        color: #f7768e;
      }

      /* ── Red ── */
      #network {
        color: #7dcfff;
      }

      #network.disconnected {
        color: #e0af68;
      }

      /* ── Batería: desconectada de la corriente ── */
      #battery {
        color: #9ece6a;
      }

      /* ── Batería: enchufada y cargando ── */
      #battery.charging {
        color: #7aa2f7;
      }

      /* ── Batería: enchufada y llena (format-plugged) ── */
      #battery.plugged {
        color: #9ece6a;
      }

      /* ── Batería: nivel bajo ── */
      #battery.warning {
        color: #e0af68;
      }

      /* ── Batería: nivel crítico ── */
      #battery.critical {
        color: #f7768e;
        animation: blink 1s step-start infinite;
      }

      @keyframes blink {
        50% { opacity: 0.4; }
      }
    '';
  };
}
