{ pkgs, user, ... }:

{
  imports = [
    ./apps.nix
    ./discord.nix
    ./spotify.nix
    ./appearance.nix
    ./xdg.nix
    ./hyprland
    ./caelestia
    ./menus
    ./clipboard.nix
    ./screenshots.nix
    ./audio.nix
    ./storage.nix
    ./terminal
  ];

  _module.args.theme = import ../theme { inherit pkgs; };

  home.username = user;
  home.homeDirectory = "/home/${user}";

  # Nicht ändern – bleibt auf dem Stand der Ersteinrichtung
  home.stateVersion = "26.05";
}
