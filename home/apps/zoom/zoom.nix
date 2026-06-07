{ config, pkgs, ... }:
let
  zoomHyprland = pkgs.zoom-us.override {
    hyprlandXdgDesktopPortalSupport = true;
  };
in
{
  home.packages = [
    (pkgs.writeShellScriptBin "zoom" ''
      export ZOOM_WAYLAND=1
      export QT_QPA_PLATFORM=wayland
      exec ${zoomHyprland}/bin/zoom "$@"
    '')
  ];

  xdg.desktopEntries.Zoom = {
    name = "Zoom";
    exec = "zoom %U";
    icon = "zoom";
    terminal = false;
    mimeType = [
      "x-scheme-handler/zoommtg"
      "x-scheme-handler/zoomus"
      "x-scheme-handler/zoom"
      "x-scheme-handler/zmss"
    ];
    startupNotify = false;
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/zoommtg" = "Zoom.desktop";
      "x-scheme-handler/zoomus" = "Zoom.desktop";
      "x-scheme-handler/zoom"   = "Zoom.desktop";
      "x-scheme-handler/zmss"   = "Zoom.desktop";
    };
  };
}
