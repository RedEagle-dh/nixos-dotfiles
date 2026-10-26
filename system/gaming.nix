{ pkgs, user, ... }:

{
  programs.steam = {
    enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
    localNetworkGameTransfers.openFirewall = true;
  };

  programs.gamemode.enable = true;
  users.users.${user}.extraGroups = [ "gamemode" ];

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  environment.systemPackages = [
    pkgs.mangohud
    pkgs.heroic
  ];
}
