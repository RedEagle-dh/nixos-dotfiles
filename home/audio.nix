{ pkgs, ... }:

{
  home.packages = [
    pkgs.pavucontrol
    pkgs.alsa-scarlett-gui
    pkgs.playerctl
    pkgs.libnotify
  ];
}
