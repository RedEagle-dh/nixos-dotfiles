# system/hyprland.nix – Hyprland und die Dienste, die mit der Sitzung starten.
# Wie Hyprland aussieht und sich bedient, steht in home/hyprland/.

{ pkgs, ... }:

{
  # UWSM verbindet Hyprland sauber mit systemd (vom NixOS-Wiki empfohlen)
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true; # für ältere X11-Programme und viele Spiele
  };

  # Electron-/Chromium-Apps (VS Code, Discord, Obsidian …) nativ unter Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Sperrbildschirm + Idle-Daemon. Hier nur Passwortprüfung (PAM) und Dienst;
  # Aussehen und Zeiten: home/hyprland/lock.nix und idle.nix
  programs.hyprlock.enable = true; # aktiviert automatisch auch hypridle

  # hyprlock ist auch der Login (system/login.nix) – das Passwort dort
  # entsperrt deshalb auch den Schlüsselbund
  security.pam.services.hyprlock.enableGnomeKeyring = true;

  # Statusleiste als Dienst der Sitzung (Aussehen: home/waybar/)
  programs.waybar.enable = true;

  # Passwortabfragen grafischer Programme (z. B. Mounten, GParted)
  systemd.packages = [ pkgs.hyprpolkitagent ];
  systemd.user.services.hyprpolkitagent.wantedBy = [ "graphical-session.target" ];
}
