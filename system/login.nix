{
  config,
  lib,
  pkgs,
  user,
  ...
}:

let
  # uwsm schreibt sonst Statusmeldungen auf den Bildschirm (stehen auch im Journal)
  hyprland = toString (
    pkgs.writeShellScript "hyprland-session" ''
      exec ${lib.getExe config.programs.uwsm.package} start -e -D Hyprland hyprland.desktop > /dev/null 2>&1
    ''
  );
in
{
  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings = {
      initial_session = {
        inherit user;
        command = hyprland;
      };
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
