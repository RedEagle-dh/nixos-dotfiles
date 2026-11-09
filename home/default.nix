# Gemeinsam für Desktop (NixOS) und MacBook (nix-darwin) – möglichst alles hier.
# Nur Linux: home/linux.nix, nur Mac: home/darwin/. Innerhalb gemeinsamer Module unterscheidet
# pkgs.stdenv.hostPlatform.isDarwin bzw. isLinux. Programme kommen auf dem Mac aus Homebrew
# (home/packages.nix, home/darwin/brew.nix), Nix schreibt dort nur die Konfiguration
{ pkgs, user, ... }:

{
  imports = [
    ./packages.nix
    ./apps.nix
    ./browsers.nix
    ./zed.nix
    ./discord.nix
    ./spotify.nix
    ./terminal
    ./agent-skills.nix
  ];

  _module.args.theme = import ../theme { inherit pkgs; };

  home.username = user;

  # Nicht ändern – bleibt auf dem Stand der Ersteinrichtung
  home.stateVersion = "26.05";
}
