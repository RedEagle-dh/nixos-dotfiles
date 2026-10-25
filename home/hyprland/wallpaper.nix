# home/hyprland/wallpaper.nix – Hintergrundbild.
# Das Bild selbst wird in theme/wallpaper.nix aus der Farbpalette erzeugt.

{ lib, pkgs, theme, ... }:

{
  systemd.user.services.wallpaper = {
    Unit = {
      Description = "Hintergrundbild";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${lib.getExe pkgs.swaybg} --mode fill --image ${theme.wallpaper}";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
