# system/login.nix – Anmeldung: Autologin in Hyprland, hyprlock als Login.
#
# Nach dem Startbildschirm startet Hyprland direkt und sperrt sich sofort
# (home/hyprland/lock.nix). Das Passwort gibt man also im Sperrbildschirm ein –
# danach ist der Desktop sofort da, ohne zweiten Bildwechsel. Dabei wird auch
# der Schlüsselbund entsperrt (system/hyprland.nix).
#
# Nach dem Abmelden erscheint ein schlichter Text-Login (tuigreet). Auf
# Strg+Alt+F2–F6 gibt es weiterhin Text-Logins zum Reparieren.

{
  config,
  lib,
  pkgs,
  user,
  ...
}:

let
  # Wie die Desktop-Sitzung "Hyprland (uwsm-managed)" Hyprland startet
  hyprland = "${lib.getExe config.programs.uwsm.package} start -e -D Hyprland hyprland.desktop";
in
{
  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings = {
      # Einmal pro Systemstart: ohne Passwort anmelden
      initial_session = {
        inherit user;
        command = hyprland;
      };
      # Nach dem Abmelden
      default_session.command = lib.concatStringsSep " " [
        (lib.getExe pkgs.tuigreet)
        "--time"
        "--remember"
        "--asterisks"
        "--greeting 'Willkommen'"
        "--cmd '${hyprland}'"
      ];
    };
  };
}
