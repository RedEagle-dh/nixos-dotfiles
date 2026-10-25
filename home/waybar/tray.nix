# home/waybar/tray.nix – Tray-Icons in der Leiste und das Netzwerk-Icon.

{ ... }:

{
  programs.waybar.settings.main.tray = {
    icon-size = 16;
    spacing = 10;
  };

  # WLAN/LAN-Icon (Rechtsklick: Netzwerke, VPN)
  services.network-manager-applet.enable = true;
  xsession.preferStatusNotifierItems = true; # Icon-Variante, die die Leiste anzeigen kann
}
