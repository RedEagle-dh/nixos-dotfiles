# home/discord.nix – Discord als Vesktop: eigener Discord-Client mit Vencord
# (Plugins, Themes) und funktionierender Bildschirmfreigabe unter Wayland.
#
# Farben: caelestia schreibt bei jedem Farbwechsel das Theme "Midnight" in
# den aktuellen Farben nach ~/.config/vesktop/themes/caelestia.theme.css
# (siehe caelestia/default.nix, enableDiscord). Neue Farben übernimmt
# Vesktop sofort, ohne Neustart.
#
# Plugins und Einstellungen: in Vesktop selbst (Einstellungen → Vencord).
# Was hier steht, wird bei jedem nhs wieder gesetzt, der Rest bleibt erhalten.

{ ... }:

{
  programs.vesktop = {
    enable = true;

    mutableSettings = true;
    settings = {
      discordBranch = "stable";
      arRPC = true; # "Spielt gerade …" für Spiele und Programme
      minimizeToTray = true;
      hardwareAcceleration = true;
      checkUpdates = false; # Updates kommen über nix flake update
    };

    vencord.mutableSettings = true;
    vencord.settings = {
      # Weitere Themes landen in derselben Liste – hier eintragen, sonst
      # setzt nhs sie wieder zurück
      enabledThemes = [ "caelestia.theme.css" ];
    };
  };
}
