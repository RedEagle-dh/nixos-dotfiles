# system/programs.nix – Programme, die systemweit installiert sind.
#
# Hierher gehört nur, was ein NixOS-Modul braucht oder für alle Benutzer da
# sein soll. Persönliche Programme stehen in home/apps.nix.

{ pkgs, ... }:

{
  programs.firefox.enable = true;
  programs.nix-ld.enable = true; # vorkompilierte Fremd-Binaries lauffähig machen

  # Dateimanager Nautilus mit "In Kitty öffnen" im Rechtsklickmenü
  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "kitty";
  };

  environment.systemPackages = with pkgs; [
    nautilus # Dateimanager (Super+E)

    # Basics – auch ohne Home Manager und für root verfügbar
    git
    vim
    btop
    wget
    curl
    unzip
    bun
  ];
}
