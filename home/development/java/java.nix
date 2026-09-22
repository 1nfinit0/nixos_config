{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    jdk
    ant

    (writeShellScriptBin "create-java-ant"
      (builtins.readFile ./create-java-ant.sh))
  ];

  home.sessionVariables = {
    JAVA_HOME = "${pkgs.jdk}/lib/openjdk";
  };

  home.sessionPath = [
    "${pkgs.jdk}/lib/openjdk/bin"
  ];
}
