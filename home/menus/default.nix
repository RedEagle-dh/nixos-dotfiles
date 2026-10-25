# home/menus/ – Menüs mit fuzzel; sie sehen deshalb alle gleich aus:
#   fuzzel.nix        Aussehen von fuzzel (gilt für alle Menüs)
#   Super+.           Emojis                 → emoji.nix
#   Super+F1          Tastenkürzel-Übersicht → keybind-help.nix
# Der Zwischenablage-Verlauf (Super+V) steht in ../clipboard.nix; den
# Programm-Starter (Super antippen) bringt caelestia mit.
#
# Die Menüs sind kleine Shell-Skripte. Die Tastenkürzel in
# hyprland/keybinds.lua rufen sie über ihren Namen auf (z. B. "emoji-menu").

{ ... }:

{
  imports = [
    ./fuzzel.nix
    ./emoji.nix
    ./keybind-help.nix
  ];
}
