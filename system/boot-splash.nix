# system/boot-splash.nix – Startbildschirm statt Textmeldungen.
#
# Zwischen Bootmenü und Login-Bildschirm läuft keine Textflut mehr durch,
# sondern Plymouth zeigt Hintergrundbild, Logo und Spinner (theme/plymouth.nix).
# Beim Herunterfahren ebenso.
#
# Bootet etwas nicht und man will die Meldungen sehen: im Startbildschirm
# Esc drücken – oder hinterher `journalctl -b -1` (letzter Start).

{ config, theme, ... }:

{
  boot.plymouth = {
    enable = true;
    theme = theme.plymouth.name;
    themePackages = [ theme.plymouth ];
    font = theme.plymouth.fontFile;
  };

  # Beim Beenden das letzte Bild stehen lassen, bis der Login-Bildschirm
  # übernimmt – sonst ist es dazwischen kurz schwarz
  systemd.services.plymouth-quit.serviceConfig.ExecStart = [
    "" # Original-Befehl ersetzen statt ergänzen
    "-${config.boot.plymouth.package}/bin/plymouth quit --retain-splash"
  ];

  # Meldungen von Kernel und systemd nur noch bei echten Fehlern
  # ("splash" für Plymouth setzt NixOS selbst)
  boot.consoleLogLevel = 3;
  boot.kernelParams = [
    "quiet"
    "udev.log_level=3"
    "rd.udev.log_level=3"
    "systemd.show_status=auto"
    "rd.systemd.show_status=auto"
  ];
}
