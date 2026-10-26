{ pkgs, ... }:

{
  home.packages = [
    pkgs.pavucontrol
    pkgs.playerctl
    pkgs.libnotify
  ];
}
