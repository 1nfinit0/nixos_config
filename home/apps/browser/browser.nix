{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    (brave.override {
      commandLineArgs = "--disable-pinch";
    })
  ];
}
