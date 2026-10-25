# system/locale.nix – Sprache, Zeitzone, Tastatur.

{ ... }:

{
  time.timeZone = "Europe/Berlin";

  # Gilt für alles: Sprache, Datum, Zahlen, Währung, Papierformat …
  i18n.defaultLocale = "de_DE.UTF-8";

  # Deutsches Tastaturlayout für Login-Bildschirm und Text-Konsolen.
  # Hyprland hat ein eigenes: home/hyprland/hyprland.lua (kb_layout).
  services.xserver.xkb.layout = "de";
  console.keyMap = "de";
}
