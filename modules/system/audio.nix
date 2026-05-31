# modules/system/audio.nix
{ config, pkgs, ... }:

let
  micToggle = pkgs.writeShellScriptBin "mic-toggle" ''
    CURRENT=$(${pkgs.pulseaudio}/bin/pactl get-source-port alsa_input.pci-0000_03_00.6.analog-stereo)
    if [ "$CURRENT" = "analog-input-headset-mic" ]; then
      ${pkgs.pulseaudio}/bin/pactl set-source-port alsa_input.pci-0000_03_00.6.analog-stereo analog-input-internal-mic
    else
      ${pkgs.pulseaudio}/bin/pactl set-source-port alsa_input.pci-0000_03_00.6.analog-stereo analog-input-headset-mic
    fi
  '';
in
{
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  environment.systemPackages = with pkgs; [ pulseaudio micToggle ];
}
