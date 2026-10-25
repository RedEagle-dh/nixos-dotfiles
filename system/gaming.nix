# system/gaming.nix – Spielen: Steam mit Proton, Gamemode, Gamescope, MangoHud.
#
# Windows-Spiele laufen in Steam über Proton: Rechtsklick aufs Spiel →
# Eigenschaften → Kompatibilität → "Proton Experimental" oder "GE-Proton".
# Startoptionen (ebenfalls in den Eigenschaften), kombinierbar:
#   gamemoderun %command%     CPU auf volle Leistung, solange das Spiel läuft
#   mangohud %command%        Einblendung mit FPS, CPU- und GPU-Last
#   gamescope -f -- %command% eigener Mini-Compositor, hilft bei Spielen mit
#                             Problemen bei Auflösung, Vollbild oder Maus
# Die 32-Bit-Grafiktreiber, die Steam braucht, stehen in nvidia.nix.

{ pkgs, user, ... }:

{
  programs.steam = {
    enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ]; # GE-Proton: mehr Codecs & Spiele-Fixes
    localNetworkGameTransfers.openFirewall = true; # Spiele von anderen PCs im Netz kopieren
  };

  programs.gamemode.enable = true;
  users.users.${user}.extraGroups = [ "gamemode" ];

  programs.gamescope = {
    enable = true;
    capSysNice = true; # darf sich höhere Priorität geben → flüssigere Bilder
  };

  environment.systemPackages = [ pkgs.mangohud ];
}
