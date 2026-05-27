{ pkgs, ... }:
{
  systemd.user.services.battery-alert = {
    Unit.Description = "Battery low alert";
    Service = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "battery-alert" ''
        BAT=$(cat /sys/class/power_supply/BAT0/capacity)
        STATUS=$(cat /sys/class/power_supply/BAT0/status)
        if [ "$BAT" -le 10 ] && [ "$STATUS" = "Discharging" ]; then
          ${pkgs.libnotify}/bin/notify-send -u critical "🔋 Batería baja" "$BAT% — conecta el cargador"
        fi
      '';
    };
  };

  systemd.user.timers.battery-alert = {
    Unit.Description = "Check battery every 5 minutes";
    Timer = {
      OnBootSec = "1min";
      OnUnitActiveSec = "5min";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
