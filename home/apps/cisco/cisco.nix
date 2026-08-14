{ pkgs, ... }:
{
  home.packages = [
    (pkgs.ciscoPacketTracer9.override {
      packetTracerSource = ../../../assets/cisco-packet-tracer/CiscoPacketTracer_901_Ubuntu_64bit.deb;
    })
  ];
}
