# system/gaming.nix – Spielen: Steam mit Proton, Heroic, Gamemode, Gamescope, MangoHud.
#
# Windows-Spiele laufen in Steam über Proton: Rechtsklick aufs Spiel →
# Eigenschaften → Kompatibilität → "Proton Experimental" oder "GE-Proton".
# Startoptionen (ebenfalls in den Eigenschaften), kombinierbar:
#   gamemoderun %command%     CPU auf volle Leistung, solange das Spiel läuft
#   mangohud %command%        Einblendung mit FPS, CPU- und GPU-Last
#   gamescope -f -- %command% eigener Mini-Compositor, hilft bei Spielen mit
#                             Problemen bei Auflösung, Vollbild oder Maus
#   PROTON_ENABLE_WAYLAND=1 PROTON_ENABLE_HDR=1 %command%
#                             HDR (mit GE-Proton): dann im Spiel HDR einschalten
#                             und im Vollbild spielen – der Monitor schaltet
#                             von selbst um (hyprland.lua, Abschnitt BILDSCHIRM)
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

  environment.systemPackages = [
    pkgs.mangohud
    # Spiele von Epic, GOG und Amazon. Proton-/Wine-Versionen (z. B. GE-Proton)
    # lädt Heroic im "Wine Manager" selbst herunter.
    pkgs.heroic
  ];
}
