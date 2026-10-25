# system/ – NixOS-Module, eines pro Thema.
#
# Neues Thema? Datei anlegen, hier eintragen, `git add` – fertig.
# Jedes Modul bekommt automatisch `user` (aus flake.nix) und `theme`
# (Farben, Schriften, Hintergrundbild aus ../theme) als Argument.

{ pkgs, ... }:

{
  imports = [
    ./boot.nix # Bootloader
    ./nix.nix # Nix selbst: Flakes, Aufräumen, nh
    ./locale.nix # Sprache, Zeitzone, Tastatur
    ./users.nix # Benutzerkonto & Shell
    ./nvidia.nix # Grafiktreiber RTX 4080
    ./hyprland.nix # Hyprland, Sperrbildschirm, Leiste, Polkit
    ./login.nix # Login-Bildschirm (SDDM)
    ./sound.nix # PipeWire
    ./services.nix # Netzwerk, Schlüsselbund, USB-Sticks …
    ./fonts.nix # Schriften
    ./programs.nix # systemweite Programme
    ./1password.nix # 1Password mit Browser- & System-Anbindung
    ./docker.nix # Docker mit GPU
    ./storage.nix # Swap & Btrfs-Pflege
  ];

  _module.args.theme = import ../theme { inherit pkgs; };
}
