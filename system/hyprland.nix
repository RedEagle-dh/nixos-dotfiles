# system/hyprland.nix – Hyprland und die Dienste, die mit der Sitzung starten.
# Wie Hyprland aussieht und sich bedient, steht in home/hyprland/.

{
  config,
  lib,
  pkgs,
  user,
  ...
}:

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

  # Passwortabfragen grafischer Programme (z. B. Mounten, GParted, 1Password).
  # Soteria ist GTK4/libadwaita und übernimmt deshalb die caelestia-Farben aus
  # home/caelestia/gtk-css.nix. Schweben statt kacheln: home/hyprland/hyprland.lua
  security.soteria.enable = true;

  # Soteria braucht die Nummer der Login-Sitzung (XDG_SESSION_ID). uwsm gibt sie
  # nicht an systemd-Dienste weiter → beim Start bei logind nachfragen.
  systemd.user.services.polkit-soteria.serviceConfig.ExecStart = lib.mkForce (
    pkgs.writeShellScript "soteria-session" ''
      export XDG_SESSION_ID=$(${pkgs.systemd}/bin/loginctl show-user "$USER" -p Display --value)
      exec ${lib.getExe config.security.soteria.package}
    ''
  );

  # Startet polkitd neu (passiert bei manchem nhs), meldet sich der Agent nicht
  # von selbst wieder an. Ohne Agent schlägt das Entsperren von 1Password mit
  # dem Systempasswort sofort fehl → es fragt nach dem 1Password-Passwort.
  # Darum den laufenden Agent danach mit neu starten.
  systemd.services.polkit.serviceConfig.ExecStartPost = [
    "-${pkgs.systemd}/bin/systemctl --user --machine=${user}@ --no-block try-restart polkit-soteria.service"
  ];
}
