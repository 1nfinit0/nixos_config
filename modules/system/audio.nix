{ config, pkgs, ... }:
{
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  environment.etc."wireplumber/main.lua.d/51-headset-mic.lua".text = ''
    alsa_monitor.rules = alsa_monitor.rules or {}
    table.insert(alsa_monitor.rules, {
      matches = {
        {
          { "node.name", "equals", "alsa_input.pci-0000_03_00.6.analog-stereo" },
        },
      },
      apply_properties = {
        ["device.profile"] = "analog-input-headset-mic",
      },
    })
  '';
}
