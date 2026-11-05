# Wie system/1password.nix. 1Password verlangt die App unter /Applications und `op` unter
# /usr/local/bin, sonst keine Anbindung an Browser und CLI – die Module kopieren beides dorthin.
# SSH-Agent und Git-Signatur brauchen die laufende App: in 1Password "Beim Anmelden starten" einschalten
{ lib, pkgs, ... }:

let
  # nixpkgs hinkt bei 1Password oft hinterher. Lief einmal eine neuere Version, verweigert eine ältere
  # die Daten ("Ihre gespeicherten Daten scheinen neuer zu sein …"). Greift nur, solange nixpkgs älter
  # ist – danach wirkungslos und entfernbar. Neuere Version vorziehen: version und Hash anpassen,
  #   nix store prefetch-file https://downloads.1password.com/mac/1Password-<version>-aarch64.zip
  version = "8.12.44";
  gui =
    if lib.versionOlder pkgs._1password-gui.version version then
      pkgs._1password-gui.overrideAttrs {
        inherit version;
        src = pkgs.fetchurl {
          url = "https://downloads.1password.com/mac/1Password-${version}-aarch64.zip";
          hash = "sha256-mySxRkv0N4DwThr6+LB0LyFjypTbiwYgBZ56BaJJj6E=";
        };
      }
    else
      pkgs._1password-gui;
in
{
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    package = gui;
  };
}
