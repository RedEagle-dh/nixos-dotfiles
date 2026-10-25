# home/menus/fuzzel.nix – Aussehen von fuzzel: Zwischenablage, Emojis, Kürzel-Übersicht.
# Als Programm-Starter dient caelestia; fuzzel ginge aber auch (Befehl: fuzzel).
#
# Farben: aus dem aktuellen Farbschema von caelestia, wie GTK. caelestia füllt
# die Vorlage unten bei jedem Farbwechsel aus (nach ~/.local/state/caelestia/
# theme/fuzzel.ini), fuzzel liest sie bei jedem Öffnen – neue Farben gelten sofort.

{ config, theme, ... }:

let
  m3 = name: "{{ ${name}.hex }}"; # Platzhalter für eine Farbe des Schemas
in
{
  xdg.configFile."caelestia/templates/fuzzel.ini".text = ''
    [colors]
    background=${m3 "surface"}eb
    text=${m3 "onSurface"}ff
    prompt=${m3 "primary"}ff
    placeholder=${m3 "outline"}ff
    input=${m3 "onSurface"}ff
    match=${m3 "tertiary"}ff
    selection=${m3 "surfaceContainerHighest"}ff
    selection-text=${m3 "onSurface"}ff
    selection-match=${m3 "tertiary"}ff
    counter=${m3 "outline"}ff
    border=${m3 "primary"}cc
  '';

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        include = "${config.xdg.stateHome}/caelestia/theme/fuzzel.ini"; # Farben
        font = "${theme.fonts.ui.name}:size=13,${theme.fonts.mono.name}:size=13";
        prompt = ''"  "'';
        placeholder = ''"Programm suchen …"'';
        icon-theme = theme.icons.name;
        terminal = "kitty";
        layer = "overlay";
        width = 42;
        lines = 9;
        horizontal-pad = 24;
        vertical-pad = 18;
        inner-pad = 12;
        line-height = 28;
        image-size-ratio = 0.5;
        show-actions = false;
      };
      border = {
        width = 2;
        radius = 16;
        selection-radius = 10;
      };
    };
  };
}
