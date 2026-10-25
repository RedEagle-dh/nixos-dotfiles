# configuration.nix – dieser Rechner.
#
# Hier steht nur, was genau diese Maschine betrifft. Alles Allgemeine
# (Sound, Login, Programme …) liegt als eigenes Modul in system/.

{ ... }:

{
  imports = [
    ./hardware-configuration.nix # von nixos-generate-config erzeugt, nicht von Hand ändern
    ./system
  ];

  networking.hostName = "nixos"; # muss zu nixosConfigurations.nixos in flake.nix passen

  # Die NixOS-Version der Erstinstallation. Hält Daten älterer Dienste
  # kompatibel – NIE ändern, auch nicht nach Updates oder dem Wechsel auf
  # nixos-unstable. Welche Pakete du bekommst, legt allein flake.nix fest.
  system.stateVersion = "26.05";
}
