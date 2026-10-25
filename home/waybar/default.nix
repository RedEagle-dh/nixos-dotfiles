# home/waybar/ – Statusleiste oben.
#
# Drei schwebende "Inseln":
#   links   NixOS-Logo · Arbeitsflächen · aktives Fenster   → workspaces.nix
#   Mitte   Datum & Uhrzeit                                   → clock.nix
#   rechts  CPU · RAM · GPU                                   → system-stats.nix
#           Lautstärke · Benachrichtigungen · Power           → controls.nix
#           Tray-Icons (z. B. Netzwerk)                       → tray.nix
#
# Hier: Größe, Position, Reihenfolge der Module und das Aussehen (style.css).
# Die Leiste startet als systemd-Dienst mit der Sitzung (system/hyprland.nix).

{ lib, theme, ... }:

let
  # Farben und Schriften aus theme/ als CSS vor style.css
  themeCss =
    lib.concatStrings (
      lib.mapAttrsToList (name: value: "@define-color ${name} #${value};\n") theme.colors
    )
    + ''
      * { font-family: "${theme.fonts.ui.name}", "${theme.fonts.mono.name}"; }
    '';
in
{
  imports = [
    ./workspaces.nix
    ./clock.nix
    ./system-stats.nix
    ./controls.nix
    ./tray.nix
  ];

  programs.waybar = {
    enable = true;
    systemd.enable = false; # der Dienst kommt aus system/hyprland.nix

    style = themeCss + builtins.readFile ./style.css;

    settings.main = {
      layer = "top";
      position = "top";
      height = 34;
      margin-top = 10;
      margin-left = 14;
      margin-right = 14;
      spacing = 0;

      modules-left = [
        "custom/logo"
        "ext/workspaces"
        "hyprland/window"
      ];
      modules-center = [ "clock" ];
      modules-right = [
        "cpu"
        "memory"
        "custom/gpu"
        "pulseaudio"
        "tray"
        "custom/notifications"
        "custom/power"
      ];
    };
  };
}
