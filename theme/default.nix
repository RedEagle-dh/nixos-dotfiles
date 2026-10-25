# theme/default.nix – Das Aussehen des ganzen Systems an einer Stelle:
# Farbpalette, Schriften, Mauszeiger, Icons, GTK-Theme und Hintergrundbild.
#
# Genutzt von system/ (Bootmenü, Startbildschirm, Login-Bildschirm, Schriften)
# und home/. Dort steht es jedem Modul als Argument `theme` zur Verfügung.
# Wer hier eine Farbe ändert, ändert sie überall: Fensterrahmen, Leiste,
# Starter, Benachrichtigungen, Terminal, Sperrbildschirm und Hintergrund.

{ pkgs }:

let
  # Farbpalette "Rosé Pine" (https://rosepinetheme.com) – Hex-Werte ohne "#"
  colors = {
    base = "191724"; # Grundfläche
    surface = "1f1d2e"; # Leisten, Menüs
    overlay = "26233a"; # erhöhte Flächen, inaktive Rahmen
    muted = "6e6a86"; # deaktivierter Text
    subtle = "908caa"; # Nebentext
    text = "e0def4"; # Haupttext
    love = "eb6f92"; # Fehler, Dringendes
    gold = "f6c177"; # Warnungen
    rose = "ebbcba"; # zweite Akzentfarbe
    pine = "31748f";
    foam = "9ccfd8";
    iris = "c4a7e7"; # Hauptakzent
    highlightLow = "21202e";
    highlightMed = "403d52";
    highlightHigh = "524f67";
  };

  wallpaper = import ./wallpaper.nix { inherit pkgs colors; };

  # Dasselbe Bild in Monitorauflösung für Bootmenü und Startbildschirm. Beide
  # laufen vor dem Grafiktreiber und müssen das Bild selbst laden und
  # skalieren – passend gerendert geht das schneller und sieht schärfer aus.
  bootWallpaper = import ./wallpaper.nix {
    inherit pkgs colors;
    width = 2560;
    height = 1440;
  };
in
{
  inherit colors;

  fonts = {
    ui = {
      name = "Inter";
      package = pkgs.inter;
      size = 11;
    };
    mono = {
      name = "JetBrainsMono Nerd Font"; # enthält auch die Icons für Leiste & Menüs
      package = pkgs.nerd-fonts.jetbrains-mono;
      size = 12;
    };
  };

  cursor = {
    name = "BreezeX-RosePine-Linux"; # klassischer Zeiger für Programme
    package = pkgs.rose-pine-cursor;
    hyprcursor = "rose-pine-hyprcursor"; # gestochen scharfe Variante für Hyprland
    hyprcursorPackage = pkgs.rose-pine-hyprcursor;
    size = 24;
  };

  icons = {
    name = "Papirus-Dark";
    package = pkgs.papirus-icon-theme.override { color = "violet"; }; # Ordner in Akzentfarbe
  };

  # GTK-3-Programme sehen damit aus wie moderne GTK-4/libadwaita-Programme
  gtk = {
    name = "adw-gtk3-dark";
    package = pkgs.adw-gtk3;
  };

  inherit wallpaper bootWallpaper;

  # Startbildschirm (Plymouth): Hintergrundbild, Logo und Spinner
  plymouth = import ./plymouth.nix {
    inherit pkgs colors;
    wallpaper = bootWallpaper;
  };
}
