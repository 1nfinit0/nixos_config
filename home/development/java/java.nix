{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    jdk
  ];

  home.sessionVariables = {
    JAVA_HOME = "${pkgs.jdk}/lib/openjdk";
  };

  home.sessionPath = [
    "${pkgs.jdk}/lib/openjdk/bin"
  ];
}
