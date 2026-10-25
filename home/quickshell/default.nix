# home/quickshell/ – Oberfläche mit Quickshell: die Leiste oben.
#
# Die Leiste ist in QML geschrieben (config/, Einstieg: shell.qml) und wird
# nach ~/.config/quickshell verlinkt. Farben und Schriften kommen als
# Theme.qml aus theme/default.nix dazu.
#
# Quickshell startet als Dienst mit der Sitzung. Nach Änderungen lädt es die
# Dateien selbst neu; hängt etwas: systemctl --user restart quickshell
# Fehler ansehen: journalctl --user -u quickshell

{ lib, theme, ... }:

let
  colors = lib.concatStrings (
    lib.mapAttrsToList (name: value: "    readonly property color ${name}: \"#${value}\"\n") theme.colors
  );
in
{
  programs.quickshell = {
    enable = true;
    systemd.enable = true;
  };

  xdg.configFile = {
    "quickshell" = {
      source = ./config;
      recursive = true; # einzelne Dateien verlinken, damit Theme.qml daneben passt
    };

    "quickshell/Theme.qml".text = ''
      // Automatisch erzeugt aus theme/default.nix – Änderungen bitte dort machen.
      pragma Singleton

      import Quickshell
      import QtQuick

      Singleton {
      ${colors}
          readonly property string fontUi: "${theme.fonts.ui.name}"
          readonly property string fontMono: "${theme.fonts.mono.name}"
          readonly property string fontIcons: "${theme.fonts.icons.name}"
      }
    '';
  };

  # WLAN/LAN-Icon im Tray (Klick: Netzwerke, VPN)
  services.network-manager-applet.enable = true;
  xsession.preferStatusNotifierItems = true; # Icon-Variante, die die Leiste anzeigen kann
}
