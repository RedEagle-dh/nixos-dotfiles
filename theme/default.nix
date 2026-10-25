# theme/default.nix – Das Aussehen des ganzen Systems an einer Stelle:
# Farbpalette, Schriften, Mauszeiger, Icons, GTK-Theme und Hintergrundbild.
#
# Genutzt von system/ (Bootmenü, Startbildschirm, Login-Bildschirm, Schriften)
# und home/. Dort steht es jedem Modul als Argument `theme` zur Verfügung.
# Die Palette färbt alles, was vor oder neben caelestia läuft: Bootmenü,
# Startbildschirm, Login, das erzeugte Hintergrundbild, Qt-Programme, Spotify,
# Prompt und fzf. Leiste, Fensterrahmen, Terminal, GTK-Programme und Menüs
# färbt caelestia nach seinem Farbschema (home/caelestia).

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

  # Offizielles NixOS-Logo (SVG), die zwei Blautöne ersetzt durch Iris und Rosé
  nixosLogo = pkgs.runCommand "nixos-logo.svg" { } ''
    sed -e 's/#415e9a/#${colors.iris}/I; s/#4a6baf/#${colors.iris}/I; s/#5277c3/#${colors.iris}/I' \
        -e 's/#699ad7/#${colors.rose}/I; s/#7eb1dd/#${colors.rose}/I; s/#7ebae4/#${colors.rose}/I' \
        ${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg > $out
  '';
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
      name = "JetBrainsMono Nerd Font"; # enthält auch die Icons für Menüs
      package = pkgs.nerd-fonts.jetbrains-mono;
      size = 12;
    };
  };

  cursor = {
    # Bibata Modern Ice: weiß, runde Ecken (Vorschau: github.com/ful1e5/Bibata_Cursor).
    # Weitere Varianten im selben Paket: Bibata-Modern-Classic (schwarz),
    # Bibata-Modern-Amber (gold), Bibata-Original-* (spitze Ecken)
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
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

  # Qt-Programme (Kvantum-Stil): Rosé Pine mit Iris-Akzent, passend zu GTK
  qt = {
    name = "rose-pine-iris";
    package = pkgs.rose-pine-kvantum;
  };

  inherit wallpaper bootWallpaper;

  # Bootmenü (rEFInd): Hintergrund, Icons, Auswahlrahmen, Schrift
  refind = import ./refind.nix {
    inherit pkgs colors nixosLogo;
    wallpaper = bootWallpaper;
  };

  # Startbildschirm (Plymouth): Hintergrundbild, Logo und Spinner
  plymouth = import ./plymouth.nix {
    inherit pkgs colors nixosLogo;
    wallpaper = bootWallpaper;
  };
}
