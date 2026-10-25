# home/audio.nix – Lautstärke-Einstellungen und Medientasten.
# Die Lautstärke-Anzeige beim Ändern kommt von caelestia.

{ pkgs, ... }:

{
  home.packages = [
    pkgs.pavucontrol # Lautstärke & Audiogeräte (Strg+Alt+V)
    pkgs.playerctl # Medientasten
    pkgs.libnotify # notify-send (Benachrichtigungen aus Skripten)
  ];
}
