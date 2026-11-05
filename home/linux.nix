# Nur auf dem NixOS-Desktop: Hyprland-Oberfläche und was dazugehört
{ user, ... }:

{
  imports = [
    ./appearance.nix
    ./xdg.nix
    ./hyprland
    ./caelestia
    ./menus
    ./clipboard.nix
    ./screenshots.nix
    ./audio.nix
    ./storage.nix
  ];

  home.homeDirectory = "/home/${user}";
}
