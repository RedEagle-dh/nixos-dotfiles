# system/services.nix – kleine Dienste, die ein Desktop braucht.

{ ... }:

{
  networking.networkmanager.enable = true; # LAN/WLAN (Icon in der Leiste)
  security.polkit.enable = true; # erlaubt Programmen, nach Rechten zu fragen

  services.gnome.gnome-keyring.enable = true; # Passwortspeicher (Browser, VS Code, WLAN)
  security.pam.services.login.enableGnomeKeyring = true; # beim Login entsperren

  programs.dconf.enable = true; # GTK-Einstellungen
  services.udisks2.enable = true; # USB-Sticks einhängen
  services.gvfs.enable = true; # Papierkorb, Netzlaufwerke im Dateimanager
  services.gnome.sushi.enable = true; # Leertaste im Dateimanager = Schnellvorschau

  # hardware.bluetooth.enable = true; # falls dein PC Bluetooth hat
}
