# Gemeinsam für Desktop (NixOS) und MacBook (nix-darwin) – möglichst alles hier.
# Nur Linux: home/linux.nix, nur Mac: home/darwin/. Innerhalb gemeinsamer Module unterscheidet
# pkgs.stdenv.hostPlatform.isDarwin bzw. isLinux
{ pkgs, user, ... }:

{
  imports = [
    ./apps.nix
    ./browsers.nix
    ./zed.nix
    ./discord.nix
    ./spotify.nix
    ./terminal
    ./neovim
    ./agent-skills.nix
  ];

  _module.args.theme = import ../theme { inherit pkgs; };

  home.username = user;

  # Nicht ändern – bleibt auf dem Stand der Ersteinrichtung
  home.stateVersion = "26.05";
}
