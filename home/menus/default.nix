# home/menus/ – Menüs. Alle nutzen fuzzel und sehen deshalb gleich aus:
#   Super+Leertaste  Programme              → launcher.nix
#   Super+Esc        Power-Menü             → power.nix
#   Super+.          Emojis                 → emoji.nix
#   Super+F1         Tastenkürzel-Übersicht → keybind-help.nix
# Der Zwischenablage-Verlauf (Super+V) steht in ../clipboard.nix.
#
# Die Menüs sind kleine Shell-Skripte. Die Tastenkürzel in
# hyprland/keybinds.lua rufen sie über ihren Namen auf (z. B. "power-menu").

{ ... }:

{
  imports = [
    ./launcher.nix
    ./power.nix
    ./emoji.nix
    ./keybind-help.nix
  ];
}
